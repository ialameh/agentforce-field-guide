# Example 2. Flow action: create a follow-up task

When the agent should orchestrate a multi-step record update that admins might want to maintain without code, an auto-launched flow is the right tool. This example creates a follow-up `Task` for a contact, with sensible defaults filled in by the flow.

## Why a flow

- Admins can change the task subject, due date offset, and priority without involving developers.
- Multi-step record creation (a Task plus a related field update on the parent record) is declarative.
- No callouts needed.

## What you build

1. An auto-launched flow named `Create_Follow_Up_Task` with two input variables (`contactId`, `subject`) and one output (`taskId`).
2. A `GenAiFunction` of type `flow` that wraps the flow.
3. A permission set granting access.

## The agent action wrapper

```xml
<?xml version="1.0" encoding="UTF-8"?>
<GenAiFunction xmlns="http://soap.sforce.com/2006/04/metadata">
    <description>Creates a follow-up Task for a contact.</description>
    <developerName>Create_Follow_Up_Task</developerName>
    <invocationTarget>Create_Follow_Up_Task</invocationTarget>
    <invocationTargetType>flow</invocationTargetType>
    <isConfirmationRequired>true</isConfirmationRequired>
    <isIncludeInProgressIndicator>true</isIncludeInProgressIndicator>
    <localDeveloperName>Create_Follow_Up_Task</localDeveloperName>
    <masterLabel>Create Follow-Up Task</masterLabel>
    <progressIndicatorMessage>Creating the task</progressIndicatorMessage>
</GenAiFunction>
```

Note `isConfirmationRequired = true`. Creating records is a side effect; we want the user to confirm.

## The flow itself

The flow has:

- Two input variables: `contactId` (Text) and `subject` (Text).
- One output variable: `taskId` (Text).
- A "Get Records" element to fetch the Contact.
- A "Create Records" element that builds the Task with defaults (Priority Normal, Due Date today + 7 days, Status Not Started).
- An "Assignment" that sets `taskId` to the new record's id.

Build it in Flow Builder. Save. Activate. Then create the GenAiFunction wrapping it.

## Tips

- Use `isConfirmationRequired` on any flow that writes data.
- Add fault paths for missing or invalid inputs. The agent will pass through the fault message.
- Test the flow standalone in Flow Builder's debug mode before adding it to the agent.

## When you would prefer Apex

If the orchestration grows past three or four steps, or you need conditional logic that is hard to express in flow, port the logic to an Apex invocable. The agent does not care which backs the GenAiFunction.
