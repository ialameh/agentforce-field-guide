# Example 3. Prompt template action: draft a customer reply

When the agent should generate text in a controlled way (a draft email, a summary, a classification), a prompt template is the right tool. This example drafts a follow-up email to a customer based on the latest case activity.

## Why a prompt template

- The output is text that the user will review and possibly edit. Non-deterministic generation is acceptable.
- The prompt structure stays under your control. You decide what the LLM sees and what it produces.
- Cheaper to maintain than custom logic for most "draft something" use cases.

## What you build

1. A prompt template of type `Email Generation` (or similar, depending on Salesforce release) named `Draft_Customer_Reply`.
2. A `GenAiFunction` of type `prompt` wrapping the template.
3. A permission set granting access if the template is restricted.

## The prompt template

Two inputs:

- `Recipient` (Contact)
- `RelatedCase` (Case)

The body of the prompt template (using merge fields):

```
You are a professional customer service representative drafting a follow-up
email to {!Recipient.FirstName}.

The customer recently raised case {!RelatedCase.CaseNumber}, which is about:
{!RelatedCase.Subject}

Current status: {!RelatedCase.Status}.
Last update: {!RelatedCase.Description}

Draft a concise reply (under 150 words). Acknowledge the issue, summarise
the current status, and indicate what happens next. Do not invent details.
Use the customer's first name. Sign off with "The Acme Support Team".

Plain text only. No markdown, no emoji.
```

Notice the constraints baked into the prompt: word limit, format, banned content, signature.

## The agent action wrapper

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiFunction xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Drafts a follow-up email to a contact based on a related case. Returns the draft text.</description>
    <developerName>Draft_Customer_Reply</developerName>
    <invocationTarget>Draft_Customer_Reply</invocationTarget>
    <invocationTargetType>prompt</invocationTargetType>
    <isConfirmationRequired>false</isConfirmationRequired>
    <isIncludeInProgressIndicator>true</isIncludeInProgressIndicator>
    <localDeveloperName>Draft_Customer_Reply</localDeveloperName>
    <masterLabel>Draft Customer Reply</masterLabel>
    <progressIndicatorMessage>Drafting the reply</progressIndicatorMessage>
</GenAiFunction>
```

`isConfirmationRequired` is false. Drafting is read-only. The user can review the draft and decide whether to send.

## How the agent uses it

In a topic that handles "draft a reply to this case":

```yaml
reasoning:
    instructions: ->
        |Draft a reply to the customer about their case. Show the draft to the user
        |and ask if they want to edit or send it. Do not send it directly.
        |Run @actions.Draft_Customer_Reply with the relevant Contact and Case.
        |Show the result and pause for user input.
    actions:
        Draft_Customer_Reply: @actions.Draft_Customer_Reply
            with Recipient = @variables.currentContact
                 RelatedCase = @variables.currentCase
```

The agent invokes the action, gets the draft, shows it, and asks the user what to do next. A separate action (perhaps an Apex `Send_Email`) handles the send when the user approves.

## Tips for prompt template actions

- **Constrain everything.** Word limit, format, allowed content, signature, language. The LLM will ignore one of these unless you say it twice.
- **Do not let it invent.** Tell the prompt explicitly not to fabricate details.
- **Test with weird inputs.** Long case descriptions, missing fields, contacts with no first name, etc.
- **Treat the output as a draft.** Have the agent show it to the user before any downstream action uses it.

## When you would prefer Apex

If the text needs to be generated deterministically, or the same input must always produce the same output, do not use a prompt template. Use Apex with templated string interpolation, or a flow with a Formula.
