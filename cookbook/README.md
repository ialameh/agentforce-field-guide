# Cookbook

Worked end-to-end examples. Each one shows every file you need, in the right place, with the placeholders filled in. Copy any of these into your project, adjust to taste, deploy.

## Examples

| # | Example | When to use this pattern |
|---|---------|--------------------------|
| [01](./01-apex-action) | Apex action: order status lookup | You need deterministic logic that touches Salesforce records |
| [02](./02-flow-action) | Flow action: create a follow-up task | You want admins to maintain the orchestration |
| [03](./03-prompt-action) | Prompt template action: draft a customer reply | You want the LLM to write text in a controlled way |
| [04](./04-action-with-callout) | Apex action with callout: lookup external customer | You need to call an external system |

## How to use these

1. Copy the example folder into your project's source root (or create a sibling project).
2. Update the placeholders. The most common ones are `<ns>` (your org's namespace, or empty), `<AgentName>`, and class names.
3. Deploy with `sf project deploy start -d <path> -o <ORG>`.
4. Add the action to your agent in the Builder.
5. Activate the agent.
6. Test it.

If something does not work, walk through the [Troubleshooting](../05-troubleshooting.md) chapter.

## Conventions

Every example follows the same structure:

```
<example>/
    README.md                               <-- description and walkthrough
    classes/
        <ActionName>.cls                    <-- Apex implementation (where applicable)
        <ActionName>.cls-meta.xml
        <ActionName>Test.cls                <-- tests
        <ActionName>Test.cls-meta.xml
    genAiFunctions/
        <Function_Name>/
            <Function_Name>.genAiFunction-meta.xml
            input/schema.json
            output/schema.json
    flows/                                  <-- where applicable
    permissionsets/
        <ActionName>_Permissions.permissionset-meta.xml
```

That mirrors what you would commit to source control. The `agent` snippet that wires the action into a topic is in each example's README.
