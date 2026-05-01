# Templates

Copy-paste skeletons for the artefacts you need to build a custom Agentforce action. Replace the placeholders (in `<ANGLE_BRACKETS>`) with your own values, then deploy.

## What's here

| File | Purpose |
|------|---------|
| `agent-skeleton.agent` | Starter `.agent` DSL with one subagent, one topic, one action |
| `bundle-meta-skeleton.xml` | Wrapper file for an `aiAuthoringBundle` |
| `genAiFunction-skeleton.xml` | A `GenAiFunction` metadata file pointing at an Apex invocable |
| `input-schema-skeleton.json` | Input JSON Schema for the function |
| `output-schema-skeleton.json` | Output JSON Schema for the function |
| `apex-invocable-skeleton.cls` | An `@InvocableMethod` Apex class |
| `apex-invocable-skeleton.cls-meta.xml` | Metadata wrapper for the Apex class |
| `apex-test-skeleton.cls` | Test class for the invocable |
| `permissionset-skeleton.xml` | Permission set granting access to the class |
| `project-scratch-def.json` | Scratch org definition with Agentforce features enabled |
| `package.xml` | Sample manifest for retrieve operations |

## How to use

1. Create your project layout (or use this guide's parent project as a starting point).
2. Copy the skeletons into the right folders under `force-app/main/default/`.
3. Search and replace the placeholders. Common ones:
   - `<AgentName>`: e.g. `Customer_Service_Agent`
   - `<ActionName>`: e.g. `Get_Order_Status` (developer name)
   - `<ClassName>`: e.g. `GetOrderStatus` (Apex class name, no underscores)
   - `<ns>`: your org's namespace, or empty
4. Deploy in this order: Apex class, permission set, GenAiFunction, AiAuthoringBundle.
5. Activate the agent in Builder.

The full walkthrough is in [Chapter 0: Quickstart](../00-quickstart.md).
