# 16. Migration Guides

Salesforce has shipped two distinct ways to build conversational agents: the legacy `Bot` framework and the newer `AiAuthoringBundle` (the `.agent` DSL). Many orgs have both, often by accident. This chapter covers the practical paths from one to the other.

## Legacy Bot to AiAuthoringBundle

### What changes

| Concept | Legacy Bot | AiAuthoringBundle |
|---------|-----------|-------------------|
| Definition | `Bot` + `BotVersion` metadata | Single `.agent` file |
| Source layout | `bots/` folder | `aiAuthoringBundles/` folder |
| Topics | Bot dialogs | Topics in DSL |
| Actions | Invocable referenced via planner bundles | Inline action declarations or GenAiFunction references |
| Activation | `BotVersion.Status = Active` | Builder UI activate |
| Variables | Conversation variables on BotVersion | Variables block in DSL |
| Reasoning | Less flexible, more rules-based | LLM-driven planner |

The new format is denser, more flexible, and what Salesforce is investing in. Eventually the old one will be deprecated.

### Why migrate

- Better LLM reasoning. The new planner is smarter.
- Single-file agent definition. Easier to review, easier to diff.
- More consistent metadata story. Modern features ship for the new format first.
- Less duplication. The new format pulls in functions by reference rather than re-declaring them.

### Why not migrate (yet)

- Migration is not a deploy-and-pray operation. You will rebuild conversation logic.
- Some features are still legacy-only at any given moment. Check the release notes.
- If the old bot works and is not under active change, you can leave it.

### Migration approach

Two paths, depending on how invested you are in the existing bot.

**Path 1. Greenfield rebuild.**

Treat the new agent as a new project. Read the existing bot's behaviour, capture the requirements in plain English, build the new agent from scratch using the field guide. Keep the old bot running until the new one is proven.

This is the cleanest path. Most teams end up here.

**Path 2. Mechanical port.**

Translate each bot dialog to a topic. Each invocable reference to a GenAiFunction. Each conversation variable to a DSL variable. Then test side-by-side and switch over.

This is faster but produces a literal translation that may not take advantage of the new format's strengths. Useful when you have many simple bots and need to migrate at scale.

### Step-by-step (path 1)

1. **Inventory.** List every dialog in the bot. Note the actions each one runs, the variables it touches, the entry conditions.
2. **Design.** For each dialog, decide whether it should become a topic, a subagent, or be merged with another. Often the new format wants fewer larger topics than the old format had dialogs.
3. **Functions.** For each invocable referenced in the bot, create a `GenAiFunction` record (if one does not already exist). Confirm it is callable via the REST endpoint.
4. **Build the .agent file.** Use the [template](./templates/) as a starting point. Add subagents, topics, actions, variables, reasoning.
5. **Permission set.** The agent user for the new agent needs its own permission set. Do not reuse the legacy bot's; the access surface is likely different.
6. **Test.** Run the new agent in test mode. Compare side-by-side with the legacy bot for a representative set of conversations.
7. **Cutover.** When the new agent matches the old, switch the inbound channel (whatever surface the user lands on). Decommission the old bot once you are confident.

### Common gotchas during migration

- **Variable scope changes.** Legacy bots had per-dialog and global variable scopes. The new format simplifies this. Some logic that depended on dialog-scoped variables has to be rethought.
- **Linked variables to platform context.** If your bot used messaging session context, the new format's `linked` variables work differently. Re-map them.
- **Action calls in instructions.** The new DSL invokes actions through reasoning blocks; the old format had explicit "run action" steps. Idiom is different.
- **Error handling.** The old format had explicit error dialogs. The new format relies on LLM-driven error handling, which you have to design into instructions.

## Prompt-only agent to action-driven agent

Some teams started with an agent that only used prompt templates ("just have the LLM answer questions"). They now need the agent to do things. This is a smaller migration but worth covering.

### What changes

