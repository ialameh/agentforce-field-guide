# References

Canonical Salesforce documentation for every claim made in this guide. Organised by topic so you can verify any specific point quickly.

This index is the source of truth for "where did that come from". When a Salesforce feature changes, the documentation here is what we re-check first.

## Verification status

The claims in this guide were last cross-checked against published Salesforce documentation in **May 2026**, against the **Spring '26 (API version 65 and 66)** release. Salesforce ships changes every release; some of what's documented here may have evolved by the time you read it. The disclaimer in [VERIFICATION.md](./VERIFICATION.md) lists the specific items most likely to change, and the canonical pages to consult.

## Agent metadata types

| Topic | Canonical reference |
|-------|---------------------|
| AiAuthoringBundle (introduced API v65) | [Metadata API: AiAuthoringBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm) |
| Agent Script language reference | [Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html) |
| Agent Script: actions and target schemes | [Actions](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-ref-actions.html) |
| Agent Script: language characteristics | [Language Characteristics](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-lang.html) |
| Agent Script: full reference | [Reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-reference.html) |
| Agent metadata directory layout | [Agent Metadata](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-metadata.html) |
| GenAiFunction | [Metadata API: GenAiFunction](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaifunction.htm) |
| GenAiPlannerBundle (API v64+) | [Metadata API: GenAiPlannerBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiplannerbundle.htm) |
| GenAiPlanner (legacy, API v60-v63) | [Metadata API: GenAiPlanner](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiplanner.htm) |
| GenAiPromptTemplate | [Metadata API: GenAiPromptTemplate](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiprompttemplate.htm) |
| Bot (legacy bot framework) | [Metadata API: Bot](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_bot.htm) |
| Agentforce Tooling API entities | [Metadata Types reference](https://developer.salesforce.com/docs/ai/agentforce/references/agents-metadata-tooling/agents-metadata.html) |
| All metadata types index | [Metadata Types](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_types_list.htm) |

## Apex

| Topic | Canonical reference |
|-------|---------------------|
| `@InvocableMethod` annotation | [Apex Developer Guide: InvocableMethod](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableMethod.htm) |
| Callouts from invocable actions (`callout=true`) | [Making Callouts to External Systems from Invocable Actions](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_forcecom_flow_invocable_action_callout.htm) |
| `@InvocableVariable` | [Apex Developer Guide: InvocableVariable](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_classes_annotation_InvocableVariable.htm) |
| Governor limits (100 SOQL, 150 DML, 10s CPU, 6 MB heap, 100 callouts) | [Execution Governors and Limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) |
| Limits Quick Reference | [Salesforce Developer Limits and Allocations](https://developer.salesforce.com/docs/atlas.en-us.salesforce_app_limits_cheatsheet.meta/salesforce_app_limits_cheatsheet/salesforce_app_limits_platform_apexgov.htm) |
| Apex testing | [Apex Developer Guide: Testing](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_qs_test.htm) |
| Platform Events | [Platform Events Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.platform_events.meta/platform_events/) |

## REST API and direct invocation

| Topic | Canonical reference |
|-------|---------------------|
| Invoke a custom Apex action via REST | [Invocable Actions Custom](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_actions_invocable_custom.htm) |
| Get custom invocable actions | [Get Custom Invocable Actions](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_actions_invocable_custom_get.htm) |
| Apex actions overview | [Apex Actions](https://developer.salesforce.com/docs/atlas.en-us.api_action.meta/api_action/actions_obj_apex.htm) |
| Actions Developer Guide (full) | [Actions Developer Guide](https://resources.docs.salesforce.com/latest/latest/en-us/sfdc/pdf/api_action.pdf) |
| Standard Invocable Actions | [Standard Actions](https://developer.salesforce.com/docs/atlas.en-us.api_action.meta/api_action/actions.htm) |

## Salesforce CLI

| Topic | Canonical reference |
|-------|---------------------|
| `sf` CLI command reference | [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm) |
| `sf project deploy / retrieve` | [project Commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_project_commands_unified.htm) |
| Source tracking changes (Dec 2025) | [GitHub Issue 3375](https://github.com/forcedotcom/cli/issues/3375) |
| CLI release notes | [forcedotcom/cli releases](https://github.com/forcedotcom/cli/blob/main/releasenotes/README.md) |

## Tooling API

| Topic | Canonical reference |
|-------|---------------------|
| Tooling API overview | [Tooling API Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/intro_api_tooling.htm) |
| `ApexClass` Tooling object | [ApexClass](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_apexclass.htm) |
| `BotVersion` | [BotVersion](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_botversion.htm) |

## Agentforce Builder, Studio, and runtime

| Topic | Canonical reference |
|-------|---------------------|
| Agentforce overview | [Agentforce Developer Guide](https://developer.salesforce.com/docs/ai/agentforce/guide/) |
| Get started with agents | [Get Started](https://developer.salesforce.com/docs/einstein/genai/guide/get-started-agents.html) |
| Agentforce APIs and SDKs | [Agentforce APIs and SDKs](https://developer.salesforce.com/docs/einstein/genai/guide/get-started-agents.html) |
| Agentforce Builder UI overview (Trailhead) | [Unlock Powerful Features of the New Agentforce Builder](https://trailhead.salesforce.com/content/learn/modules/new-agentforce-builder-quick-look/explore-the-new-agentforce-builder) |
| Enable Agentforce in your org | [Enable Agentforce](https://help.salesforce.com/s/articleView?id=ai.agent_setup_enable.htm) |
| Invoke agents from Apex and Flow | [Invoke Agentforce Agents with Apex and Flow](https://developer.salesforce.com/blogs/2025/04/invoke-agentforce-agents-with-apex-and-flow) |

## Pricing, billing, and observability

| Topic | Canonical reference |
|-------|---------------------|
| Agentforce pricing page | [Agentforce Pricing](https://www.salesforce.com/agentforce/pricing/) |
| Generative AI usage and billing | [Agentforce and Generative AI Usage and Billing](https://help.salesforce.com/s/articleView?id=ai.generative_ai_usage.htm) |
| Einstein Requests pricing model (formula) | [Einstein Requests Pricing Update](https://tirnav.com/blog/salesforce-einstein-requests-pricing-update) |
| Flex Credits model | [Agentforce Pricing Update Q3 2025](https://aquivalabs.com/blog/agentforce-pricing-gets-a-long-overdue-fix-flex-credits-are-now-live/) |

## Security

| Topic | Canonical reference |
|-------|---------------------|
| Salesforce Trust and Compliance | [trust.salesforce.com](https://trust.salesforce.com/) |
| Apex security best practices | [Apex Security](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_security.htm) |
| Field-level security | [Field-Level Security](https://help.salesforce.com/s/articleView?id=sf.admin_fls.htm) |
| Permission sets | [Permission Sets](https://help.salesforce.com/s/articleView?id=sf.perm_sets_overview.htm) |
| Named Credentials | [Named Credentials](https://help.salesforce.com/s/articleView?id=sf.named_credentials_about.htm) |
| OWASP LLM Top 10 (industry reference) | [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/) |

## Release notes

| Release | Reference |
|---------|-----------|
| Spring '26 | [Spring '26 Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.salesforce_release_notes.htm) |
| Spring '26 platform features (community summary) | [Spring '26 Platform Features](https://levelshift.com/blogs/spring-26-salesforce-platform-lightning-new-features) |
| Winter '26 Agentforce changes (Gearset summary) | [Winter '26 Agentforce changes](https://docs.gearset.com/en/articles/12550109-agentforce-changes-in-the-winter-26-release) |
| Salesforce Release Notes index | [Release Notes](https://help.salesforce.com/s/) |

## Industry references and community

| Topic | Reference |
|-------|-----------|
| Trailblazer Community (Q&A and discussion) | [Salesforce Trailblazer Community](https://www.salesforce.com/trailblazer/community/) |
| Trailhead (free training) | [Trailhead](https://trailhead.salesforce.com/) |
| Salesforce Developer Blog | [Developer Blog](https://developer.salesforce.com/blogs) |
| Agent Script blog post | [Agent Script Decoded](https://developer.salesforce.com/blogs/2026/02/agent-script-decoded-intro-to-agent-script-language-fundamentals) |
| Salesforce Ben (community) | [Salesforce Ben Agentforce coverage](https://www.salesforceben.com/) |

## Tooling and deployment helpers

| Tool | Reference |
|------|-----------|
| Gearset (deployment) | [Gearset Help Center](https://docs.gearset.com/) |
| Metazoa Snapshot | [Metazoa](https://www.metazoa.com/) |
| Salesforce DevOps Center | [DevOps Center](https://help.salesforce.com/s/articleView?id=sf.devops_center_overview.htm) |

## Per-chapter cross-reference

A short list of which references back which chapter, so you can verify a specific claim quickly.

| Chapter | Primary references |
|---------|---------------------|
| 00 Quickstart | Apex `InvocableMethod`, `GenAiFunction`, `AiAuthoringBundle`, REST custom apex actions |
| 01 Mental Model | Agent metadata directory layout, Agentforce Builder overview |
| 02 Starting Checklist | Same as 00 plus Permission sets, FLS |
| 03 Naming and Namespaces | Salesforce namespace docs, managed package basics |
| 04 Development Loop | `sf project deploy / retrieve`, source tracking |
| 05 Troubleshooting | Tooling API objects, REST custom apex actions, Builder UI |
| 06 Release and Activation | Agent Metadata DX, Bot/BotVersion |
| 07 Anti-Patterns | Cumulative; references throughout the rest of the guide |
| 08 Glossary | All of the above |
| 09 Security | Apex security, FLS, Permission Sets, Named Credentials, OWASP LLM Top 10 |
| 10 Testing | Apex testing, REST custom apex actions, Tooling API |
| 11 Observability | Platform Events, Apex `Logger`, debug logs |
| 12 Decision Matrix | Agent Script actions reference, Standard Actions, Flow, Prompt Templates |
| 13 Performance and Limits | Execution Governors and Limits, Limits Quick Reference |
| 14 Conversation Design | Agent Script reference, Agentforce Builder Trailhead |
| 15 FAQ | Cumulative |
| 16 Migration Guides | GenAiPlanner, GenAiPlannerBundle, AiAuthoringBundle, Bot |
| 17 Cost Optimization | Einstein Requests pricing, Flex Credits, Platform Cache |
| 18 CI/CD Recipes | `sf` CLI reference, GitHub Actions, GitLab CI, Bitbucket Pipelines |
| 19 Designing Agents | Agentforce Builder, Trailhead modules |
| 20 Prompt Engineering | Agent Script reasoning, Prompt template best practices |

## Salesforce-specific terminology

A few terms have official Salesforce names that the community sometimes uses inconsistently. The canonical ones, for clarity:

| Casual term | Official term |
|-------------|---------------|
| "the .agent file" | Agent Script file |
| "the agent's planner" | Reasoning |
| "the action" (as referenced in `.agent`) | Local action declaration |
| "the action" (as a global registration) | GenAiFunction |
| "the agent definition" | AiAuthoringBundle |
| "the bot" (legacy) | Bot + BotVersion |
| "the linked actions for a topic" | Topic action references |
| "the activated agent" | The current active version of the AiAuthoringBundle |

Use the official terms when filing Salesforce support cases or discussing with Salesforce account teams.
