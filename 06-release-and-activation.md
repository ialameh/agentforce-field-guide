# 06. Release and Activation

This chapter covers the operational side: how to promote agents from one environment to another, what does and does not deploy as metadata, and how to set up a release runbook that survives the first time someone leaves the team.

## What deploys, what doesn't

A useful first step is to understand which artifacts are actually transportable as Salesforce metadata.

| Artifact | Deploys via metadata API? | Notes |
|----------|---------------------------|-------|
| Apex classes (the `@InvocableMethod`) | Yes | Standard `ApexClass` deployment. |
| Apex tests | Yes | Run by CI or by deploy options. |
| Flows | Yes | `Flow` metadata. |
| Prompt templates | Yes | `GenAiPromptTemplate` and friends. |
| `GenAiFunction` records | Yes | Retrievable as `genAiFunctions/...` source. |
| `AiAuthoringBundle` (the new agent format) | Yes | The `.agent` file plus `.bundle-meta.xml`. |
| Bot definitions (legacy) | Yes | `Bot` and `BotVersion` metadata. |
| Permission sets | Yes | Standard `PermissionSet`. |
| Permission set assignments | No | Has to be set up per environment, manually or via a custom script. |
| Agent activation status | No, currently | Has to be performed manually in each environment. |
| Conversational variable values that come from Salesforce data (e.g. `MessagingSession.EndUserId`) | Implicitly yes via the data they reference, no for the values themselves | The wiring is in source; the runtime values are produced at runtime. |

The two items that bite teams during release are activation and permission set assignments. Neither is deployable. Both have to be in your release runbook as explicit steps.

## A baseline release runbook

This is a template. Adapt it to your team's tooling.

### Pre-deploy

- [ ] All metadata committed and reviewed.
- [ ] CI green: Apex compile passes, tests pass with coverage above 75 percent, metadata validation passes against a designated scratch org.
- [ ] Source has been pulled from the source environment (sandbox where authoring happened, or scratch org if applicable). Confirm with `git status` that there are no uncommitted local changes.
- [ ] Deployment plan reviewed. List which sandboxes, in which order. Identify the highest-risk env (usually the one closest to production) and earmark it for extra eyes.

### Deploy

- [ ] Deploy to the next environment with `sf project deploy start -d <path> -o <ORG>`.
- [ ] Watch the deploy summary for component failures.
- [ ] Run any post-deploy Apex tests if not run during deploy.
- [ ] Verify the components you deployed are present in the target org (Setup or Tooling API queries).

### Post-deploy

- [ ] Assign permission sets to the target agent user (and any other relevant users).
- [ ] **Activate the agent.** Open Agentforce Builder for each agent and click Activate. This is the step everyone forgets. Make it loud in the runbook.
- [ ] Run a smoke test in test mode. Not just simulation.
- [ ] If applicable, run the canary suite (a set of representative prompts you have agreed represent the agent's behaviour).
- [ ] Document the change in your team's deployment log: what was deployed, when, who did it, what tests were run, what the outcome was.

### Rollback

If a release goes wrong, the rollback path depends on what failed:

- **Apex compile or test failure.** The deploy itself was rejected. The org is in its previous state. No rollback needed.
- **Agent runtime failure after activation.** Re-activate the previous version of the agent (the Builder retains a history of versions). Or deploy the previous source and re-activate.
- **Data corruption from a non-idempotent action.** This is why idempotency matters. Recovery is case-specific. Have a SOQL query that identifies affected records, and have a script to roll them back, before the action goes live.

## Why activation has to be manual

For the new `aiAuthoringBundle` format, activation is currently not exposed as a deployable step. The reason is that activation involves more than just flipping a flag: it materialises the agent's authoring state (with its current set of linked functions, variables, and topics) into the runtime registry. Salesforce wants this to be an explicit decision, not a side effect of deployment.

The implication for your team is that activation has to be in your runbook. It cannot be in your CI script. Several teams have built post-deploy scripts that use the Salesforce CLI's `sf data record update` and a small JavaScript helper to flip the relevant records, but this is undocumented and fragile. Treat it as a manual step until Salesforce ships first-class activation deployment.

## Cross-environment naming

A subtle but real issue: your sandbox might be on namespace `lumin`, your production might be on `lumin`, but your developer scratch org might be on namespace `mypackage`. The `.agent` DSL stores the activation-time namespace inside its target URIs.

The result is that source you authored against scratch org A may not deploy cleanly to org B because the `target:` URI hard-codes the wrong namespace.

Mitigations:

- Standardise scratch org namespaces. Match production.
- If you must use a different scratch namespace, use a search-and-replace step in CI to translate the namespace before deployment.
- Prefer `GenAiFunction` records over inline `apex://...` targets where possible. The function's resolution is more namespace-friendly than the inline form.

## CI/CD considerations

A typical CI/CD pipeline for an Agentforce project looks like:

1. **On pull request:** lint, compile, test, validate metadata against a scratch org. No deploy to anywhere durable.
2. **On merge to main:** deploy to the integration sandbox, run a smoke test, alert on failure.
3. **On release tag:** deploy to QA, then UAT, then production, with a manual approval gate between stages. A human activates the agent in each environment.

The manual approval gate at each stage exists for a reason. The runtime behaviour of an agent is not fully verifiable via automation. A human running a few representative prompts catches things the automation cannot.

## Per-environment configuration

Some things vary between environments and should be parameterised:

- The agent user's username (it tends to be different in each org).
- The default agent user assigned in `default_agent_user:` in the `.agent` file. Either keep this as a placeholder and substitute at deploy time, or accept that it has to be manually set per environment.
- Named credential URLs and secrets.
- Any configuration sObjects that hold per-environment values.

A lightweight pattern: use a simple template substitution step in CI. Read the environment's variables from a secret store, run them through `envsubst` or a similar tool over the source files, then deploy.

## Audit and observability

Once the agent is in production, you will want to know:

- How often each action is invoked.
- How often each action fails.
- The latency distribution per action.
- Which conversation paths most often lead to a failed action.

Salesforce ships some of this in Agentforce Studio's analytics, but the coverage is uneven. Your monitoring will likely be a mix of:

- Platform Event records emitted from inside the Apex method (recommended).
- Custom log records (a `Log__c` object) updated from the method.
- LimitsServiceManager telemetry if you are on the relevant license.
- Salesforce's native debug logs as a backup.

Decide on the monitoring before the first agent ships. Adding it later is harder than getting it right the first time.

## Release-day checklist

Print this and tape it to the wall.

- [ ] Source is in main and tagged.
- [ ] CI is green.
- [ ] Deployments to the lower environments succeeded and were tested.
- [ ] The release window is announced to stakeholders.
- [ ] The runbook is open and ready.
- [ ] You have time to roll back if something goes wrong.
- [ ] You know who to call if you need help.

The most common cause of a bad release is rushing the last step.

## References

- [Agent Metadata DX guide](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-metadata.html)
- [`AiAuthoringBundle` metadata type](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_aiauthoringbundle.htm)
- [Bot and BotVersion (legacy)](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_bot.htm)
- [`sf` CLI reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm)
- [Salesforce DevOps Center](https://help.salesforce.com/s/articleView?id=sf.devops_center_overview.htm)
