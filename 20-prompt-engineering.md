# 20. Prompt Engineering for Agentforce

The LLM is the most powerful and the least predictable component in your agent. The quality of its behaviour depends heavily on what you tell it. This chapter covers the practical writing skills that turn a "kind of works" agent into one that behaves reliably.

The chapter is opinionated. Different teams find different things work for them. Treat this as a starting set you can refine.

## What you are actually writing

Several distinct pieces of text feed the LLM on every turn. Each has a different purpose and a different audience.

| Piece | Audience | Updated when | Tokens |
|-------|----------|--------------|--------|
| System prompt | LLM, every turn | Rarely. Set once at agent level. | High (always sent). |
| Topic instructions | LLM, when in this topic | Per release. | Medium (sent only for active topic). |
| Action descriptions | LLM, when this action is in scope | When the action changes. | Medium (one per scoped action). |
| Action input descriptions | LLM, when filling action inputs | When the input meaning changes. | Low. |
| Conversation history | LLM, every turn | Every turn. | Grows over time. |
| User message | LLM, every turn | Every turn. | User-controlled. |
| Reply | User | The LLM writes it. | User-visible. |

The pieces you write directly are the system prompt, topic instructions, action descriptions, and input descriptions. The LLM writes the reply. The runtime manages history and the user message.

## The five rules

### 1. Be specific, not aspirational

The LLM reads "be helpful" as "do something helpful". It reads "if the user asks for an order status, run the Get_Order_Status action with their order_id" as a clear instruction. The second produces reliable behaviour. The first does not.

Aspirational: "You are a friendly customer service agent who delights customers."

Specific: "Greet the user. Ask for their order number if they don't provide one. Run Get_Order_Status. If the order is shipped, give the tracking link. If not shipped, give the expected ship date. Reply in plain text under 80 words."

The specific version is harder to write. It also produces vastly more reliable behaviour.

### 2. State what to do AND what not to do

The LLM is creative. Telling it what to do leaves a lot of room. Telling it what not to do shrinks the room.

Examples:

- "Use plain text. Do not use markdown, do not use emoji, do not use bold or italics."
- "Reply in English unless the user writes in Spanish, in which case reply in Spanish. Never mix languages in one reply."
- "If the user asks about pricing, run Get_Price. Do not invent prices. Do not estimate. Do not guess."
- "Respond in three sentences or fewer. Do not list bullet points unless the user explicitly asks for a list."

Negation is unfashionable in writing. It is essential in prompts.

### 3. Show, don't tell

When the LLM is unsure how to handle a case, examples help more than abstract instructions. Include one or two concrete examples in the topic instructions:

```
If the user asks "Where's my order?", reply like this:

User: Where's my order?
Assistant: I can help with that. What's your order number?
User: ORD-1234
Assistant: [runs Get_Order_Status, then] Order ORD-1234 shipped on
February 12. Tracking: https://tracking.example.com/ORD-1234.
```

Examples ground the LLM. They also give you a stable behaviour to test against.

### 4. Constrain the format

LLMs default to verbose, markdown-rich, bullet-listed replies. That is rarely what you want.

Format instructions worth using:

- "Reply in plain text. No markdown, no formatting symbols, no emoji."
- "Reply in fewer than 100 words."
- "Reply with two sentences: a confirmation, then the next step."
- "Reply with the result and nothing else. No preamble, no commentary."

The LLM will obey if you say so. It will improvise if you don't.

### 5. Test against ambiguity

Real users say weird things. "Order or whatever". "the thing from last week". "you know what i mean lol". The LLM's behaviour on these inputs is where things go wrong.

For each topic, write a short list of "weird inputs" and trace through what should happen:

- User says nothing useful: ask a clarifying question.
- User asks for something out of scope: explain politely, offer alternatives.
- User is angry: acknowledge, offer to escalate.
- User mixes intents: handle one, ask about the other.

Encode these into the topic instructions. The LLM will then handle them consistently.

## The system prompt

The system prompt sets the agent's overall identity and the rules that apply across topics.

A good system prompt:

- Names the agent (or describes what role it plays).
- Sets the tone.
- Lists the absolute rules (things that should never happen).
- Provides minimal context about the broader system.

Example:

```
You are AcmeBot, a customer service agent for Acme Industries. You help
customers check orders, request returns, and track shipments. You do not
discuss pricing for products the customer is not asking about. You do
not give legal, medical, or financial advice. You reply in plain text,
under 100 words, in a friendly but professional tone. When you need to
take action, use one of the available actions. When unsure, ask.
```

A bad system prompt:

- Tries to cover every edge case (gets too long).
- Is full of marketing language (wastes tokens).
- Restates the obvious (the LLM already knows it is an AI).
- Leaks implementation details (action names, internal jargon).

Set the system prompt once. Audit it whenever you add a new topic.

## Topic instructions

Topic instructions are where most of your design intent ends up. Each topic should have its own clear instructions covering:

1. **When to enter this topic.** What user intents trigger it.
2. **What information to gather.** Inputs the actions need.
3. **What actions to run, in what order.** Concrete action invocations.
4. **What to do on success.** How to confirm to the user.
5. **What to do on failure.** Error handling and escalation.
6. **Format constraints.** Length, tone, style.

A useful template:

```
This topic handles ORDER STATUS lookups.

Enter this topic when the user asks about an order, mentions an order
number, or asks where their delivery is.

Gather the order number from the user's message. If not provided, ask
"What's your order number?" before doing anything else.

Run @actions.Get_Order_Status with the order number.

If the action returns a shipped order, reply with the status and
tracking link. If pending, give the expected ship date. If not found,
apologise and offer to escalate.

Reply in plain text, under 60 words, friendly but professional. Do not
use markdown.

If the user is angry or has tried more than twice, transition to
@subagent.escalation.
```

