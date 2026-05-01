# 19. Designing Agents and Subagents

This is the chapter on how to think before you build. Most agent failures start as design mistakes that get harder to fix once code exists. An hour of design thinking up front saves a week of rework later. The first part of this chapter covers the thinking process. The second part covers what to do and what not to do, in concrete terms.

## The thinking process

### Step 1. Write the agent's purpose in one sentence

Force yourself to write one sentence. Not a paragraph. Not three sentences. One.

Good purpose statements:

- "Helps customers check the status of their orders and request returns."
- "Helps internal sales reps draft personalised outreach emails based on account context."
- "Helps support engineers triage incoming cases and route them to the right specialist."

Bad purpose statements:

- "An AI assistant that helps users with anything they need." (too broad)
- "Acts as a knowledgeable, friendly representative of our brand to delight customers and increase conversion." (marketing copy, not behaviour)
- "Answers questions, performs lookups, sends emails, schedules meetings, books rooms, ..." (a list, not a purpose)

If you cannot get to one sentence, you probably have two agents stuck together. Split them.

### Step 2. Identify the audience

Who is talking to this agent?

- Are they internal employees or external customers?
- What is their level of trust in the system?
- What is their level of patience for things going wrong?
- What language do they speak? What tone do they expect?

Audience drives persona, tone, error handling, escalation paths. A grumpy customer who has been on hold expects different handling than a sales rep doing administrative work.

### Step 3. List the things the agent should be able to do

A bullet list. Concrete actions. What the user can ask the agent to do, and what the agent will respond.

For each item, ask:

- Is this a single action, or a multi-step flow?
- What inputs does it need from the user?
- What does success look like?
- What does failure look like, and how does the agent recover?

### Step 4. List the things the agent should not do

This is the step everyone skips. It is at least as important as step 3.

- "Should not give medical advice."
- "Should not commit to specific delivery dates."
- "Should not discuss pricing for products the user is not authorised to see."
- "Should not generate code on behalf of the user."

Out-of-scope behaviours leak into agents through hopeful interpretations. The LLM will try to be helpful. Boundaries have to be explicit.

### Step 5. Decide the persona

A short description of how the agent presents itself.

- Tone (formal, casual, warm, neutral).
- Voice (active, helpful, terse, verbose).
- Identity (does it have a name? does it acknowledge being an AI?).
- Boundaries (when does it apologise? when does it escalate?).

A persona is constraint. Without it, the LLM defaults to a generic "helpful assistant" voice that drifts over time and feels off-brand.

### Step 6. Map the conversation shape

Sketch the conversation. Even a rough one.

- What does the agent say first?
- What information does it gather?
- When does it invoke an action?
- How does it confirm success or report failure?
- When does it hand off to a human?

This sketch tells you whether you have one topic, several topics, or different subagents. See [Chapter 14](./14-conversation-design.md).

### Step 7. Identify the actions

For each thing the agent should do, decide:

- Is this an existing action, or do I need to build one?
- What type? (Apex, flow, prompt, external, standard. See [Chapter 12](./12-decision-matrix.md).)
- What is the action's input and output schema?
- Are there preconditions to running it?
- Is it idempotent? Can it be safely retried?

This is also when you discover that "the agent should send an email" is one action but "the agent should draft, review, and send an email" is three.

### Step 8. Identify the variables

Conversation state. What does the agent need to remember between turns?

- User identity, if it persists across the session.
- Authentication state.
- Current step in a multi-step flow.
- Last error message.
- Anything the LLM should be able to see across topics.

Less is more here. Variables that exist but are not used add tokens to every turn.

### Step 9. Plan the failure modes

For each thing the agent does, what can go wrong?

- The action itself fails.
- The user provides invalid input.
- The user changes their mind mid-flow.
- The agent picks the wrong action.
- The conversation goes off-script.

For each failure mode, write what the agent should do. "Apologise and escalate" is fine for some. "Ask for clarification" is right for others. Don't leave failure handling to the LLM's improvisation.

### Step 10. Decide what success looks like

Before you build, decide how you will know the agent is working.

- What metrics?
- What thresholds?
- Who reviews the conversations?
- Who decides when the agent is "good enough"?

Without explicit success criteria, agents tend to ship "when the demo works", which is rarely a real bar.

## When to use a subagent versus a topic

This is the most common design question. The mental test:

**Use a topic when**: the conversation is the same agent doing different things. Same persona, same audience, same trust boundary.

**Use a subagent when**: the conversation is genuinely a different role, persona, or audience.

A few examples:

| Scenario | Decision |
|----------|----------|
| Customer service agent that handles orders, refunds, and shipping questions | Three topics. Same persona. |
| Sales agent that hands off to a support specialist mid-conversation | Two subagents. Different roles. |
| Internal IT agent that routes between password reset, software install, and access requests | Three topics. Same role, different intents. |
| Public-facing agent that escalates to a human-in-the-loop for sensitive cases | One agent with an escalation path. The human is not a subagent; they are an external actor. |
| Bilingual agent with different actions per language | Probably one agent with language-aware actions, not a subagent per language. |

The default should be "one agent, one or several topics". Reach for subagents only when the test above genuinely says "different role". A common smell: five subagents that share most of their context. That is one agent with five topics, dressed up.

## What to do

### Start small