You add Apex actions or flows to the agent's surface, link them to topics, and update the topic instructions to use them.

### Why migrate

- Prompt-only agents cannot reliably touch data. Real CRM agents need to.
- Determinism. An action returns the same answer for the same input; a prompt does not.
- Auditability. Action invocations log cleanly; prompt outputs are harder to audit.

### Approach

1. Identify the next thing the agent should be able to do. Pick something concrete.
2. Build it as an action following the [Quickstart](./00-quickstart.md).
3. Link it to the relevant topic.
4. Update the topic's instructions to mention when to use the action.
5. Test. Repeat for the next thing.

This is incremental. You don't have to redesign the whole agent.

## Per-environment promotion

Once you have an agent in source control, moving it between environments is mostly mechanical. The exceptions are the things that don't deploy cleanly: agent user assignments, permission set assignments, activation.

### Recommended flow

1. **Dev.** Build and iterate in a sandbox or scratch org. Use the Builder for fast feedback.
2. **Integration.** Auto-deploy from main branch on merge. Activation may be automated by a script (unsupported but possible) or done manually.
3. **QA.** Auto-deploy on release tag. Manual activation. Run the conversation eval suite.
4. **UAT.** Same as QA but with stakeholders looking at it.
5. **Production.** Same as QA but with a manual approval gate. Activation is manual and announced to the team channel.

See [Chapter 6](./06-release-and-activation.md) for the full release runbook.

## Migrating between Salesforce releases

Salesforce ships changes to Agentforce every few months. Some are additive, some change the DSL or the metadata format.

### Tactics that work

- **Pin your API version in `sfdx-project.json`.** Don't auto-upgrade. Let the team upgrade deliberately when there is time to handle breakage.
- **Track release notes.** Subscribe. Read the Agentforce sections every release.
- **Test against a future-version sandbox.** Salesforce makes preview sandboxes available before each major release. Test there before the release hits production sandboxes.
- **Have a rollback plan.** If the upgrade breaks production, you need a way back. The Builder version history helps. Source control helps more.

### A useful checklist for a Salesforce upgrade

- [ ] Read the relevant release notes.
- [ ] Spin up a preview-version sandbox.
- [ ] Deploy the current source.
- [ ] Run the conversation eval suite.
- [ ] Note any failures or warnings.
- [ ] Triage: are these breakages, deprecations, or noise?
- [ ] Plan fixes for breakages before the release reaches production.

## Migrating from another platform (Dialogflow, Lex, Bot Framework)

If you came from a non-Salesforce conversational platform, the mental model is different in a few specific ways:

- **Salesforce expects you to live in the org.** Actions touch records natively. Other platforms call out for everything.
- **The agent user is real.** It has a username and a profile. Not a service principal.
- **Authoring and runtime are separate.** Other platforms tend to deploy on save. Salesforce makes you activate.
- **Agentforce is opinionated about reasoning.** The LLM is allowed to choose actions, but there is a planner in the middle. You don't write a free-form LLM loop.

The migration is rarely a literal port. Usually it is a redesign that takes advantage of Salesforce-native features (permission model, sObjects, native actions). Plan accordingly.

## When to wait

A few situations where holding off on migration is wise:

- The current solution works and is not under change. Stability matters more than modernity.
- The new format is missing a feature you depend on. Wait for the release that adds it.
- You are mid-quarter on a deadline. Migrations take longer than expected. Don't combine them with other deliverables.

Migration is rarely urgent unless the old format is breaking. Plan it as a project. Schedule it. Don't sneak it into a sprint as a "small refactor".

## References

- [`AiAuthoringBundle` (introduced API v65)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm)
- [`GenAiPlannerBundle` (introduced API v64)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiplannerbundle.htm)
- [`GenAiPlanner` (legacy, API v60-v63)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiplanner.htm)
- [`Bot` (legacy bot framework)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_bot.htm)
- [Spring '26 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.salesforce_release_notes.htm)
