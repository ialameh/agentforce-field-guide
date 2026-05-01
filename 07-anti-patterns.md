# 07. Anti-Patterns and Pitfalls

A list of mistakes that are common, costly, and recurrent. Most of these are not mistakes anyone would make on purpose. They tend to creep in under deadline pressure, or because the platform's defaults nudge you the wrong way. Knowing them ahead of time is the best defence.

## Skipping the GenAiFunction wrapper

The single most expensive mistake. When you author an agent with the new `.agent` DSL and declare an action inline:

```yaml
actions:
    Get_Connection_Info:
        target: "apex://lumin__AdminSetupInvocable"
        ...
```

It is tempting to assume this is enough, because the deploy succeeds and the Builder accepts it. It is not. The agent runtime expects a registered `GenAiFunction` record for custom Apex actions. Without it, the runtime cannot resolve the action and you get an opaque "Action name not found" error.

**Always create the `GenAiFunction` wrapper.** Two minutes of work avoids hours of debugging.

## Editing in the UI without retrieving to source

The Builder accepts any change you make and saves it to the org. The next environment will not know about that change until the metadata is retrieved and committed.

A common scenario:

1. Developer A creates an agent action in the dev sandbox, links it to a topic, activates the agent.
2. Developer A calls it done.
3. Two weeks later, the team promotes the codebase to staging. The `GenAiFunction` does not exist in staging, the agent does not work.
4. Developer A is on holiday.

**Retrieve after every UI change.** Make it a habit. It costs five seconds per change and saves the next person a debugging session.

## Activating at the wrong time

A surprising number of agent issues come down to "I activated, but I forgot to retrieve first" or "I retrieved, but I forgot to activate after deploy".

**Order matters.** The right sequence is:

1. Author in Builder.
2. Retrieve to source.
3. Commit and merge.
4. Deploy to the next environment.
5. Activate in that environment.

If you skip step 2, source is out of date. If you skip step 5, the runtime is out of date. Either way, something will not work.

## Trusting the simulator

The Builder simulator is convenient. It is also generous. It can sometimes resolve actions from authoring state that the runtime would not be able to find. So a passing simulation does not prove the agent works.

**Always test in test mode.** The simulator is a quick check. The test mode is a real check.

## Naming actions after the implementation

It is tempting to name the agent action `AdminSetupInvocable` because that is what the underlying class is called. Resist.

The agent action's name is part of the LLM's prompt context. The LLM uses the name (along with the description) when deciding whether to invoke the action. A name that describes the **behaviour** (`Get_Connection_Info`, `Sync_Account_From_External_System`, `Send_Welcome_Email`) is far more useful than a name that describes the **implementation** (`AdminSetupInvocable`, `SyncCallout`, `EmailController`).

The implementation can change. The behaviour, hopefully, does not.

## Returning empty data on error

Apex methods invoked from Agentforce often look like this:

```apex
public static List<Result> doThing(List<Input> inputs) {
    try {
        // ... business logic ...
    } catch (Exception e) {
        return new List<Result>(); // <-- silent failure
    }
}
```

The catch block looks defensive. It is destructive. The agent gets back an empty result, the LLM concludes the action ran successfully with no data to report, and confidently tells the user "Done". The user trusts the agent. The action did not actually do anything.

**Throw a specific exception, or return a structured error.** Either makes the failure visible to the LLM, which can then either retry, ask the user, or escalate.

## Ignoring idempotency

Agentforce sometimes retries actions automatically. The LLM also sometimes invokes an action a second time because it forgets it ran the first time. Both are real, both happen in production.

If your action sends an email, charges a card, creates a record, deletes a record, or has any other side effect that is not safely repeatable, **make it idempotent** or use the `isConfirmationRequired` flag on the `GenAiFunction` to surface a confirmation step in the conversation.

The cheap forms of idempotency that work for most cases:

- A nonce field on a record, populated by the agent, checked before the action proceeds.
- A "last action timestamp" field that prevents reruns within a window.
- A check-then-act pattern in the Apex method itself.

The expensive forms (full transaction logging, distributed locking, etc.) are sometimes warranted, but most actions can get away with the cheap forms.

