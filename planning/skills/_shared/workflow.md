# Planning workflow — shared rules

Every planning skill cites this file by section (`_shared/workflow.md` §N). A rule lives here once;
skills point at it instead of restating it.

## 1. Pipeline and artifacts

Skills are invoked as `/planning:<skill>`; below they are named by skill only.

```
grill-me ──► complexity (§2)
               ├── one slice   ──► to-ticket ──► to-adr? ──► one Linear issue
               └── many slices ──► to-prd    ──► to-adr  ──► docs/prd/<slug>.md + Linear project
                                                              └──► to-tickets ──► Linear issues
```

| Artifact | Where | Written by |
|---|---|---|
| Decisions, open questions, risks | the conversation | `grill-me` |
| PRD | `docs/prd/<slug>.md` | `to-prd` |
| ADRs | `docs/adr/NNNN-<slug>.md` | `to-adr` (also applied by `to-prd`, `to-ticket`) |
| Project (summary + PRD path) | Linear | `to-prd` |
| Issues and `blocked-by` relations | Linear | `to-tickets`, `to-ticket` |

- The tracker is Linear only. Every Linear read or write goes through the `linear` skill: its team,
  flags, states, labels and Markdown rules apply.
- Repo files and Linear text are written in English. `<slug>` is kebab-case, derived from the feature name.
- Nothing is written to the repo or to Linear before the user approves the draft.

## 2. Vertical slices and complexity

A slice is **not** a layer. "Build the database schema" is not a slice. A slice cuts through every layer
it needs and ends with something a human can observe working.

- **Tracer bullet first.** Slice 1 goes end to end with the thinnest possible functionality, hardcoded
  where necessary. It proves the wiring; later slices thicken the path it opened.
- **One clean context.** A slice must be completable by one agent in one context window. More than
  roughly a dozen files, or two unrelated subsystems, means it must be split.
- **Real dependencies only.** A shared *contract* is a dependency; a shared file is not. Express
  dependencies as `Blocked by` so the slices form a directed acyclic graph. Never write phases.

**Complexity** is the number of slices the settled design needs: **one** slice is low → `/planning:to-ticket`;
**two or more** is high → `/planning:to-prd`.

## 3. Ticket template

An issue is ready when an agent with no memory of the planning conversation can finish it without
asking a question. Body, in this order:

```md
## Goal
One sentence: the observable behaviour that exists when this is done.

## Context
Part of <Linear project URL> — PRD `docs/prd/<slug>.md`, slice "<slice title>".
(or: Standalone change.)

## Acceptance criteria
- [ ] Given <state>, when <action>, then <observable outcome>

## Out of scope
What a well-meaning agent might do here and must not.

## Constraints
- ADR-NNNN <title> — the part that binds this ticket.

+++ [Agent notes]

Files and modules involved, contracts to respect, pitfalls.

+++
```

- Every acceptance criterion is Given/When/Then and converts directly into one failing test (`tdd-loop`).
  If a criterion cannot be phrased that way, the design is still too vague: go back, don't write a
  fuzzy ticket. Visual work (layout, styling, animation, 3D) gets a "Then the user sees…" criterion
  checked by eye instead.
- Point at the PRD; never restate it.
- Dependencies are **not** written in the body: they become `blocked-by` relations on Linear.
- Title: imperative, one line. Label `Feature` (or `Bug` / `Improvement`), state `Backlog`.

## 4. Duplicates and recovery

- **Before creating** a project or an issue, search for it (`linear project list`,
  `linear issue query --search "<title>"`). If a match exists, show it and ask whether to reuse,
  update or create anyway.
- **Exit code 5** (Linear unavailable): the write may have gone through. Check before retrying.
- **Partial failure** in a multi-step write: stop, list what was already created (with URLs) and what
  is missing, and resume from the first missing item. Never recreate what exists.
