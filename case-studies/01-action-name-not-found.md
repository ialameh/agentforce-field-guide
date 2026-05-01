# Case 01. "Action name not found", and the four reasons it can mean

## Context

A team building a customer-facing agent on a namespaced scratch org. The agent's first reasoning step calls a custom action that checks whether the user has an active session with an external service. The Apex code is written, the agent definition is in source control, the deploy succeeds. The agent simulator runs. The action fails.

## Symptoms

Browser console while running the simulation:

```
ldsAdaptersAgentAuthoring.js: Validation failed for action(s) 'Get_Connection_Info'
due to invalid attribute value for 'target'.
Invocable action 'CheckSession' does not exist.

client.js: O11Y Error "Something went wrong. Refresh and try again."
```

Plus a steady stream of AG Grid warnings about deprecated `gridOptions` properties, which were a red herring (internal Salesforce UI noise, unrelated to the agent).

The runtime trace, when the simulator did get to invoking the action, returned:

```json
{
  "statusCode": "MISSING_RECORD",
  "message": "Action name not found: ns__CheckSession",
  "fields": null
}
```

## Initial hypothesis

First thought: the Apex class was not deployed, or had a compile error.

Verified via Tooling API:

```bash
sf data query --use-tooling-api \
  -q "SELECT Name, NamespacePrefix, Status, IsValid FROM ApexClass WHERE Name='CheckSession'"
```

Result: one row, namespace prefix matched the org's namespace, status Active, IsValid true. The class was fine.

Second hypothesis: the action was not registered with the platform's invocable runner.

Verified via REST:

```bash
curl -H "Authorization: Bearer $TOK" \
  "$INSTANCE/services/data/v62.0/actions/custom/apex"
```

Result: `ns__CheckSession` was in the list. Direct REST invocation worked, returning the expected output.

So the Apex was fine, the action was registered, and it was callable directly. But the agent runtime claimed the action did not exist. Confusing.

## What was actually wrong

Three layers of wiring were missing or broken, all giving the same generic error message:

1. **The `target:` URI in the `.agent` DSL was bare** (`apex://CheckSession`), with no namespace prefix. The runtime in a namespaced org expects `apex://ns__CheckSession`.
2. **No `GenAiFunction` record existed** for the action. The `.agent` DSL inline declaration was not enough. The runtime expects a registered `GenAiFunction` (created via Setup, Agent Actions) for custom Apex actions.
3. **The agent had not been activated** after the `GenAiFunction` was created. The runtime registry only sees changes after activation, so even with the function in place, the agent could not see it until the next activate.

Each missing piece produced the same "Action name not found" error. There was no way to tell from the message which one was at fault.

## What they did

In order:

1. **Confirmed the Apex layer was fine** (Tooling API query, REST invocation). This isolated the problem to the Agentforce wiring.
2. **Fixed the `target:` URI** to use the namespaced API name with double underscores: `apex://ns__CheckSession`. Deploy passed; runtime still failed with the same error.
3. **Created a `GenAiFunction` via Setup, Agent Actions, New Agent Action.** Set the type to Apex, the reference action to `ns__CheckSession`, mapped the inputs and outputs. Saved. Retrieved the new metadata into source.
4. **Linked the action to the relevant subagent in Builder.** The action appeared under "Actions Available For Reasoning". Saved.
5. **Activated the agent.** This was the missing final step. Until activation, the runtime registry did not see the linkage.
6. **Re-tested.** The simulation passed. Test mode passed. Action invocations resolved correctly.

Total time from first error to resolution: about two hours, most of it spent ruling out red herrings (the AG Grid warnings, hypothetical permission issues, debating whether the dotted form `apex://ns.CheckSession` could work).

## What they learned

A few takeaways that informed the rest of this guide:

1. **The same error message covers four distinct root causes.** Apex missing, GenAiFunction missing, topic linkage missing, agent not activated. Without a layered triage discipline, you guess wrong and waste time.

2. **Browser console noise is mostly Salesforce UI components.** AG Grid warnings, deprecated property warnings, missing-toast-label warnings. None of them mattered. The signal was the `ldsAdaptersAgentAuthoring.js` line and the runtime `MISSING_RECORD`.

3. **Authoring state is not runtime state.** A passing simulation can coexist with a failing test. Activation is the bridge, and forgetting it is the most common operational mistake.

4. **Sanity-check Apex via direct REST before blaming Agentforce.** It takes thirty seconds and immediately tells you whether the issue is in your code or in the wiring.

5. **The dot vs double-underscore distinction matters.** API names in metadata files use double underscores. The dot form is Apex source syntax only. Confusing the two costs deploys.

6. **The Tooling API is the source of truth for metadata diagnostics.** `GenAiFunctionDefinition` is only queryable via Tooling. So is `ApexClass.Body`. So are several other useful tables.

## What this case became

This case is the origin of the field guide you are reading. The team wrote up the incident the same week. Then they realised the writeup applied beyond their project, and turned it into a generic handbook.

The specific incident docs (with the original org name, class names, and chronology) live separately. This case study is the anonymised version that captures the lessons without the project context.

## How to apply this to your own situation

If you are seeing "Action name not found" right now:

1. Open [Chapter 5: Troubleshooting](../05-troubleshooting.md).
2. Walk through the layered probes in order.
3. Stop at the first one that fails. That is your problem.

The probes are designed to be cheap (Tooling queries, REST calls) so you can run them all in five minutes if you have to.