## Over-trusting the agent's input

The LLM can hallucinate inputs. It can also be persuaded by a sufficiently determined user to pass values you did not anticipate. Treat agent inputs the way you would treat HTTP request inputs: as untrusted, with explicit validation at the boundary.

This is doubly true for inputs that determine which records the action operates on. The LLM may pass a recordId from a different account than the one the user is supposed to be operating on. **Authorise** before you act.

## Forgetting the agent runs as a different user

`UserInfo.getUserId()` inside an agent action returns the agent user, not the human conversing with the agent. If your action depends on knowing who the human is, you have to thread that information through explicitly, typically via a conversation variable like `@MessagingEndUser.ContactId`.

The pattern that catches people: code that worked in a user-context test scenario fails in agent-context production because the implicit user is different.

## Long-running actions

Each agent action has a per-step time budget. If your Apex makes a long callout, calls another long-running process, or otherwise takes more than a few seconds, the runtime will time the action out. The agent will then either retry or hand the conversation off to an error path.

**Keep custom actions fast.** Aim for under 2 seconds, allow up to 5 seconds reluctantly. For longer work, kick off a queueable from the action and have the action return immediately with a status like "Started, you'll be notified when it's done".

## Coupling the agent's variables to the platform's data model

It is tempting to model agent variables on Salesforce sObjects: a `Account_Id` variable that the agent threads through every conversation. Sometimes that is the right thing. Often it is not.

Agent variables are good at holding **state of the conversation**, not state of the database. The platform already knows the database. Use variables for things like "what is the user trying to do", "what step are we on", "what was the last error". Use the database for things like "what is the user's account number".

Mixing the two leads to variables that drift out of sync with the records they are mirroring, which leads to confusing bugs.

## One agent for everything

It is tempting to build one big agent that handles every case the team can think of. Don't.

Smaller, focused agents are easier to test, easier to maintain, easier to reason about, and easier to attribute production incidents to. If two agents have very different audiences, very different sets of actions, or very different conversation styles, they should be two agents. The platform supports this comfortably with subagents and agent-to-agent handoff.

A useful test: if you cannot describe your agent's purpose in a single sentence, you probably have two agents stuck together.

## Letting the agent improvise where it should not

The LLM is creative. That is its strength and its weakness. For actions that have hard correctness requirements (legal disclaimers, regulated information, financial calculations), put the deterministic logic in Apex or a flow and have the agent call it. Do not rely on the LLM to produce correct text for these cases.

A good rule: if the action's output is going on the internet, into a contract, into a regulated system, or into a place where a wrong answer has a cost, it is deterministic logic, not generation.

## Letting permission sets decay

Permission sets that grant access to agent action classes tend to accumulate. Someone adds a class. The permission set grows. The class is removed but the permission entry remains. The permission set then has a stale reference to a class that no longer exists.

This is not usually a runtime problem. It is a hygiene problem that complicates audits and slows down DevOps. Set a quarterly reminder to clean up permission sets and remove references to classes that no longer exist.

## Writing the agent description as if it were marketing copy

Every `GenAiFunction` has a description. The Salesforce UI prompts you for it. There is a temptation to write something punchy and customer-facing.

Resist. The description is for the LLM, not for the customer. Write it like a function docstring: "Determine the connection status to the Lumin API, returning a boolean and a status message". The LLM uses this to decide when to invoke the action. It does not need marketing copy. It needs precise behaviour description.

Same goes for the action label, the input descriptions, and the output descriptions. Be precise. Brevity helps. Salesforce's own OOTB actions are a good model.

## Using too many subagents

Subagents are useful when a conversation has fundamentally different modes. They are not a substitute for good topic design.

If you find yourself building five subagents for a simple workflow, step back. Most of the time, a single agent with several topics, each scoped to a clear purpose, is more maintainable than a constellation of subagents.

The question to ask: does this subagent have its own personality, audience, or behaviour, or is it really just a topic in disguise?

## References

- [Apex `@InvocableMethod` (callout, idempotency notes)](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm)
- [Metadata API: `GenAiFunction` (`isConfirmationRequired`)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaifunction.htm)
- [Apex security best practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_security.htm)
- [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