Build the simplest possible version of the agent first. One topic, one or two actions, the core conversation. Get it working end-to-end. Then add.

Big agents grown out of small ones tend to be coherent. Big agents designed all at once tend to have parts that do not quite fit.

### Constrain the LLM

Tell the LLM what to do, what not to do, when to invoke each action, when to ask for clarification, when to escalate. The more explicit, the more reliable. Free-form "you are a helpful assistant" instructions produce free-form behaviour.

### Author for the platform

Use linked variables for platform context (messaging session, contact, user). Use the platform's standard actions where they fit. Use Salesforce's permission model. Don't fight the platform.

### Write conversation copy out loud

The replies the agent generates have to feel right when read aloud. Read them. If they sound stiff or off-brand, edit the instructions until the LLM produces what you want.

### Plan for the first production incident

There will be one. The agent will say something it shouldn't, or do something the user did not ask. Have a way to:

- Detect it (observability, see [Chapter 11](./11-observability.md)).
- Investigate it (action invocation logs, conversation history).
- Roll it back (version history, source control).
- Communicate about it (incident response process).

Build all of this before launch.

### Use confirmations liberally on irreversible actions

`isConfirmationRequired: true` is a small UX cost for a large reduction in misfires. Use it for sending email, charging, deleting, anything that the user might regret. Don't use it on read-only actions.

### Get a human reviewer

A non-developer should review the conversation flow before launch. Ideally someone from the agent's audience. They will spot things the developer cannot.

## What not to do

### Don't build "an agent that does everything"

The temptation is real. A single agent that handles ordering, support, sales, billing, and HR. It will be harder to maintain than five focused agents and will perform worse on each task than dedicated agents would.

Smaller, focused agents win.

### Don't rely on the LLM to "figure it out"

If the agent has no instructions about what to do when an action fails, the LLM will improvise. The improvisation will sometimes be wrong. Spell out the failure handling.

### Don't use the LLM as a calculator

If the action involves arithmetic, business rules, or anything where exactness matters, do it in Apex or a flow. The LLM is creative; creativity is wrong here.

### Don't put production secrets in the agent's context

Tokens, API keys, internal IDs that the LLM should not be able to leak. Tag them with `filter_from_agent: True` or keep them out of the variables block entirely.

### Don't ship without monitoring

Shipping an agent without observability is shipping it blind. You will not know if it is working. You will not know if it is getting worse. By the time someone complains, the data needed to investigate is gone.

### Don't ignore the activation step

This is the single most common operational mistake. Activate after every change. See [Chapter 6](./06-release-and-activation.md).

### Don't write marketing copy in action descriptions

The action description is read by the LLM, not by the user. It should describe the action's behaviour in 200 characters or less. Bloated descriptions waste tokens on every turn.

### Don't accept a passing simulation as proof of correctness

Test mode is the truth. Simulation can pass while test fails. See [Chapter 7](./06-release-and-activation.md).

### Don't skip the design step

The temptation to "just start building and see what happens" is strong. Resist. An hour of design saves a week of rework. Even a back-of-napkin design beats no design.

### Don't change the agent without telling people

Activation in production has user-visible consequences. The conversation might behave differently. Customers might notice. Communicate the change before pressing the button.

## A useful design template

For each new agent, write a one-page document covering:

1. **Purpose.** One sentence.
2. **Audience.** Who, internal/external, trust level, language, expectations.
3. **Persona.** Tone, voice, identity, boundaries.
4. **Topics.** List with one-sentence descriptions each.
5. **Subagents (if any).** Justify why a topic was not enough.
6. **Actions.** List by type, with input/output sketch and ownership.
7. **Variables.** List with type and purpose.
8. **Failure modes.** List with handling per mode.
9. **Escalation path.** How does a stuck conversation get to a human.
10. **Success criteria.** Metrics, thresholds, reviewers.

This document is the source of truth for what the agent is supposed to do. Update it as the agent evolves. New team members read it before touching the agent.

## A common evolution pattern

Most agents grow in this rough sequence:

1. Single topic, two or three actions. The minimum viable agent.
2. The same topic gains more actions as features accumulate. Five, then eight.
3. The topic gets crowded. Token costs creep up, the LLM occasionally picks wrong.
4. Split into two or three topics by intent. Cost drops, accuracy improves.
5. A new audience appears (internal vs external, sales vs support). Introduce a subagent for the new role.
6. The router gets more sophisticated. The number of subagents stabilises.
7. Steady state. Maintenance, not growth.

Don't try to skip steps. Each step is a learning that informs the next. Building step 6 from scratch on day one usually produces a worse version than evolving into it.

## When you are stuck

If you cannot decide between two designs, build the simpler one. You can always make it more complex later. Going the other direction is harder.

If you cannot articulate what the agent is for, talk to a user. One conversation with someone who actually needs this is worth ten internal design meetings.

If the design feels too big, it probably is. Pick one part and ship it. Iterate.

## References

- [Agentforce Builder (Trailhead)](https://trailhead.salesforce.com/content/learn/modules/new-agentforce-builder-quick-look/explore-the-new-agentforce-builder)
- [Agent Script reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-reference.html)
- [Agentforce: Get Started](https://developer.salesforce.com/docs/einstein/genai/guide/get-started-agents.html)
- [Salesforce Architect resources](https://architect.salesforce.com/)
