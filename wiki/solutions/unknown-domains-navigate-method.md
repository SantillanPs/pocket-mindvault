---
type: Solution
problem: Getting dropped into domains you know nothing about, with no vocabulary to even name the gaps
solved: 2026-08-11
recheck: 2026-11-09
deployed_to: AGENTS.md Navigate workflow + wiki/navigate/method.md
mechanism: ai-present
dissent: Validation was real-world but anecdotal — the User's "the advice worked," with no prediction or stake written before validating (the ledger rule was skipped in practice). Recheck should re-confirm on a second domain. 
---

## Problem

The User gets dropped into domains they know nothing about — the instance that opened this problem was redesigning a system's frontend with zero UI/UX knowledge, but it hits in many rooms (work, health, money, new tools). They don't know the field's words, can't explain what they don't like or want, and can't name the gaps. Core pain: **not knowing what they don't know**. You can't tell someone (or an AI) what's wrong when you can't name the problem in the first place.

## What We Tried

- **A UI/UX toolkit** built around the frontend example — corrected: the problem is general, frontend was just one instance. Narrow toolkits can't be the answer to a general problem.
- **Describing the problem** ("explain what you don't like") — fails because describing requires vocabulary you don't have. When you lack the words, describing fails.
- **Asking the AI to research** — the AI can't fill a gap you can't name; it guesses, and the User can't tell a good guess from a bad one.

## The Fix

The **Navigate method** (six moves, full spec in `wiki/navigate/method.md`):

1. **Ask for the questions first** — surface the unknown unknowns before anything else.
2. **Build the domain map** — core vocabulary (~30 terms, plain meanings), the landscape (parts, tools, who does what), failure modes, and the questions people in the field ask. Map #1: `wiki/navigate/maps/frontend-design.md`.
3. **Point, don't describe** — collect 5-10 reference examples of "good" ("like X, not like Y"). Examples carry meaning words can't.
4. **Checklists replace judgment** — run the domain's standard checklists; a newcomer with a checklist finds what an expert spots by instinct.
5-6. **When describing fails, make the other side generate** — checklist, interview, three versions, "explain what you did plainly" — and **shrink yourself to recognizing** (yes/no / this-one-not-that-one). Recognition needs zero domain vocabulary.

## Why It Worked

You can't find a gap you can't name. Navigate's moves convert "I don't know what I don't know" into "I know what I don't know," which is manageable — the map gives the words, references give the targets, checklists give the search pattern, and recognition lets the User judge without vocabulary. First real-world test: the User ran the method + frontend-design map on the real frontend redesign and reported the advice **worked** (validation passed 2026-08-11, recorded in HANDOFF.md). The method is `ai-present` — it lives in `wiki/navigate/method.md` and the AGENTS.md workflow, and the AI re-applies it when a new unknown domain shows up.
