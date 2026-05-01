# Case Studies

Real incidents from real projects, anonymised. Each one has the same structure: what broke, what we thought was wrong, what was actually wrong, what we did, what we learned.

The point of these is not to embarrass anyone. The point is that the same mistakes happen everywhere, and reading about how someone else got out of them is faster than rediscovering the lessons yourself.

## Cases

| # | Case | Time to resolve | What we learned |
|---|------|-----------------|-----------------|
| [01](./01-action-name-not-found.md) | "Action name not found" with everything seemingly correct | About 2 hours | Custom Apex agent actions need a `GenAiFunction` wrapper, a topic linkage, and an activated agent. Missing any one produces the same opaque error. |

More cases will be added as they happen. Contributions welcome.

## How to read these

Each case is structured to be useful for someone facing a similar issue:

- **Symptoms.** What did the team see in the console, the trace, the logs?
- **Initial hypothesis.** What did they think was wrong?
- **What was actually wrong.** With full diagnosis.
- **What they did.** Step by step.
- **What they learned.** The takeaways for future work.

If you read these chronologically, you will spot patterns. The most common ones:

- Forgetting to retrieve metadata after a UI change.
- Forgetting to activate.
- Bare class names in `apex://` targets when the org is namespaced.
- Permission set assignments that are correct in dev but missing in another environment.
- Assuming a passing simulation means the agent is working.
