# 08. Glossary and References

A short reference for terms, metadata types, and useful commands. The glossary is alphabetical. The references at the end point to the platforms, tools, and Salesforce resources you will need most often.

## Glossary

### Activation

The process of promoting an agent's authoring (draft) state into the runtime registry. Performed via the Builder UI. Each environment requires its own activation. Without activation, test mode and production conversations will not see your changes.

### Agent

A configured AI persona that orchestrates conversation, reasoning, and action invocation. Implemented as an `AiAuthoringBundle` in the new format, or as a `BotDefinition` in the legacy format.

### Agent Action

In Salesforce terminology, this is the `GenAiFunction` record that wraps a piece of platform logic (Apex, flow, prompt) and registers it as something the agent can invoke. Created via *Setup, Agent Actions*.

### Agent User

The Salesforce user under whose identity the agent's actions run. Configured per agent. Permission checks happen against this user, not against the human the agent is talking to.

### `AiAuthoringBundle`

The new metadata type (introduced around API 65) that holds an entire agent definition in a single bundle. Composed of a `.agent` DSL file plus a `.bundle-meta.xml` wrapper. Replaces the legacy `Bot` plus `BotVersion` plus `GenAiPlannerBundle` decomposition.

### Authoring State

The editable state of an agent that the Builder UI shows. Changes here do not affect the runtime until you activate.

### Bot (legacy)

The pre-aiAuthoringBundle agent format. Stored as `bots/<BotName>/...` in source. Has a separate `BotVersion` that tracks Active or Inactive status. Newer agents do not use this format.

### `BotVersion`

A specific version of a legacy `Bot`. Has a `Status` of `Active` or `Inactive`. Multiple versions can exist; one is active at a time.

### Builder

The UI for authoring agents. Salesforce calls it Agentforce Builder. Includes a simulator panel for quick iteration.

### `GenAiFunction`

A first-class metadata record that registers a piece of platform logic as an invocable agent action. Has a developer name, master label, description, input and output schemas, and an `invocationTargetType` plus `invocationTarget` pair that points at the underlying implementation.

### `GenAiFunctionDefinition`

The Tooling API representation of a `GenAiFunction`. Useful for verifying that a function exists and is wired up correctly. Query with `--use-tooling-api`.

### `GenAiPluginDefinition`

A Tooling API record that represents a topic-like grouping of agent actions. Used by the legacy planner-bundle format and partly by the new format.

### `InvocableMethod`

An Apex annotation that exposes a static method to the platform's invocable runner. The agent runtime calls invocable methods through `GenAiFunction` records of type `apex`.

### `InvocableVariable`

An annotation on a class field that marks it as an input or output to an invocable method. Required for any input or output type referenced by the method's signature.

### LDS (Lightning Data Service)

The framework Salesforce uses for declarative data binding in Lightning components. The Agentforce Builder uses it for the validation that produces the "Action name not found" error in the Builder console.

### O11Y Error

Salesforce's observability error format. Surfaces in the browser console as a structured payload with `name`, `message`, `stack`, and `userPayload` fields. The `userPayload` is the most useful part for diagnosis.

### Plan Tracer

The runtime trace ID emitted in error responses (`urn:trace:plan_tracer_<id>`). The only durable handle for correlating with server-side logs. Save it when you escalate to Salesforce Support.

### Planner

The component of the agent runtime that decides which action to invoke given the current conversation state. ReAct-style by default.

### Prompt Template

A reusable LLM prompt with parameters. Lives in `GenAiPromptTemplate` metadata. Can be invoked as an agent action via a `GenAiFunction` of type `prompt`.

### Reasoning

The LLM-driven planning step in an agent's loop. Configured per topic or subagent in the `.agent` DSL.

### Runtime State

The state of an agent that the runtime engine actually serves. Updated only when you activate.

### Simulator

The "Try Agent" panel in the Builder. Useful for quick iteration. May resolve some things from authoring state, so a passing simulation is not proof that the agent works in test or production.

### Subagent

A self-contained agent fragment that handles a specific portion of conversation. Linked into the parent agent via the `start_agent` and `subagent` blocks in the `.agent` DSL.

### Test Mode

A surface in the Salesforce UI for exercising the activated agent. Closer to production than the simulator. If the simulator passes but test mode fails, check activation.

### Topic

