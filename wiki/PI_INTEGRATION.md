# Pi Integration Contract

MindVault is designed to run through Pi. Pi is the agent runtime and tool interface; MindVault provides durable state and retrieval rules.

## Startup

At the beginning of a new task:

1. Read `AGENTS.md`.
2. Check current conversation context first.
3. If continuity matters, inspect `HANDOFF.md` or `state/` only when active work exists.
4. Use Mnemosyne for personal memory when available.
5. Use `scripts/search_context.sh` when previous durable context may help.
6. Do not read the whole vault by default.

## Retrieval

For a request that may depend on previous work, call:

```bash
bash scripts/search_context.sh "<plain-language query>"
```

Use broader search only when the normal result is insufficient:

```bash
bash scripts/search_context.sh "<query>" 20 --archive
```

Use `--all` only when historical reconstruction is genuinely necessary.

## Memory boundary

Mnemosyne is the preferred place for small durable personal facts, preferences, recurring context, and lightweight continuity.

Do not copy Mnemosyne memory into Markdown unless the information is also a durable artifact or project fact that belongs in the repository.

## Writing boundary

Before writing anything, decide which layer it belongs to:

- conversation context → no file
- personal memory → Mnemosyne
- current unfinished work → `state/` / `HANDOFF.md`
- durable knowledge → `knowledge/` or an existing durable artifact
- raw history → archive

Never create a file merely because a conversation happened.

## Tool boundary

Prefer Pi's existing tools for deterministic work. Do not reimplement shell, Git, filesystem, or web capabilities in MindVault unless there is a demonstrated gap.

MindVault scripts should be small deterministic helpers, not a second agent runtime.

## Retrieval output

`search_context.sh` is intentionally lexical and deterministic. It is the first retrieval layer, not the final intelligence layer.

If repeated real-world use shows that lexical search misses relevant material because different words describe the same concept, then add semantic retrieval. Do not add a vector database or embeddings until there is evidence they are needed.

## Failure behavior

If retrieval returns nothing:

- do not invent continuity
- ask the User when the missing fact matters
- research when research is appropriate

If retrieved records conflict, prefer the newest validated information and surface the conflict when it matters.

## Agent principle

Pi should feel like it is operating one continuous personal environment. The User should not need to know which script, directory, or memory backend produced the context.
