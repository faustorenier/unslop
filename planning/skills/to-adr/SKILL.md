---
name: to-adr
description: Record the architectural decisions settled in a grilling session as ADR files in docs/adr/, reusing and checking existing ones. Also applied by /planning:to-prd and /planning:to-ticket.
argument-hint: "[decision to record, optional]"
disable-model-invocation: true
---

Turn settled decisions into Architecture Decision Records in `docs/adr/`. ADRs are the only planning
artifact that lives only in the repo: they bind every later PRD and ticket.

`/planning:to-prd` and `/planning:to-ticket` apply sections 2-4 of this file and handle input and reply themselves.

## 1. Check the input

With an argument, record that decision. Without one, use the decisions settled in this conversation
(`/planning:grill-me`). If neither exists, **stop** and suggest running `/planning:grill-me` first. Never record a
decision the user has not made.

## 2. Find candidates

A decision becomes an ADR only if **all three** hold:

- **Hard to reverse** — changing it later costs real rework.
- **Surprising without context** — a newcomer reading the code would ask "why this?".
- **A real trade-off** — there were credible alternatives and one was chosen for stated reasons.

Everything else (naming, local implementation choices, obvious defaults) stays in the PRD or ticket.
Zero candidates is a normal outcome, especially for small changes.

## 3. Reuse and check conflicts

Read every file in `docs/adr/` (it may not exist yet).

- An existing ADR already covers a candidate → reuse it, don't duplicate.
- A candidate contradicts an accepted ADR → **stop** and ask the user: keep the old one (drop the
  candidate), or supersede it. Superseding sets the old ADR's status to `Superseded by ADR-NNNN`.
- Collect the accepted ADRs that constrain the work even if no new one is written.

## 4. Confirm and write

Show the candidates, one line each with the trade-off, plus any supersession. **Wait for approval**
and write only the approved ones, numbered after the highest existing (`0001` if none), as
`docs/adr/NNNN-<slug>.md`:

```md
# ADR-NNNN: <decision, as a statement>

- Status: Accepted
- Date: <YYYY-MM-DD>

## Context
The forces at play, in a few sentences.

## Decision
What was decided, in present tense.

## Alternatives considered
- <alternative> — why not.

## Consequences
What becomes easier, what becomes harder, what is now off-limits.
```

## 5. Reply

List the ADRs created, any superseded, and the existing ADRs that constrain the work (these go into a
ticket's Constraints, `_shared/workflow.md` §3).
