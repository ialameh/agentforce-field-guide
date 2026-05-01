# 15. FAQ

A scannable Q&A for the questions teams ask most often. Each answer points to the chapter where the topic gets fuller treatment.

## Architecture

**Q. Why does my action fail at runtime when the deploy succeeded?**
A. Almost always one of: missing GenAiFunction wrapper, missing topic linkage, or missing activation. See [Chapter 5](./05-troubleshooting.md) for the layered triage.

**Q. What is the difference between an Apex invocable and an agent action?**
A. The Apex invocable is the underlying logic. The agent action (a `GenAiFunction` record) is the wrapper that registers the invocable as something the agent can call. You need both. See [Chapter 1](./01-mental-model.md).

**Q. Do I need a `GenAiFunction` for every action?**
A. For custom Apex, flow, and prompt template actions: yes. For Salesforce-shipped standard actions, no, they come pre-registered.

**Q. Where does the agent run? On my org or somewhere else?**
A. Apex runs on your org. The LLM call leaves the org for inference. The runtime that orchestrates them is part of Salesforce's hosted Agentforce infrastructure. Confirm data residency with your account team if it matters.

## Naming and namespaces

**Q. Why does `apex://lumin.AdminSetupInvocable` not deploy?**
A. Wrong separator. Use double underscores: `apex://lumin__AdminSetupInvocable`. The dot is Apex source syntax only. See [Chapter 3](./03-naming-and-namespaces.md).

**Q. My scratch org is namespaced. My project is not. Is that a problem?**
A. Usually not for retrieve and deploy. It matters when creating new scratch orgs or packaging. See [Chapter 3](./03-naming-and-namespaces.md).

**Q. Why can't a default-namespace class call a `public` method in the `lumin` namespace?**
A. Cross-namespace access requires `global`. `public` is namespace-internal. See [Chapter 3](./03-naming-and-namespaces.md).

## Development workflow

**Q. I edited the agent in the Builder. Why does the next environment not see my changes?**
A. You forgot to retrieve. Run `sf project retrieve start -o <ORG> -m "AiAuthoringBundle:*" -m "GenAiFunction:*"`. See [Chapter 4](./04-development-loop.md).

**Q. Should I author in the UI or in source?**
A. Author in the UI for speed. Retrieve to source for reproducibility. Don't pick one or the other. Both. See [Chapter 4](./04-development-loop.md).

**Q. Can I version-control the activated runtime version?**
A. No. Activation is not deployable metadata, currently. Plan to activate manually in each environment.

## Activation and testing

**Q. The simulator works but test mode fails. Why?**
A. Activation. The simulator can run against draft state; test mode runs against the activated runtime version. Click Activate. See [Chapter 7](./06-release-and-activation.md).

**Q. My change in the Builder is not picked up by the agent.**
A. Same answer. Activate.

**Q. Do I have to activate after every change?**
A. Yes. Saving the change records it in authoring state. Activation promotes it to runtime state. Both are required.

**Q. Is there an API to activate from CI?**
A. Not currently for the new aiAuthoringBundle format. Some teams have built unsupported scripts. Treat them as fragile.

## Custom actions

**Q. My Apex method does not show up in the agent action picker. Why?**
A. The class likely lacks `@InvocableMethod`, or the method is not public, or the input wrapper does not have `@InvocableVariable`. Confirm via `curl /services/data/v62.0/actions/custom/apex` that the action is registered. See [Chapter 5](./05-troubleshooting.md).

**Q. How do I know if my agent has the right permissions?**
A. Query `SetupEntityAccess` for the agent user's permission sets. The Apex class should be granted via at least one. See [Chapter 5](./05-troubleshooting.md).

**Q. My action throws but the agent says "Done". Why?**
A. Probably an exception swallowed by a `try/catch` that returns an empty result. Fix the catch block to throw or return a structured error. See [Chapter 7](./07-anti-patterns.md).

## Performance

**Q. The agent is slow. What can I do?**
A. Measure first. Latency P95 per action, SOQL count per invocation. Optimise the slowest step. See [Chapter 13](./13-performance-and-limits.md).

**Q. My action makes a callout that takes 8 seconds. The runtime times out.**
A. Move the callout into a queueable. Have the action return immediately with a "started" status. A follow-up action checks the result. See [Chapter 13](./13-performance-and-limits.md).

