# Agentforce Field Guide

A practical handbook for developers and architects who are building agents on Salesforce Agentforce. Written by people who hit these problems in production and wrote down what they learned.

The aim is simple: keep you out of the kind of trouble that costs a day or two and produces an error message that names the wrong layer.

## Who this is for

- **Developers** who are wiring up custom Apex, flows, or prompt templates into agents and want a checklist that prevents the obvious failure modes.
- **Architects** who are designing the broader integration and need to know which seams require deployment discipline, which require human action, and which silently diverge between environments.
- **Tech leads** who are setting up the team's first Agentforce project and want a baseline that survives the first round of "it works on my org but not on yours".

It is not a beginner's introduction to Salesforce or to LLM agent design. It assumes you know what an Apex invocable method is, what a permission set does, and what an LLM-orchestrated agent is meant to do.

## How to read it

Pick the chapter that matches what you are doing right now.

### Quickstart

| Chapter | Read it when |
|---------|--------------|
| [00. Quickstart](./00-quickstart.md) | You want a working custom action in 15 minutes, end to end. |

### Foundations

| Chapter | Read it when |
|---------|--------------|
| [01. The Mental Model](./01-mental-model.md) | You are starting on Agentforce and want the layered architecture in your head. |
| [02. Starting Checklist](./02-starting-checklist.md) | You are about to build a new agent action. Run through this first. |
| [03. Naming and Namespaces](./03-naming-and-namespaces.md) | You keep getting "We couldn't find the flow, prompt, or apex class" or similar resolution errors. |
| [04. Development Loop](./04-development-loop.md) | You are unsure what to do in the Builder UI and what to keep in source control. |

### Operations

| Chapter | Read it when |
|---------|--------------|
| [05. Troubleshooting](./05-troubleshooting.md) | The agent is not behaving and you need a structured way to find the broken layer. |
| [06. Release and Activation](./06-release-and-activation.md) | You are promoting agents from sandbox to production. |
| [07. Anti-Patterns and Pitfalls](./07-anti-patterns.md) | You want to know what to avoid before you do it. |
| [11. Observability](./11-observability.md) | You need to know what your agent is doing in production. |
| [13. Performance and Limits](./13-performance-and-limits.md) | The agent is slow, or you want to design within the budgets. |
| [17. Cost Optimization](./17-cost-optimization.md) | The bill is bigger than expected. |
| [18. CI/CD Recipes](./18-cicd-recipes.md) | You want concrete pipeline configurations for GitHub, GitLab, or Bitbucket. |

### Design and engineering

| Chapter | Read it when |
|---------|--------------|
| [09. Security](./09-security.md) | You are designing an agent that touches sensitive data. |
| [10. Testing](./10-testing.md) | You want a real testing strategy, not just Apex unit tests. |
| [12. Decision Matrix](./12-decision-matrix.md) | You are deciding whether the action should be Apex, flow, prompt, or external. |
| [14. Conversation Design](./14-conversation-design.md) | You are deciding between topics, subagents, and gated flows. |
| [19. Designing Agents and Subagents](./19-designing-agents-and-subagents.md) | You are at the whiteboard, planning a new agent. |
| [20. Prompt Engineering](./20-prompt-engineering.md) | You want the LLM to behave reliably. |

### Reference and migration

| Chapter | Read it when |
|---------|--------------|
| [08. Glossary and References](./08-glossary.md) | You see a term and want one paragraph of context. |
| [15. FAQ](./15-faq.md) | You have a quick question and want a quick answer. |
| [16. Migration Guides](./16-migration-guides.md) | You are moving from legacy bots, or from another platform. |

### Worked material

| Folder | What's in it |
|--------|--------------|
| [Cookbook](./cookbook) | Four end-to-end worked examples with all files: Apex action, flow action, prompt template action, action with callout. |
| [Templates](./templates) | Copy-paste skeletons for `.agent`, `GenAiFunction`, JSON Schemas, Apex, permission sets, scratch org definition. |
| [Case Studies](./case-studies) | Anonymised real incidents and how they were resolved. |

## The thirty-second version

If you only have time to remember three things, remember these.

1. **Agentforce is layered, and the error messages do not tell you which layer broke.** A single "Action name not found" can mean a missing Apex class, a missing `GenAiFunction` wrapper, a missing topic linkage, or an unactivated agent. Always work through the layers in order, cheapest first.

2. **Authoring state is not runtime state.** Saving in the Builder edits the draft. Test mode and production conversations run against the activated runtime version. Activate after every meaningful change. Treat a passing simulation as encouragement, not as proof.

3. **Anything you do in the UI is invisible to the next environment until the metadata is retrieved and committed.** Treat *retrieve-after-UI-change* as part of the work, not as cleanup.

## The five layers at a glance

![Custom Apex Agent Action: The Five Layers](diagrams/five-layers.svg)

## Project status

This guide is at version 0.3.0. See [CHANGELOG.md](./CHANGELOG.md) for what changed when.

Every chapter ends with a **References** section linking to the canonical Salesforce documentation that backs its claims. The full canonical index is in [REFERENCES.md](./REFERENCES.md). Verification status, last-checked date, and known corrections are in [VERIFICATION.md](./VERIFICATION.md).

Contributions are welcome. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the conventions and process. Be kind: see [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md).

## License

The text and diagrams are released under [Creative Commons Attribution 4.0](./LICENSE). You can copy, share, adapt, and use this in your own work, including commercial work. We just ask that you credit the source.

## A note on tone

The chapters here use plain prose, short sentences where short sentences fit, and code blocks that you can copy. They avoid jargon for its own sake. When a term has to appear because Salesforce uses it, the [Glossary](./08-glossary.md) explains it once and you can flip back.

If you find an error, fix it where you find it. The point is to keep the next person from losing a day to the same problem.
