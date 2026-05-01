# Changelog

All notable changes to the Agentforce Field Guide are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com), and the project tries to follow [Semantic Versioning](https://semver.org).

## Unreleased

### Added

Nothing yet.

## v0.3.0

### Added

- `REFERENCES.md`: full canonical index of Salesforce documentation linked from the guide, organised by topic.
- `VERIFICATION.md`: verification status, last-checked date, what was confirmed, what was corrected, and items most likely to change between Salesforce releases.
- `## References` section at the end of every chapter, linking to the canonical Salesforce docs that back its claims.

### Changed

- Chapter 02 (Technical Deep Dive in `docs/agentforce/`) clarifies that only `apex://`, `flow://`, and `prompt://` are documented Agent Script target schemes. The longer IDE-derived list is now flagged as runtime-internal.
- Chapter 05 (Troubleshooting): error message reference for "invalid attribute value for 'target'" now points at the documented schemes.
- README: surfaces verification status, links to REFERENCES.md and VERIFICATION.md.

### Verified against

Salesforce Spring '26 (API v65 and v66), May 2026.

## v0.2.0

### Added

- Chapter 0, Quickstart: 15-minute walkthrough of building a "Greet User" agent action end-to-end.
- Chapter 9, Security: threat model, six top threats, defence-in-depth patterns, compliance notes.
- Chapter 10, Testing: testing pyramid, unit / contract / integration / conversation eval layers.
- Chapter 11, Observability: signals, sinks, dashboards, alerts, conversation provenance.
- Chapter 12, Decision Matrix: when to use Apex / Flow / Prompt / External / Standard actions.
- Chapter 13, Performance and Limits: per-action time budget, governor limits, async patterns.
- Chapter 14, Conversation Design: four common patterns, when to use a subagent vs a topic.
- Chapter 15, FAQ: scannable Q&A covering the questions teams ask most often.
- Chapter 16, Migration Guides: legacy bots to aiAuthoringBundle, prompt-only to action-driven.
- Chapter 17, Cost Optimization: where the tokens go, four levers, caching strategies.
- Chapter 18, CI/CD Recipes: GitHub Actions, GitLab CI, Bitbucket Pipelines configs.
- Chapter 19, Designing Agents and Subagents: full thinking process, what to do, what not to do.
- Chapter 20, Prompt Engineering: writing system prompts, topic instructions, action descriptions.
- `templates/` folder with skeletons for `.agent`, `GenAiFunction`, schemas, Apex, permission set, scratch org definition, and package manifest.
- `cookbook/` folder with four worked examples: Apex action, flow action, prompt template action, action with callout.
- `case-studies/` folder with the first anonymised case study: "Action name not found".
- New SVG diagrams: decision matrix, security threat model, testing pyramid, observability architecture, CI/CD pipeline, governor limits, conversation design patterns, cost flow, quickstart architecture.
- Repository scaffolding: LICENSE (CC BY 4.0), CONTRIBUTING.md, CODE_OF_CONDUCT.md, this changelog.

### Changed

- README updated to reflect the expanded structure.

## v0.1.0

### Added

Initial release of the field guide, derived from a real production incident.

- Chapter 1, The Mental Model: five-layer architecture, two state machines.
- Chapter 2, Starting Checklist: pre-flight checklist for new agent actions.
- Chapter 3, Naming and Namespaces: three notations for one class.
- Chapter 4, Development Loop: UI vs source seam, retrieve discipline.
- Chapter 5, Troubleshooting: layered probes for symptom-driven diagnosis.
- Chapter 6, Release and Activation: deploy-vs-not table, runbook template.
- Chapter 7, Anti-Patterns and Pitfalls: 14 common mistakes.
- Chapter 8, Glossary and References: A-Z terms, quick command reference.
- SVG diagrams: five layers, authoring vs runtime, runtime call sequence, triage decision tree, four runtime contexts.
