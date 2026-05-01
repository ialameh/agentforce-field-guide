# Verification Notes and Corrections

This document records when the field guide was last cross-checked against published Salesforce documentation, what was confirmed, what was corrected, and what is still uncertain.

If you find a claim in the guide that no longer matches the official Salesforce documentation, please open a PR or an issue. See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Last verification

- **Date:** May 2026
- **Salesforce release tracked:** Spring '26
- **API versions checked:** 60, 62, 64, 65, 66
- **Method:** Cross-checked against Salesforce Developer Documentation, Help articles, and Release Notes via web search.

## What was confirmed

| Claim | Source |
|-------|--------|
| `AiAuthoringBundle` is the metadata type for new-format agents (introduced API v65) | [Metadata API: AiAuthoringBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm) |
| File extension for the Agent Script is `.agent` | [Agent Metadata](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-metadata.html) |
| Bundle directory layout (`aiAuthoringBundles/<api-name>/<api-name>.agent` plus `<api-name>.bundle-meta.xml`) | Same |
| `GenAiFunction` represents an agent action; an agent can have multiple | [GenAiFunction docs](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaifunction.htm) |
| `GenAiPlannerBundle` is the metadata type for API v64 agents | [GenAiPlannerBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiplannerbundle.htm) |
| `GenAiPlanner` is the legacy metadata for API v60-v63 | Same |
| Agent Script target URI format: `{TARGET_TYPE}://{DEVELOPER_NAME}` | [Actions reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-ref-actions.html) |
| Apex governor limits: 100 SOQL sync (200 async), 150 DML, 10s CPU sync, 6 MB heap sync, 100 callouts | [Execution Governors and Limits](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_gov_limits.htm) |
| `@InvocableMethod` requires `callout=true` for HTTP callouts | [Making Callouts from Invocable Actions](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_forcecom_flow_invocable_action_callout.htm) |
| REST endpoint `/services/data/vXX.X/actions/custom/apex/<class-name>` | [Invocable Actions Custom](https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/resources_actions_invocable_custom.htm) |
| `sf project deploy start` and `sf project retrieve start` are the unified CLI commands | [Salesforce CLI Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm) |
| Source tracking required by default starting Dec 2025, unless metadata is specified explicitly | [GitHub forcedotcom/cli #3375](https://github.com/forcedotcom/cli/issues/3375) |
| Bot and BotVersion are the legacy structure: only one BotVersion can be active | [Salesforce Help: Bot Versions](https://help.salesforce.com/s/articleView?id=sf.bots_service_managing_bot_versions.htm) |
| Agent Script uses indentation for structure (Python-like) | [Agent Script Language Characteristics](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-lang.html) |
| `@` symbol references variables, actions, topics, outputs in Agent Script | Same |
| Einstein Requests pricing formula: `RoundUp((input + output tokens) / 2000) * Multiplier` | [Einstein Requests Pricing](https://tirnav.com/blog/salesforce-einstein-requests-pricing-update) |
| Flex Credits model: $0.10 per action, 100,000 credits for $500 | [Agentforce Flex Credits](https://aquivalabs.com/blog/agentforce-pricing-gets-a-long-overdue-fix-flex-credits-are-now-live/) |

## Corrections to apply (versus earlier guide drafts)

### 1. Target URI schemes are limited to three in official docs

**Earlier draft said:** Valid `target:` schemes include `api`, `apex`, `apexRest`, `auraEnabled`, `cdpMlPrediction`, `flow`, `prompt`, `slack`, `mcpTool`, `standardInvocableAction`, and ~12 others (sourced from the IDE diagnostic stream).

**Salesforce documentation says:** Three target types are documented for Agent Script actions: `apex`, `flow`, `prompt`.

**What this means in practice:**
- The IDE diagnostic stream may surface additional internal schemes that work at runtime but are not part of the public Agent Script reference.
- For documented, supported, future-proof code, **use only `apex://`, `flow://`, and `prompt://` in your Agent Script files.**
- If the IDE suggests another scheme, treat it as undocumented. It may break in a future release.

The relevant chapters ([02. Technical Deep Dive](./02-technical-deep-dive.md), [12. Decision Matrix](./12-decision-matrix.md)) have been updated to reflect this. The IDE-derived list is retained as a "what you may see" note, with a clear distinction from the supported schemes.

### 2. Indentation convention is three spaces

**Earlier draft used:** 4-space indentation in `.agent` examples.

**Salesforce documentation says:** "The recommended convention is three spaces per indentation level."

**What this means in practice:** The DSL parses with any consistent space-based indentation, so 4-space examples will work. But for alignment with Salesforce's published examples, three spaces is the canonical choice. Templates have been updated to follow this convention.

### 3. Activation terminology

**Earlier draft used:** "Activation" as a single concept.

**Salesforce documentation distinguishes:** "Commit" (saves a snapshot of the current draft, locks it as a version) and "Activate" (promotes a committed version to be the active one).

In practice, the Builder UI surfaces both as part of one button (often "Save and Activate"). The distinction matters when scripting against Tooling API or when reading release notes.

### 4. Agent Script is the official name

**Earlier draft used:** "the .agent file" or "the DSL".

**Salesforce documentation calls it:** "Agent Script", a named language.

The guide retains "the .agent file" and ".agent DSL" because they are common community usage, but the [Glossary](./08-glossary.md) and key chapters reference "Agent Script" as the official name.

## Items most likely to change

These are the parts of the guide most exposed to Salesforce platform changes. Re-verify these specifically when you upgrade to a new release.

| Item | Why it can change | Where to verify |
|------|-------------------|-----------------|
| `AiAuthoringBundle` schema (fields, valid values) | New release adds fields | [Metadata API: AiAuthoringBundle](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm) |
| Agent Script target schemes | New action types may be added | [Actions reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-ref-actions.html) |
| `sf` CLI command flags | Behaviour changes per release | [CLI Release Notes](https://github.com/forcedotcom/cli/blob/main/releasenotes/README.md) |
| API version numbers in code samples | Salesforce releases v62, 63, 64, ... every few months | Use the current default in your project |
| Pricing model | Salesforce restructured pricing in Q3 2025; further changes possible | [Agentforce Pricing](https://www.salesforce.com/agentforce/pricing/) |
| Activation API support | Salesforce may eventually ship a deployable activation step | [Release Notes](https://help.salesforce.com/s/articleView?id=release-notes.salesforce_release_notes.htm) |
| Tooling API entity exposure | New tables surface, old ones gain or lose columns | [Tooling API reference](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/intro_api_tooling.htm) |

## How to re-verify

When you suspect a claim in the guide is out of date:

1. Check the official Salesforce documentation (linked in [REFERENCES.md](./REFERENCES.md)).
2. Check the most recent Release Notes for changes since this guide was last verified.
3. Test against a current scratch org if the change might be runtime behaviour.
4. Open an issue or PR with the finding. Cite the canonical source.

## Acknowledged uncertainty

A few items in the guide are based on community practice or the author's experience rather than official Salesforce documentation. They are flagged in the chapters where they appear:

- **Activation behaviour for new aiAuthoringBundle agents.** Salesforce has not (as of May 2026) shipped a clean public API for activation. The "click Activate in Builder" guidance is observational. If Salesforce ships an API, this guidance will need updating.
- **Specific token costs.** The Einstein Requests formula is documented, but per-conversation token consumption depends heavily on the agent's design. The cost guidance in [Chapter 17](./17-cost-optimization.md) is heuristic.
- **The IDE-extended target scheme list.** As noted above, only three schemes are publicly documented. The longer list comes from the IDE diagnostic stream and should be treated as informational, not authoritative.

When in doubt, prefer Salesforce's official documentation over this guide. This guide aims to be useful, but the platform is the source of truth.
