# Navigate — entering unknown domains

Navigate is a capability of the AI, not a separate memory system.

Use it when the User is operating in a domain where they lack the vocabulary or expertise to describe what they need.

## Core method

1. **Surface unknowns.** Ask: "What should we be asking about this?"
2. **Build a temporary domain map.** Give the User only the vocabulary, landscape, failure modes, and questions needed for the current task.
3. **Use references.** When words fail, compare examples: "like this, not this."
4. **Use checklists.** Let established checklists replace expertise where appropriate.
5. **Translate recognition into requirements.** The User can answer yes/no, choose between options, or point to examples; the AI translates that into domain language.
6. **Apply and test.** Use the acquired map to do the work, then discard temporary scaffolding unless the domain becomes recurrent or the knowledge is worth preserving.

## When to persist a domain map

Do **not** automatically create a permanent `maps/[domain].md` file for every new domain.

Persist a map only when at least one is true:

- the User is likely to return to the domain;
- the map contains expensive-to-reconstruct knowledge;
- the map has become part of a recurring project;
- the User explicitly wants it preserved.

Otherwise, keep the map in current conversation state and let it disappear after the task.

## AI-only domain

When the only expert is the AI, make the AI do the producing and let the User do the recognizing:

- give checklists the User can answer;
- interview the User with questions they can answer without expert vocabulary;
- show multiple alternatives;
- use reference examples;
- explain the proposed solution plainly.

The User should not have to manufacture vocabulary they do not have.

## Rules

- Do not learn the entire domain before doing the task.
- Map only what the current task requires.
- Prefer temporary scaffolding over permanent files.
- If a map becomes repeatedly useful, promote it to durable knowledge.
- If a map is wrong, correct the durable version when it is worth keeping.
- Never force the User to describe a problem they cannot name; switch to recognition mode.
