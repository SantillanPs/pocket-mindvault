# MindVault Retrieval Contract

Retrieval is the bridge between conversation and durable context. The AI should retrieve relevant information instead of loading the entire vault.

## Retrieval order

When a request may depend on previous context:

1. **Current conversation** — use what is already available first.
2. **Mnemosyne** — search durable personal memory and recurring context.
3. **Current state** — inspect active project/unfinished-work state when continuity is relevant.
4. **Durable knowledge** — search solutions, decisions, research, project artifacts, and other preserved knowledge.
5. **Archive/transcripts** — search raw history only when the answer cannot be reconstructed from the higher-value layers.

## Local retrieval command

The repository provides a lightweight deterministic first-pass search:

```bash
bash scripts/search_context.sh "query" [limit] [--archive|--all]
```

Normal searches cover current state and high-value knowledge while deliberately excluding raw archives/transcripts. Use `--archive` or `--all` only when broader historical retrieval is justified.

This is intentionally simple. It is a lexical retrieval layer, not semantic search. Mnemosyne remains responsible for personal memory. Add semantic retrieval only if real usage demonstrates that lexical search is insufficient.

## Query by intent

Retrieval should be driven by the user's actual request, not by a generic "read everything" operation.

Examples:

- "What did we decide?" → decisions and project state.
- "Didn't we try this before?" → solutions, previous attempts, and relevant memory.
- "Continue what we were doing." → current state first, then recent project context.
- "What do you know about me?" → Mnemosyne and durable personal context.
- "How did we solve this?" → validated solutions and prior attempts.
- "What happened in that conversation?" → archive/transcripts as a last resort.

## Relevance rules

Prefer:
- exact matches
- same project/topic
- recent active state
- validated knowledge over speculation
- decisions with explicit reasoning
- outcomes over intentions

Avoid:
- loading the whole vault
- retrieving duplicate versions of the same fact
- treating old brainstorming as current truth
- treating unvalidated ideas as solutions
- returning large raw transcripts when a small durable record answers the question

## Memory vs knowledge

Use Mnemosyne for small personal facts and context.
Use the repository for durable artifacts.
Do not duplicate the same information in both unless the duplication has a clear retrieval benefit.

## Fallback

If retrieval finds conflicting information, prefer the most recent validated state and surface the conflict when it materially affects the answer.

If retrieval finds nothing, do not invent continuity. Ask the User or research the problem.

## Agent integration

Pi should treat `search_context.sh` as the deterministic repository retrieval tool. The LLM decides when retrieval is warranted and what query expresses the user's intent; the script handles the mechanical search.
