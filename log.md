# MindVault Log

A sparse record of meaningful durable events. This is **not** a transcript log and not proof that a session occurred.

Only record events when they create or change durable state, such as:
- an important decision
- a meaningful project-state transition
- a validated solution or outcome
- a significant architectural change
- a milestone worth reconstructing later

Do not create heartbeat entries, per-response entries, or entries merely because a conversation happened.

## [2026-08-13] architecture | Persistence policy simplified

MindVault is being refactored so persistence is selective. Mnemosyne is the preferred store for small durable personal memory; the repository stores durable knowledge and artifacts; current state is kept only while unfinished work matters; raw transcripts are archival rather than primary memory. Solve, Reflect, Navigate, and Learn share these layers rather than maintaining separate storage systems.

## [2026-08-12 14:45] goal | OUT Solve job opened

The OUT plan is now an active Solve job. Facts needed: freelance income/week, savings, current monthly costs, target city + rent level, target timeline.

## [2026-08-11] navigate | First real-world validation passed

The Navigate method was used on the real frontend redesign and the User reported that the advice worked. Durable solution saved at `wiki/solutions/unknown-domains-navigate-method.md`.