A scoped portion of an agent's behaviour, with its own instructions, allowed actions, and reasoning configuration. The LLM picks among topics based on user intent.

### Tooling API

A Salesforce REST API for metadata operations. Distinct from the standard REST API. Some metadata (like `GenAiFunctionDefinition`) is only queryable via the Tooling API. Use `--use-tooling-api` on `sf data query`.

### Variable

A named slot in an agent's state. Holds conversation state, action results, or platform-derived values. Declared in the `variables:` block of the `.agent` DSL.

## Quick command reference

### Org and metadata inspection

```bash
# List authenticated orgs
sf org list

# Show details for an org
sf org display -o <ORG>

# Org's namespace
sf data query -o <ORG> -q "SELECT NamespacePrefix FROM Organization"

# Apex class inspection
sf data query -o <ORG> --use-tooling-api \
    -q "SELECT Name, NamespacePrefix, Status, IsValid FROM ApexClass WHERE Name LIKE '%<Pattern>%'"

# GenAiFunction inspection
sf data query -o <ORG> --use-tooling-api \
    -q "SELECT DeveloperName, MasterLabel, InvocationTargetType, InvocationTarget FROM GenAiFunctionDefinition"
```

### Retrieve

```bash
# Specific class
sf project retrieve start -o <ORG> -m "ApexClass:<Name>"

# All agent bundles
sf project retrieve start -o <ORG> -m "AiAuthoringBundle:*"

# All GenAiFunctions
sf project retrieve start -o <ORG> -m "GenAiFunction:*"

# Catch-all for a session
sf project retrieve start -o <ORG> \
    -m "AiAuthoringBundle:*" -m "GenAiFunction:*" -m "ApexClass:*"
```

### Deploy

```bash
# Specific path
sf project deploy start -d force-app/main/default/classes/<Name>.cls -o <ORG>

# An agent bundle
sf project deploy start -d force-app/main/default/aiAuthoringBundles/<Name> -o <ORG>

# Validate without deploying
sf project deploy validate -d <path> -o <ORG>
```

### Direct REST invocation of a custom Apex action

```bash
TOK=$(sf org display -o <ORG> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["accessToken"])')
INSTANCE=$(sf org display -o <ORG> --json | python3 -c 'import json,sys;print(json.load(sys.stdin)["result"]["instanceUrl"])')

# List
curl -s -H "Authorization: Bearer $TOK" \
    "$INSTANCE/services/data/v62.0/actions/custom/apex"

# Describe
curl -s -H "Authorization: Bearer $TOK" \
    "$INSTANCE/services/data/v62.0/actions/custom/apex/<ns>__<ClassName>"

# Invoke
curl -s -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
    -X POST \
    "$INSTANCE/services/data/v62.0/actions/custom/apex/<ns>__<ClassName>" \
    -d '{"inputs":[{"<name>": <value>}]}'
```

## Useful external resources

- [Salesforce Trailblazer Community: Agentforce](https://www.salesforce.com/trailblazer/community/) for finding others who have hit the same issue.
- The Salesforce Developer Documentation, specifically the sections on Agentforce, Invocable Actions, and Custom Apex actions.
- The Tooling API reference for entity definitions you cannot find in the standard SOQL surface.
- The Metadata Coverage Report for figuring out whether a given type can be deployed via a given API version.
- The Metadata API Developer Guide.

## Where this guide cannot help

A few classes of problem are outside the scope of this guide:

- **Capacity, billing, and licensing.** Talk to your account executive.
- **Org-level Setup that has been customised by other parties.** If a previous consultant has done unusual things to permission sets or org-wide settings, you will have to reverse-engineer.
- **Genuine platform regressions.** Salesforce ships changes regularly and sometimes a new release breaks something that was working. File a case if you cannot find a workaround.

For everything else, work through the layered model and the troubleshooting chapter. They cover the bulk of what teams hit in practice.

## References

This glossary draws from across the Salesforce documentation. The full canonical index is in [REFERENCES.md](./REFERENCES.md). Spot-check entries against:

- [Agentforce Developer Guide](https://developer.salesforce.com/docs/ai/agentforce/guide/)
- [Metadata API: AiAuthoringBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm)
- [Metadata API: GenAiFunction](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaifunction.htm)
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [Tooling API objects](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/reference_objects_list.htm)
