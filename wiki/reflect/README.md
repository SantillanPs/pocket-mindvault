# Reflect — the thinking mirror

Reflect is MindVault's longitudinal analysis capability. It exists to show the User patterns that become visible across time, plainly and without pretending incomplete data is complete.

Reflect is **not** general memory and it is not a diary. Mnemosyne handles lightweight personal memory; Reflect handles structured measurements when longitudinal analysis is actually useful.

## Principles

1. **Only observed data.** Record only values the User actually provides or that a tool can reliably measure. Never invent, infer, or backfill missing values.
2. **Missing data is normal.** Gaps are simply gaps. No catch-up ritual, no empty rows, and no shame.
3. **Analysis over bookkeeping.** The purpose of storing a number is to make a future comparison possible. If a record does not help analysis, don't create it.
4. **Plain conclusions.** Say what the data supports directly. Distinguish observations from causal claims.
5. **User history first.** Prefer patterns found in the User's own data. External playbooks are secondary.
6. **Suggestions are experiments, not obligations.** A suggestion is worth recording only when tracking whether it was tried and what happened will improve future decisions. They are offered plainly: no bets, no penalties, no devil's advocate.
7. **Rest is data.** Recovery and downtime are valid outcomes, not failures.
8. **Cheap cold start.** After a gap, use whatever data exists. Never reconstruct missing history merely to make the dataset look complete.
9. **Local by default.** Reflect data stays in this repository unless the User explicitly asks to move or share it.

## What gets persisted

Persist structured measurements when at least one of these is true:

- the User is actively tracking the metric over time;
- the value will materially improve a future comparison;
- the value is needed to evaluate an ongoing experiment;
- the data would be expensive to reconstruct later.

Otherwise, leave it in conversation context.

## Weekly snapshots

A weekly row is useful when enough data exists to summarize the week or compare it with previous weeks. It is **not required every week**.

The AI may derive a snapshot from available evidence. Missing values remain blank; denominators must reflect the actual number of observations.

| Week | Weight (kg) | Sleep (avg h) | Spending (total) | Income (wk) | Exit fund | Good days | Screen (avg h/day) | Workout (sessions) | One line |
|---|---|---|---|---|---|---|---|---|---|

Do not create a row solely because a calendar week ended.

## Pattern reports

Generate a report only when there is enough data to answer a useful question, or when the User asks for one.

The old fixed schedule is not a requirement. Evidence quality matters more than elapsed weeks.

A useful report can contain:

1. **What the data shows** — direct observations.
2. **Patterns** — recurring relationships or changes supported by the available history.
3. **Uncertainty** — what cannot be concluded from the data.
4. **One to three experiments** — small actions worth testing, with a reason.
5. **Follow-through** — only for experiments that were deliberately tracked.

Never turn a small sample into a confident causal claim.

## Strength observations

Qualitative observations about the User can be stored separately from numeric pattern reports when they are durable and supported by repeated behavior. They should not be presented as measured statistics.
