# Example 4. Apex action with callout: lookup external customer

When the agent needs data from an external system (an inventory service, a payment gateway, a reservation system), an Apex action with a callout is the right tool. This example looks up a customer in an external CRM via a Named Credential.

## Why this pattern

- The data lives outside Salesforce.
- The action needs to be synchronous from the agent's perspective. The user is waiting.
- The remote system is fast enough to fit in the per-action time budget. If it is not, see the async note at the bottom.

## What you build

1. A Named Credential pointing at the external API, with auth configured.
2. An Apex class with `callout=true` on the `@InvocableMethod`.
3. A `GenAiFunction` wrapping it.
4. A permission set granting class access and Named Credential access.

## The Named Credential

Configured in Setup. Stores the base URL and authentication for the external system. Use OAuth or API key, not a hard-coded secret.

```
Name: External_CRM
URL: https://api.external-crm.example.com
Identity Type: Named Principal
Authentication Protocol: OAuth 2.0
```

The Apex code references it as `callout:External_CRM/customers/{id}`.

## The Apex class

```apex
public with sharing class LookupExternalCustomer {

    public class ActionInput {
        @InvocableVariable(label='External Customer ID' required=true)
        public String external_id;
    }

    public class ActionOutput {
        public ActionOutput(String name, String email, Boolean isActive) {
            this.name = name;
            this.email = email;
            this.is_active = isActive;
        }
        @InvocableVariable public String name;
        @InvocableVariable public String email;
        @InvocableVariable public Boolean is_active;
    }

    @InvocableMethod(
        label='Lookup External Customer'
        description='Looks up a customer in the external CRM by id.'
        category='Integrations'
        callout=true
    )
    public static List<ActionOutput> execute(List<ActionInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new ActionException('No inputs provided.');
        }

        List<ActionOutput> outputs = new List<ActionOutput>();
        for (ActionInput input : inputs) {
            if (String.isBlank(input.external_id)) {
                throw new ActionException('external_id is required.');
            }

            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:External_CRM/customers/' + EncodingUtil.urlEncode(input.external_id, 'UTF-8'));
            req.setMethod('GET');
            req.setTimeout(8000);

            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() == 404) {
                throw new CustomerNotFoundException('Customer ' + input.external_id + ' not found.');
            }
            if (res.getStatusCode() >= 400) {
                throw new ActionException('External CRM error: ' + res.getStatus());
            }

            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            outputs.add(new ActionOutput(
                (String) body.get('name'),
                (String) body.get('email'),
                (Boolean) body.get('is_active')
            ));
        }
        return outputs;
    }

    public class ActionException extends Exception {}
    public class CustomerNotFoundException extends Exception {}
}
```

Note: `callout=true` is required for the platform to allow the callout from an invocable method. Without it, the action will fail at runtime.

## Permissions

Three things to grant the agent user:

1. The Apex class itself.
2. The Named Credential (External Credential and Principal).
3. Access to the response if you store any of it.

Permission set:

```xml
<classAccesses>
    <apexClass>LookupExternalCustomer</apexClass>
    <enabled>true</enabled>
</classAccesses>
<externalCredentialPrincipalAccesses>
    <externalCredentialPrincipal>External_CRM-Default</externalCredentialPrincipal>
    <enabled>true</enabled>
</externalCredentialPrincipalAccesses>
```

## Tips for callout actions

- **Set a tight timeout.** Eight seconds is generous for the agent. The Apex maximum is 120 but you cannot wait that long.
- **Handle 4xx separately from 5xx.** Different error paths help the agent recover.
- **Mock in tests.** The example tests would use `Test.setMock(HttpCalloutMock.class, new MockExternalCRM())`.
- **Watch the callout limit.** 100 per transaction is the hard cap, but each adds latency. Aim for one per action.

## When the remote is too slow

If the external system can take 10+ seconds to respond, the agent runtime will time out. The pattern then is asynchronous:

1. The action enqueues a `Queueable` that does the callout.
2. The action returns immediately with a job id and "started" status.
3. A follow-up action (or a Platform Event) tells the agent when the result is ready.

This adds a second turn to the conversation but keeps the agent responsive.

## When you would prefer External Service

External Services are declarative wrappers around REST APIs that surface as flow actions. Less code than a callout-aware Apex class. Suitable for simple GET and POST patterns where you do not need custom error handling.

For anything beyond simple, prefer Apex. You get full control of the request, response, and error paths.
