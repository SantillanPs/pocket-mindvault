# MindVault — Session Handoff

Session state lives here, on disk — never only in the AI's memory. Read at every session open (recap first). Written at every response. Fixed sections: Open Problems, Pending Validations, In-Flight Research, Last Known State, Waiting On User.

## Open Problems

- [2026-08-10] Unknown unknowns in unfamiliar domains. METHOD BUILT: Navigate workflow added to AGENTS.md (ask-for-questions, domain map, point-don't-describe, checklists). Artifacts: wiki/navigate/method.md (the five moves) + wiki/navigate/maps/frontend-design.md (map #1: UI/UX vocabulary, landscape, failure modes, questions, Nielsen checklist, reference gallery). VALIDATION PENDING: User uses the map on the real frontend redesign — names problems in map words, runs the checklist, collects reference examples.

## Pending Validations

- (none)

## In-Flight Research

- (none)

## Last Known State

- 2026-08-10: Navigate method built (third workflow). User corrected AI: stop overusing structured question menus — only when a real decision needs it (codified in AGENTS.md rules + memory). Method artifacts: wiki/navigate/method.md + maps/frontend-design.md. Solve cycle for the unknown-domains problem is at validation-pending stage.
- 2026-08-10: Second grilling completed. MAIN PURPOSE declared and written into AGENTS.md (user's own words): "The MindVault exists so that the User can become better — optimize growth, learning, career, and life." Solve and Reflect absorbed as the two METHODS serving it (per user's "absorbed" answer). Guardrails written into Core Purpose: "better" is broader than productive; rest counts as data; the vault suggests, never demands; never shames. Annual purpose review scheduled (first: 2027-08-09) — it also decides where growth/learning/career get measured ("review decides"). Growth lives in the daily record (transcripts) until then. wiki/reflect/README.md gained rule 9 (rest is data).
- 2026-08-09: Grilling completed (5 rounds). Design locked and BUILT: the vault gained the Reflect method — the thinking mirror for health & body and money & time. Built that session: `wiki/reflect/` (README.md rules, numbers.md weekly table, suggestions.md follow-through log, reports/), the Reflect workflow in AGENTS.md, HANDOFF + log updated, repair commit made. Prior session's uncommitted HANDOFF + transcript committed.
- 2026-08-09: Grilling session (grill-me skill) ran 5 rounds via the ask-user-questions tool. User decisions: mirror not storage; domains = health & body + money & time (not work/tech); success = behavior actually changed; worst failure = dead system. Teeth = visibility alone + plain follow-through reporting (no bets, no stakes). Data = tracked numbers, weekly. Output = pattern reports with ranked shortlist of 2-3 suggestions (own history first, playbooks as fallback). Security = local only. Anti-death = cold start ritual + weekly feeding floor.
- 2026-08-08: Vault bootstrapped from replication spec (commit 7886933). Healthcheck ported to bash (scripts/healthcheck.sh) since PowerShell is unavailable on this device; ps1 kept for Windows hosts. index.md placeholder removed so the healthcheck passes on a fresh vault. Healthcheck verified exit 0.

## Waiting On User

- (none — the weekly check-in numbers are welcome whenever the User wants to start; no due date, no pressure. First row goes in wiki/reflect/numbers.md.)