**Q. What is the per-action time budget?**
A. A few seconds, with a hard timeout around 10 seconds. Aim for under 2 seconds.

## Cost

**Q. Why is my agent expensive?**
A. Most likely too many actions in the topic, bloated action descriptions, or long conversation history not being truncated. See [Chapter 17](./17-cost-optimization.md).

**Q. Do I get charged for failed actions?**
A. Generally yes. The LLM call happens whether the downstream action succeeds or fails. Reducing failure rate cuts cost as well as improving reliability.

**Q. Can I cache action results?**
A. Yes, in custom storage or Platform Cache. Useful for deterministic actions with stable inputs. Be careful with cache invalidation.

## Security

**Q. Can a user trick the agent into running an action I did not intend?**
A. Yes. Prompt injection is real. Validate inputs in Apex regardless of what the schema says. See [Chapter 9](./09-security.md).

**Q. Should the agent user be a copy of my admin user?**
A. No. The agent user should have a scoped permission set with only the access this agent needs. See [Chapter 9](./09-security.md).

**Q. How do I prevent the agent from leaking PII in its responses?**
A. Tag PII in the output schema. Use `filter_from_agent: True` for fields the LLM should not see. Redact at log boundaries. See [Chapter 9](./09-security.md).

## Operations

**Q. How do I monitor an agent in production?**
A. Emit Platform Events from inside Apex actions. Build dashboards on top. Wire alerts on failure rate and latency. See [Chapter 11](./11-observability.md).

**Q. A user complained that the agent did the wrong thing. How do I investigate?**
A. If you have action invocation logs with conversation ids, query for that conversation and inspect the action chain. If you do not, this is harder. Either way, plan for this in advance. See [Chapter 11](./11-observability.md).

**Q. How do I roll back a bad agent change?**
A. The Builder retains version history. Reactivate a previous version. If the change came from source, deploy the previous source and reactivate. See [Chapter 6](./06-release-and-activation.md).

## Troubleshooting specifics

**Q. I see "AG Grid: invalid gridOptions property" in the console. Is that my problem?**
A. No. That is internal Salesforce Lightning component noise. Ignore it. The actionable errors are from `ldsAdaptersAgentAuthoring.js` and runtime `MISSING_RECORD` lines.

**Q. The error says "Action name not found: lumin__X". I created `X`. What's missing?**
A. One of: the GenAiFunction does not exist, the function is not linked to the agent's topic, or the agent is not activated. See [Chapter 5](./05-troubleshooting.md).

**Q. My action call returns "INSUFFICIENT_ACCESS". Where is the gap?**
A. The agent user is missing class access (or FLS / CRUD on a touched object). Check `SetupEntityAccess` and field-level security. See [Chapter 9](./09-security.md).

## Migration

**Q. We have a legacy bot. Should we migrate to aiAuthoringBundle?**
A. Eventually yes, the new format is where Salesforce is investing. Plan it as a project, not as an in-place migration. See [Chapter 16](./16-migration-guides.md).

**Q. Can I have legacy bots and new aiAuthoringBundle agents in the same org?**
A. Yes. They coexist. Useful during a phased migration.

## Process

**Q. Who should own the agent, dev or admin?**
A. Both. Dev owns Apex and tests. Admin owns conversation design. Activation is the shared step. Be explicit about ownership in your team. See [Chapter 4](./04-development-loop.md).

**Q. How do I make agent work fit into our existing PR review process?**
A. Treat the `.agent` file, the `.genAiFunction-meta.xml`, and the JSON Schemas as code. Require review for changes. Get admins to push their UI changes through the same flow via retrieve.

## Things that look like questions but are not

**"Why does Salesforce do it this way?"** Sometimes the answer is "for good reasons" and sometimes it is "because it shipped that way and they have not changed it yet". Either way, you cannot change the platform. Work with what you have.

**"Will Salesforce add feature X?"** Maybe. Subscribe to Release Notes. Don't bet a project on a feature that is not in GA.

**"Is there a better way?"** Often yes. Read [Chapter 7](./07-anti-patterns.md) before assuming the way you have is the right way.

## References

For the full canonical index, see [REFERENCES.md](./REFERENCES.md). Each Q&A links to its relevant chapter, where chapter-specific references live.