Long? Yes. Reliable? Also yes. The trade-off is worth it.

## Action descriptions

The action description is the single sentence that tells the LLM what an action does and when to use it. It is read on every turn that the action is in scope.

Good action descriptions:

- Are under 200 characters.
- Describe what the action does in present tense.
- Mention any side effects ("sends an email", "creates a record").
- Mention any preconditions ("requires the user to be authenticated").

Bad action descriptions:

- Repeat the action name ("This is the GetOrderStatus action that gets order status").
- Include marketing copy ("Our amazing order status action delivers...").
- Describe the implementation ("Calls the GetOrderInfo class which queries...").
- Are vague ("Helps with orders").

Examples:

- Good: "Returns the current status of an order, including ship date and tracking number. Requires order_id."
- Bad: "Get order. Lookup. Returns information about orders for users."

The LLM picks actions based largely on these descriptions. Treat them as code, not as documentation.

## Input and output descriptions

Each input and output to an action also has a description. The LLM uses input descriptions to figure out what to put in. It uses output descriptions to figure out what to do with what comes back.

Good input description:

- "The user's order number, in the format ORD-XXXX where XXXX is digits."

Bad input description:

- "Order number." (no format guidance)
- "An order number that the user provides which corresponds to an order in our system." (verbose, no new information)

Good output description:

- "Boolean. True if the order has shipped, false otherwise."

Bad output description:

- "Status." (vague)
- "A boolean value that represents whether or not the order has shipped." (verbose)

## Prompt templates as actions

Some actions are prompt templates: the action invokes the LLM with a specific prompt to generate something. These are powerful but easy to misuse.

Use prompt templates for:

- Drafting text the user will edit (welcome emails, follow-ups, summaries).
- Classifying free-form text into a category.
- Extracting structured data from unstructured input.
- Translating, summarising, paraphrasing.

Don't use prompt templates for:

- Anything where exactness matters (calculations, dates, prices).
- Decisions that affect downstream actions (let deterministic logic decide).
- Anything you cannot easily verify after the fact.

The discipline: prompt templates produce text. Apex actions produce truth. Use the right tool for each.

## Anti-patterns in prompt writing

### The mega-prompt

A 2000-word system prompt that tries to cover every conceivable case. The LLM will pick three things from it and ignore the rest. Trim it.

### The nested instruction

"If the user asks about X, then if they also mention Y, then unless Z, do A, otherwise B." The LLM will get this wrong sometimes. Flatten the logic. Move the conditionals into Apex if they need to be reliable.

### The polite preamble

"Please be aware that..." "It would be appreciated if..." "Note that..." All of these are tokens spent on courtesy the LLM does not need. Be direct.

### The implementation leak

"Use the GetOrderStatus class which calls the @InvocableMethod annotated method..." Internal implementation does not belong in the prompt. The LLM cares about behaviour, not implementation.

### The hopeful generalisation

"Handle any other questions appropriately." This is the exit clause that produces unpredictable behaviour. Either spell out what "appropriate" means, or have the agent escalate.

### The hidden assumption

"The user will provide their order number." Real users do not. Spell out the case where they do not.

## Iterating on prompts

Prompt engineering is empirical. Write a prompt, run it through several conversations, see what goes wrong, refine.

A useful workflow:

1. Write the first version. Test it on the happy path.
2. Add three weird inputs. Test those. Adjust the prompt.
3. Add three adversarial inputs (prompt injection attempts). Test those.
4. Lock in the prompt as a baseline.
5. When the agent misbehaves in production, capture the input and add it to your test set. Adjust the prompt. Run all the tests again.

Over time, the prompt accumulates the wisdom of every conversation that went wrong. It also gets longer. Periodically refactor. Drop instructions that no longer apply.

## A reasonable budget

Some rough targets to keep cost under control:

- System prompt: 100 to 200 words.
- Topic instructions: 100 to 300 words each.
- Action descriptions: under 200 characters each.
- Input and output descriptions: under 100 characters each.

These are not hard limits. They are signals. A topic instruction at 800 words probably has redundancy or hopeful generalisation. A system prompt at 400 words is probably trying to do the work of topic instructions.

## The quality test

After writing or editing a prompt, ask:

- Could a new team member read this and predict what the agent will do?
- Are there clear instructions for failure cases?
- Does it tell the LLM what not to do, not just what to do?
- Are the format constraints explicit?
- Is there an example for each non-obvious behaviour?
- Could it be shorter without losing meaning?

If the answer to any of these is "no", revise.

## When prompts are not enough

Sometimes the right answer is not a better prompt. It is more deterministic logic.

If you find yourself writing instructions like:

- "Always check that the value is between 1 and 100."
- "Make sure the date is in the future."
- "Verify the email contains an @ sign."

Push that logic into Apex. Validate at the action boundary. Throw clear exceptions. The LLM will not consistently enforce these rules; the platform will.

The prompt is for guiding behaviour. It is not for enforcing constraints.

## References

- [Agent Script: Reasoning instructions](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-reference.html)
- [Prompt Builder (`GenAiPromptTemplate`)](https://help.salesforce.com/s/articleView?id=sf.prompt_builder_about.htm)
- [Prompt template metadata](https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_genaiprompttemplate.htm)
- [Agent Script Decoded blog](https://developer.salesforce.com/blogs/2026/02/agent-script-decoded-intro-to-agent-script-language-fundamentals)
- [OWASP LLM Top 10 (prompt injection)](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
