# Solve — problem to tested result

Solve is the problem-solving capability of MindVault. It is not a logging workflow.

## Core loop

```text
problem
→ retrieve previous attempts
→ understand the actual constraint
→ research when needed
→ propose practical options
→ User chooses
→ AI executes or helps execute
→ real-world result
→ preserve only what is worth keeping
```

## Before solving

Retrieve relevant context when the problem may have history:

- Mnemosyne for personal context and recurring preferences.
- `state/` / `HANDOFF.md` for unfinished work.
- durable knowledge and solutions for previous attempts.
- archive/transcripts only when higher-value sources cannot answer the question.

Do not make the User repeat information that can reasonably be retrieved.

## During solving

The AI should focus on the actual problem and constraints, not on producing notes.

Research should answer missing questions that materially affect the decision.

Present options in plain language. Explain the tradeoff or mechanism when it matters. Do not manufacture a menu of options when one sensible approach is clearly better.

Use Pi's tools to do deterministic or mechanical work rather than merely describing what the User could do.

## Validation

A solution is not "validated" because the AI thinks it should work.

Validation comes from a real-world outcome:

- the User tried it, or
- the system/tool was actually run and produced the expected result.

Prediction is optional. Use it when a measurable prediction would make an experiment substantially more informative.

## Persistence

After the outcome, ask:

> Is this worth preserving because it will help future work?

### Save as durable knowledge when

- a solution actually worked and is reusable;
- a decision would be expensive to reconstruct;
- a project fact needs to survive the current task;
- research or reasoning is valuable beyond the current conversation;
- a lesson has been validated by experience.

### Do not save when

- the result is obvious or easy to rediscover;
- the attempt was a dead end with no reusable lesson;
- it was only brainstorming;
- the conversation itself is the only value.

Prefer updating an existing artifact over creating a new solution file.

## Repeated failure

If a previously saved solution fails again, do not silently overwrite history. Retrieve the old solution, compare the old assumptions with the new circumstances, and update or demote the solution if the evidence warrants it.

## Completion

A Solve task is complete when:

1. the User's practical problem is resolved or a clear next action is established;
2. important unfinished state is preserved only if another session needs it;
3. durable knowledge is saved only when it earned persistence.

A task does not need a log entry, prediction, transcript update, or new Markdown file just because it happened.
