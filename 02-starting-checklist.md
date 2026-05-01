# 02. Starting Checklist

Before you build a new custom agent action, walk through this checklist. It saves the cost of redoing things halfway through, and it forces a few decisions to the surface that the Salesforce UI does not prompt you to make.

The checklist is organised by phase: design, implementation, registration, integration, validation, and release. Tick off items in order. A skipped earlier item is the most common reason for a stuck later item.

## Phase 1. Design

- [ ] **Decide whether the action should be Apex, flow, prompt template, or external.** Apex is right for transactional logic and synchronous business rules. Flows are right for declarative orchestration that may chain multiple updates. Prompt templates are right for things the LLM should write rather than the platform should compute. External services or named credentials are right for callouts to systems Salesforce does not own.
- [ ] **Define the input and output contract first, on paper.** Field names, types, requiredness, and the units. Most schema mistakes are made when the schema is implied rather than stated.
- [ ] **Decide whether the action is idempotent.** If it is not idempotent, decide what should happen if the LLM retries it. Many production incidents come from non-idempotent actions invoked twice.
- [ ] **Decide on confirmation requirements.** If the action sends an email, charges a card, deletes a record, or does anything else that the user should approve before it happens, set `isConfirmationRequired` on the function. The platform will then surface a confirmation step in the conversation.
- [ ] **Pick the agent user.** The action will run as that user. Make sure that user has, or can be granted, the access the implementation will need.

## Phase 2. Implementation

- [ ] **Apex method (if applicable).** Annotate with `@InvocableMethod`. Wrap the input in a class with `@InvocableVariable` fields. Same for output. Return a list, even if the action only handles one record at a time. The platform's invocable runner expects bulk shape.
- [ ] **Tests.** Write at least one positive and one negative test. Aim for the standard 75 percent coverage but treat the test as documentation of expected behaviour. The agent will discover edge cases for you in production.
- [ ] **Errors.** Throw clear, actionable exception messages. The agent will sometimes surface them to the end user verbatim. "Bad input" is not a message. "Account number must be numeric, got 'A123'" is.
- [ ] **No platform-context dependencies.** If your code reads `UserInfo.getUserId()` and assumes the human is the agent user, decide whether that is correct. Often it is not.
- [ ] **No silent failure.** Returning an empty result on error makes the agent confidently say "Done" while nothing has happened. Throw, or return a structured error in the output.
- [ ] **Deploy and verify with a direct REST call.** Before you go anywhere near Agentforce, confirm the action is callable via `/services/data/v62.0/actions/custom/apex/<name>`. This isolates the implementation from the wiring.

## Phase 3. Registration as an agent action

- [ ] **Create the `GenAiFunction` record.** Either via *Setup, Agent Actions, New Agent Action* or by hand-authoring the metadata file.
- [ ] **Set the right `invocationTargetType`.** `apex` for invocable methods, `flow` for flows, `prompt` for prompt templates.
- [ ] **Set the `invocationTarget`.** For Apex this is the bare class name (when the function and class share a namespace) or the prefixed API name (when they do not).
- [ ] **Map inputs and outputs.** The function's input schema must match the implementation's input shape exactly. The runtime will not coerce.
- [ ] **Write a useful description.** The LLM uses this when deciding whether to invoke the action. "Get connection info" is too short. "Determine whether the user has an authenticated Lumin session, returning a boolean and a status message" is right.
- [ ] **Write a progress message.** This is what the conversation says while the action is running. Default it to something honest like "Checking connection now" rather than the generic "Working on it".
- [ ] **Retrieve the new metadata into the workspace.** `sf project retrieve start` after every UI change is non-negotiable. Otherwise the next environment will not know about it.

## Phase 4. Integrate with the agent

- [ ] **Add the action to the relevant topic or subagent in Builder.** Map function inputs to agent variables. Map function outputs to agent variables.
- [ ] **Decide reasoning policy.** Should the LLM decide when to invoke the action, or should the topic explicitly run it? Both are valid. Make the choice deliberate.
- [ ] **Update the conversation copy.** "Tell the user that the authentication has been successfully set" is fine for a placeholder, but final copy should match the brand voice.
- [ ] **Save the topic, then retrieve again.** The `.agent` file changes when you add an action.

## Phase 5. Validation

- [ ] **Permission set check for the agent user.** Look at *Setup, Agent Studio, User Access* and confirm the agent user has the permission set that includes your Apex class.
- [ ] **Simulator pass.** Run a representative prompt in the Builder simulator. Confirm the action fires and returns the expected outputs.
- [ ] **Activate the agent.** Without this, test mode will fail.
- [ ] **Test mode pass.** Run the same prompt in test mode, not just simulation.
- [ ] **Edge cases.** Empty input. Wrong input. The "happy path" twice in a row. Each one of these has bitten someone.

## Phase 6. Release

- [ ] **Commit all metadata.** The `.cls` files, the `.genAiFunction-meta.xml`, the input and output JSON Schemas, the `.agent` file, the bundle metadata XML.
- [ ] **Update the runbook.** The post-deploy step list for sandboxes and production must include the activation step. See [Chapter 6](./06-release-and-activation.md).
- [ ] **Document the action.** A short note in the team's documentation describing the contract, the failure modes, and the owner. Future you will thank present you.
- [ ] **Decide on monitoring.** Will you log invocation counts? Failures? Latency? Pick at least one signal and wire it up before you ship.

## A common shortcut, and why not to take it

The temptation, especially with the new aiAuthoringBundle DSL, is to declare an action inline in the `.agent` file with `target: "apex://..."` and skip creating a `GenAiFunction` record. The Builder accepts it, the deploy succeeds, and you assume that is enough.

It is not. The runtime expects a registered `GenAiFunction` for custom Apex actions. The inline declaration alone passes structural validation but does not produce a callable runtime entry. The result is the "Action name not found" error that has cost more time than any other single Agentforce issue.

Always create the `GenAiFunction` wrapper. The two minutes you save by skipping it will turn into half a day of debugging.

## References

- [Apex `@InvocableMethod`](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
- [Metadata API: `GenAiFunction`](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaifunction.htm)
- [Permission sets](https://help.salesforce.com/s/articleView?id=sf.perm_sets_overview.htm)
- [Field-Level Security](https://help.salesforce.com/s/articleView?id=sf.admin_fls.htm)
- [Apex testing best practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_qs_test.htm)
