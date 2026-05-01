# 04. Development Loop

Building Agentforce agents pulls a developer in two directions. Some of the work has to happen in a UI (creating agents, linking actions, activating versions). Some of the work is plain Salesforce metadata that should live in source control like everything else. The discipline that keeps a project healthy is knowing which is which and respecting the seams.

## What the UI is good for, and what source is good for

| Task | UI | Source |
|------|----|--------|
| Designing an agent's conversation flow | Yes. Faster, more visual. | No. The DSL is hard to author from scratch. |
| Creating a `GenAiFunction` | Yes. The form generates the schema correctly. | Yes, but you have to author the JSON Schemas yourself. |
| Linking a function to a topic | Yes. Drag and drop. | Possible, but error-prone. |
| Editing instructions | Either. | Either. |
| Activation | Only the UI, currently. | Cannot be deployed. |
| Reviewing what changed | Source. The diff tells the truth. | Source is the only reliable answer. |
| Sharing a config across environments | Source. The UI does not export to other orgs. | Source. |

The pattern that works is: **author in the UI, retrieve to source after every change, commit the source, deploy to other environments from source.** Activation is the only step that has to be done manually in each environment.

## The retrieve-after-UI rule

Every UI click that changes metadata has to be followed by a retrieve. Otherwise the change exists only in the org you happened to be working in, and the next environment will not know about it. The phrase to internalise is "if it is not in source, it does not exist".

```bash
# After creating or editing a GenAiFunction in the UI
sf project retrieve start -o <ORG> -m "GenAiFunction:*"

# After editing an agent in Builder
sf project retrieve start -o <ORG> -m "AiAuthoringBundle:<AgentName>"

# Catch-all for the relevant types after a session
sf project retrieve start -o <ORG> \
  -m "AiAuthoringBundle:*" -m "GenAiFunction:*" -m "ApexClass:*"
```

The retrieve is fast and idempotent. There is no reason not to run it.

## Source organisation

A clean repo for Agentforce work tends to look like this:

```
force-app/main/default/
    aiAuthoringBundles/
        <AgentName>/
            <AgentName>.agent              <-- the DSL
            <AgentName>.bundle-meta.xml    <-- bundle wrapper
    classes/
        <Action>Invocable.cls              <-- the @InvocableMethod
        <Action>Invocable.cls-meta.xml
        <Action>InvocableTest.cls
    flows/
        <FlowName>.flow-meta.xml           <-- if you use flows
    genAiFunctions/
        <FunctionName>/
            <FunctionName>.genAiFunction-meta.xml
            input/schema.json
            output/schema.json
    permissionsets/
        <Agent>_User.permissionset-meta.xml
```

A few notes:

- Keep the `genAiFunctions/` directory tidy. One folder per function. The schemas live next to the meta XML. Do not collapse them into a flat list.
- Agent bundles tend to grow. Consider one agent per repo if the agents are independent, or one folder per agent if they share infrastructure.
- Permission sets that grant access to actions deserve their own file, named after the agent, so the dependency is obvious.

## The CI loop

A typical CI pipeline for Agentforce work runs on every pull request:

1. Static analysis on Apex (PMD, Checkmarx, or whatever your team uses).
2. Apex compile and test.
3. Metadata validation against a designated scratch org or sandbox.
4. JSON Schema validation against the function input and output files.
5. A linter pass on the `.agent` DSL (the IDE diagnostic stream is the most reliable source of validation rules).

What the CI cannot do:

- Activate an agent. There is no metadata to activate.
- Run the LLM and see if it picks the right action. Manual.
- Replicate the runtime registry's resolution exactly. Validation runs in the SOAP API context, runtime runs in the agent execution context. They mostly agree, but the agent runtime is the authoritative test.

So the CI gives you confidence that the source is well-formed. It does not give you confidence that the agent works. For that you need a human-in-the-loop test pass on a real org.

## Local development workflow

A workflow that has worked across several Agentforce projects:

1. **Spin up a scratch org with the right namespace and feature set.** Agentforce features need to be enabled in the scratch definition.
2. **Push the project source into the scratch org.** `sf project deploy start -o <ORG>`.
3. **Author or edit the agent in Builder.** Click around. Try things.
4. **Retrieve any UI changes back to source.** Don't skip this even for "small" changes.
5. **Commit source frequently.** Especially before activating, so you can roll back the source if the activated runtime turns out to be wrong.
6. **Activate.** Now the runtime is up to date.
7. **Test.** First in simulator (cheap). Then in test mode (slower but accurate). Then with a real conversation through whichever channel matters (slowest, most accurate).
8. **Iterate.**

The most valuable habit in this loop is step 4. Almost every "where did the change go?" question has the same answer: nobody retrieved.

## Working with the new `.agent` DSL

The aiAuthoringBundle format is dense. A few practical observations:

- The IDE diagnostic stream catches a lot of mistakes (invalid target schemes, unused variables, broken references). Pay attention to its warnings.
- The DSL uses indentation strictly. A single mis-aligned space breaks the parse, but the error message will not always point to the exact line.
- References between sections use the `@<scope>.<name>` syntax. `@actions.X`, `@variables.Y`, `@subagent.Z`. If a reference does not resolve, the most common reason is a typo in the name.
- The DSL is currently underdocumented. The IDE diagnostic stream is your best reference, with the OOTB planner bundles as a secondary source of examples. Read what Salesforce ships before you invent your own.

## Working in parallel

Agentforce agent metadata is not split into many files. It is concentrated in a single `.agent` file per agent. That makes merge conflicts more likely than they would be on a typical Lightning component.

Mitigations:

- One agent per developer per branch, where possible.
- Section-level conventions: keep variables alphabetised, keep actions in a stable order, so diffs are smaller and easier to read.
- Pull and rebase often. The `.agent` file does not lend itself to a satisfying three-way merge.

## Hand-offs between developer and admin

Agentforce blurs the line between developer work and admin work. The same project can require a developer to write Apex and an admin to wire actions in the Builder. Be explicit about who owns each step.

A useful pattern:

- Developer owns Apex and tests.
- Developer or admin creates the `GenAiFunction` (whoever is closer to the input/output schema).
- Admin owns conversation design (instructions, topic structure, copy).
- Whoever is shipping owns activation.
- Both review the merged result before activation.

The trap is that a UI change made by an admin can reach production without ever passing through a developer's review or a CI pipeline, because the UI does not enforce a pull-request flow. Decide as a team how to handle that.

## References

- [Salesforce CLI command reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm)
- [`sf project deploy/retrieve` commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_project_commands_unified.htm)
- [Salesforce DX source format](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_source_file_format.htm)
- [Agent Script language characteristics](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-lang.html)
- [Source tracking changes (Dec 2025)](https://github.com/forcedotcom/cli/issues/3375)
