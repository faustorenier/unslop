---
name: to-prd
description: Turn a grilling session about multi-slice work into a PRD in docs/prd/ and a matching Linear project, recording ADRs on the way. Next step is /planning:to-tickets.
argument-hint: "[feature slug, optional]"
disable-model-invocation: true
---

Turn the grilling session in this conversation into a PRD. This is the path for work that needs more
than one vertical slice; a single slice goes through `/planning:to-ticket`.

First read `../_shared/workflow.md` (relative to this skill's directory). It defines the pipeline, what a vertical slice
is, and the duplicate and recovery rules.

A PRD is a **destination document**: it describes the world once the work is finished, in enough
detail that an agent with no memory of the design conversation can build it. It is not a plan, a
schedule or a task list.

## 1. Check the input

Look back through this conversation for a `/planning:grill-me` session with settled decisions. If there is
none, **stop** and suggest running `/planning:grill-me` first. Don't write a PRD from guesses.

Optional argument: the feature slug. Otherwise derive one and confirm it with the user.

Check access to Linear (`linear` skill) and look for an existing project or `docs/prd/<slug>.md`
(`_shared/workflow.md` §4), **before writing ADRs**.

## 2. Check the size

Apply `_shared/workflow.md` §2. If the work fits **one slice**, stop and suggest `/planning:to-ticket`.
Continue only if the user explicitly says to proceed anyway.

## 3. Extract ADRs

Read `../to-adr/SKILL.md` (relative to this skill's directory) and apply sections 2-4.

## 4. Draft the PRD

```md
# <Feature>

Linear project: <URL, filled in at step 6>

## Problem
Who has the problem, what they do today, why that is not good enough. One paragraph.

## End state
The system as it will be, in present tense, as if it already shipped. The longest section.
Be concrete: screens, entities, behaviours, side effects.

## Out of scope
Anything a reasonable reader might assume is included but isn't.

## Domain model
Entities, fields, relationships, invariants that must always hold.

## Contracts
Interfaces between parts: API shapes, events, data formats, errors and how each is handled.

## Non-functional requirements
Performance budget, limits, security, observability, rollback. Only what applies.

## Decisions
- ADR-NNNN <title> — one line on what it fixes. (New and existing ADRs that apply.)

## Vertical slices
1. **<Title>** — Ships: <observable behaviour that exists after this slice and not before>.
   Blocked by: none.
2. **<Title>** — Ships: <…>. Blocked by: 1.

## Open questions
Each with who decides and what unblocks it.
```

- Slices follow `_shared/workflow.md` §2: slice 1 is the tracer bullet, dependencies only where real.
  Keep each slice to title, Ships and Blocked by; acceptance criteria and files belong to the tickets.
- Anything assumed but never confirmed goes into Open questions, never into the End state.

Show the PRD to the user and **wait for approval**. Iterate until they approve.

## 5. Write the file

Write `docs/prd/<slug>.md`.

## 6. Create the Linear project

Following the `linear` skill and `_shared/workflow.md` §4, create the project:

- name: the feature name;
- description (≤ 255 characters): the problem in one sentence;
- overview (`--content-file`): the End state condensed to a few lines, the slice list, and
  "Full PRD: `docs/prd/<slug>.md`".

Put the project URL on the PRD's `Linear project:` line.

## 7. Reply

Reply with the PRD path, the project link, the ADRs created (if any), and any open questions left.
Then suggest `/planning:to-tickets <slug>`.
