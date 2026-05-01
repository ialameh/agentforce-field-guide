# 03. Naming and Namespaces

This is the chapter most teams realise they needed only after they have wasted half a day on an error message that says "We couldn't find the flow, prompt, or apex class". The rules are not hard. The rules are also not consistent.

## Three notations for one class

Salesforce refers to a single class by three different forms depending on context. Knowing which is which prevents most resolution errors.

| Where you see it | Form | Example |
|------------------|------|---------|
| Apex source code | `<ns>.<localName>` | `lumin.AdminSetupController` |
| Metadata files (`*.flow`, `*.layout-meta.xml`, `*.agent`) | `<ns>__<localName>` | `lumin__AdminSetupController` |
| REST API URLs | `<ns>__<localName>` | `lumin__AdminSetupController` |
| Tooling API `ApexClass.Name` column | bare local name | `AdminSetupController` (with `NamespacePrefix = lumin` in a separate column) |
| Tooling API queries that filter by namespace | bare in `Name`, prefix in `NamespacePrefix` | `WHERE Name = 'AdminSetupController' AND NamespacePrefix = 'lumin'` |
| `GenAiFunction.invocationTarget` | bare local name | `AdminSetupController` (resolved within the function's own namespace) |

The double underscore is two underscores, not a single. It is also not the same as the underscore in plain identifiers. If you copy something out of Apex source into a metadata file with a single dot, the deploy will reject it. If you copy something out of a metadata file into Apex source with a double underscore, the compiler will complain.

## When to prefix

| Situation | Prefix? |
|-----------|---------|
| Apex source code, same namespace | No. The compiler resolves automatically. |
| Apex source code, different namespace | Yes, with a dot. The other namespace's class must also be `global` or you cannot see it. |
| Metadata file API name reference | Yes, with double underscores. |
| REST URL | Yes, with double underscores. |
| `.agent` DSL `target:` URI | Yes, with double underscores. `apex://lumin__AdminSetupInvocable`. |
| `GenAiFunction.invocationTarget` field | No, when the function lives in the same namespace as the target. |
| Custom field reference in a metadata file | Yes for namespaced fields, no for default-namespace fields. `lumin__Status__c` versus `Status__c`. |

## Cross-namespace visibility

Code from outside namespace A cannot see code inside namespace A unless that code is `global`. This applies even to classes you wrote yourself, if you happen to be deploying them through a packaged context.

Quick rules:

- A class declared `public with sharing class` is **invisible** outside its own namespace.
- A class declared `global with sharing class` is **visible** outside, but only for the methods that are themselves marked `global`.
- A method declared `public static` is invisible. `global static` is visible.

The implication for Agentforce is mostly relevant when packaging. Inside a single org, where every class is in the same namespace, you do not have to think about it. The moment you start working with managed packages or moving code between orgs with different namespaces, the visibility rules become load-bearing.

## Scratch orgs with their own namespace

A scratch org that has `namespacePrefix: lumin` in its definition file behaves as if the entire org has been packaged. Every class you deploy lands in the `lumin` namespace, regardless of the surrounding `sfdx-project.json`.

This is convenient for development against a specific package's namespace, but it has a few sharp edges:

- The `sfdx-project.json` "namespace" field does not have to match the scratch org's namespace for retrieve and deploy to work. They are not coupled by the CLI.
- The `sfdx-project.json` namespace **does** matter when creating new scratch orgs (it becomes the default for new orgs) and when packaging.
- If you want to switch the org's namespace later, you cannot. You have to spin up a new scratch org with the new namespace.

A common gotcha: someone retrieves source from a namespaced scratch org into a project with no namespace, then tries to deploy that source into a default-namespace org. The deploy fails because the target org has no `lumin` namespace to hold the code. Either change the destination, or remove the namespace prefix from references before deploying.

## Confirming what you are looking at

A few quick commands to remove ambiguity:

```bash
# Org's own namespace
sf data query -o <ORG> -q "SELECT NamespacePrefix FROM Organization"

# A class's namespace and source-of-truth state
sf data query -o <ORG> --use-tooling-api \
  -q "SELECT Name, NamespacePrefix, ManageableState, IsValid \
      FROM ApexClass WHERE Name = '<ClassName>'"

# Project's declared namespace
grep namespace sfdx-project.json
```

The `ManageableState` column tells you who owns the source of truth:

| Value | Meaning |
|-------|---------|
| `unmanaged` | Source-of-truth is in this org or in a connected source repo. Editable. |
| `installed` | Came from a managed package. Read-only. The package publisher controls the source. |
| `installedEditable` | Came from an unlocked package, but the org is allowed to edit. |
| `released` | A managed package version that has been published to the App Exchange. |

If the column reads `installed`, do not try to edit. Do not try to redeploy a local copy. Either ask the package publisher to update, or build a wrapper class in your own namespace that calls the global parts of the installed code.

## Custom field naming

The same rules apply to custom fields, with the wrinkle that custom fields always end in `__c`:

- `Status__c` is a default-namespace custom field on a default-namespace object.
- `lumin__Status__c` is a custom field that came from the `lumin` namespace.
- `Account.lumin__Status__c` is the namespaced field on a standard object.
- `lumin__Customer__c.Status__c` is a default-namespace field on a namespaced custom object.

There are projects that have wasted real money on confused references. The naming is precise, just verbose.

## Quick reference for "what should I write?"

- Writing an Apex class that calls another class in the same package: bare name, no prefix.
- Writing a metadata file (`*.flow`, `*.layout-meta.xml`, `*.agent`, etc.): full API name with double underscores when the target is namespaced.
- Calling a REST endpoint: full API name with double underscores.
- Querying SOQL: bare in `Name`, prefix in `NamespacePrefix`.
- Setting `invocationTarget` on a `GenAiFunction` in your namespace: bare. The platform fills in the namespace from the function's own.
- Setting `invocationTarget` on a `GenAiFunction` that should call a different namespace's class: prefixed. And the target class must be `global`.

When in doubt, prefer the prefixed form. It is verbose but it never resolves to the wrong thing.

## References

- [Salesforce namespaces overview](https://developer.salesforce.com/docs/atlas.en-us.pkg2_dev.meta/pkg2_dev/sfdx_dev2gp_create_namespace.htm)
- [Managed package access modifiers](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_modifiers.htm)
- [Tooling API: `ApexClass`](https://developer.salesforce.com/docs/atlas.en-us.api_tooling.meta/api_tooling/tooling_api_objects_apexclass.htm)
- [Salesforce DX project file format](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm)
