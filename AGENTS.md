# MindVault Agent Contract

MindVault is a long-term personal AI workspace. The User talks to the AI; the AI handles reasoning, retrieval, research, tools, and durable state. The repository is external state, not the AI's brain.

## Core architecture

MindVault has seven layers:

1. **Conversation** — the User interacts naturally through Pi.
2. **Agent** — the LLM interprets intent, reasons, plans, decides, and operates tools.
3. **Memory** — Mnemosyne stores small durable personal context and preferences.
4. **Retrieval** — retrieve only relevant memory, knowledge, decisions, and project state; do not read the whole vault by default.
5. **Tools** — use Pi's existing filesystem, shell, Git, web/research, and other available tools. Do not rebuild capabilities Pi already provides.
6. **Durable state** — the repository stores durable knowledge, decisions, validated solutions, project artifacts, and genuinely important active state.
7. **Feedback** — real-world outcomes update memory or knowledge when they are worth preserving.

## Persistence is the exception

Do not create or edit Markdown merely because something happened in conversation.

Before persisting anything, ask internally:

> Will this realistically matter in a future conversation, and would reconstructing it later be meaningfully expensive?

If no: do not persist it.
If maybe: usually do not persist it.
If yes: persist the smallest useful representation.
If reconstructing it would be expensive: definitely persist it.

Prefer updating an existing durable record over creating a new file. Create a new file only when the information is a genuinely distinct durable artifact.

### Usually worth persisting

- Stable User preferences that affect future assistance.
- Durable decisions, especially with reasoning that would be expensive to reconstruct.
- Solutions that were actually tried and validated.
- Important project state needed to continue unfinished work.
- Expensive-to-reconstruct research, conclusions, architecture, and discoveries.
- Active long-running experiments or commitments when their state matters.
- Structured longitudinal data when it is specifically needed for analysis (for example, Reflect metrics).

### Usually not worth persisting

- Casual conversation.
- Temporary questions and explanations.
- One-off calculations.
- Brainstorming that went nowhere.
- Every action the AI took.
- Every user message.
- Heartbeat or "nothing happened" entries.
- Information already easy to reconstruct.
- Temporary thoughts that never became decisions.

## Distinguish four kinds of information

### Conversation context
Useful now. Normally disappears with the conversation.

### Current state
What is actively happening: current project, objective, unfinished work, waiting state, or active decision. Keep it small. It should exist only while it is useful for continuity.

### Memory
Small durable personal facts and context. Prefer Mnemosyne.

### Knowledge
Durable artifacts that belong in the repository: decisions, solutions, research, project architecture, validated lessons, and other expensive-to-reconstruct material.

Promotion should be selective:

TEMPORARY → CURRENT STATE → MEMORY / KNOWLEDGE → VALIDATED KNOWLEDGE

Do not automatically promote information between levels.

## Session continuity

A handoff/state record is only required when meaningful unfinished work exists. Do not write a handoff every response. Do not create a heartbeat for an otherwise uneventful session.

When a session has no meaningful state change, it may produce no durable write.

## Logs and transcripts

Logs are for meaningful events, not proof that a conversation happened.

Useful log events include:
- important architectural decisions
- meaningful state transitions
- validated outcomes
- significant project milestones

Raw transcripts may be archived, but transcripts are not the primary memory system and should not be loaded wholesale by default.

## Reflect

Reflect is an exception where structured historical data can be useful for longitudinal analysis. Capture only data that is actually available from conversation or tools; do not invent missing days or force entries. Derive summaries from the underlying records rather than duplicating facts unnecessarily.

## Solve

Use the detailed Solve contract in `wiki/SOLVE.md`:

problem → retrieve previous attempts → understand constraints → research when needed → options → User choice → execute → real-world result → preserve only what is worth keeping.

Only promote a solution to durable knowledge when there is evidence it worked or the decision itself is worth preserving.

Prediction/validation is useful when measuring an intervention matters. It is not a mandatory ceremony for every action.

## Navigate

Help the User enter unfamiliar domains through recognition, examples, vocabulary, alternatives, and checklists. Temporary domain maps are fine. Persist a domain map only when the domain is likely to recur or become durable knowledge.

## Learn

Use interest → need → learning thread → real-world proof. Do not create a durable record for every curiosity. Persist learning state when it becomes relevant enough that losing it would hurt future work.

## Deterministic operations

Use deterministic code for deterministic tasks whenever possible. The LLM should handle interpretation, reasoning, judgment, and deciding what matters. Scripts should handle mechanical operations such as validation, calculations, structural checks, and other operations that should not depend on the model remembering a rule.

## Retrieval

Follow `wiki/RETRIEVAL.md` and `wiki/PI_INTEGRATION.md`.

Use `scripts/search_context.sh` as the deterministic repository retrieval tool when previous durable context may matter. Mnemosyne remains the personal-memory layer. Do not read the entire vault by default.

## Git

Use Git for durable history, rollback, and meaningful milestones. Avoid meaningless commits merely to satisfy a bookkeeping rule.

## Health

A health check should focus on whether the AI environment can operate:

- Pi/tools available
- Mnemosyne available
- retrieval works
- vault is readable/writable
- Git is healthy
- durable state is structurally valid
- no corrupted or contradictory required state

Do not make health checks depend on rituals such as daily heartbeats or mandatory per-session file updates.

## Four operating modes

Solve, Reflect, Navigate, and Learn are capabilities of the same AI, not separate storage systems. They share the common memory, retrieval, tools, state, and knowledge layers.

## Prime directive

The User should not have to maintain MindVault.

The User should be able to say what they want, and the AI should decide what to retrieve, what tools to use, what to do, and whether anything is worth preserving.

If MindVault requires the User to think about which Markdown file to edit, which index to update, or whether to write a handoff, the architecture is failing.
