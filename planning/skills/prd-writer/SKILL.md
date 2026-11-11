---
name: prd-writer
description: Writes a PRD that describes the destination end state of a feature, plus the vertical slices that get there. Use after a design interview, when the user asks for a PRD, spec, or technical design doc, or says "write this up" / "turn this into a spec" before implementation starts.
---

# PRD writer

A PRD is a **destination document**. It describes the world once the work is finished,
in enough detail that an agent with no memory of the design conversation can build it.
It is not a plan, not a schedule, and not a task list.

## Preconditions

Do not write a PRD from a vague brief. If the design has not been interrogated, say so
and run `grill-me` first. Open questions must be marked as such, never invented.

## Structure

Write to `docs/prd/<feature-slug>.md`.

```markdown
# <Feature>

## Problem
Who has the problem, what they do today, why today is not good enough. 1 paragraph.

## End state
Describe the system as it will be, in present tense, as if it already shipped.
This is the longest section. Be concrete: routes, screens, entities, side effects.

## Out of scope
Explicit list. Anything a reasonable reader might assume is included but isn't.

## Domain model
Entities, fields, relationships, invariants that must always hold.

## Contracts
API shapes, events, and errors. Request/response for each endpoint. Error codes and
what the client does with each.

## Non-functional requirements
Load, latency budget, cost ceiling, security, observability, rollback plan.

## Vertical slices
See below.

## Open questions
Each with the decision owner and what unblocks it.
```

## Vertical slices — the core of the document

A slice is **not** a layer. "Build the database schema" is not a slice. A slice cuts
through every layer — persistence → service → API → UI — and ends with something a
human can observe working.

For every slice write:

- **Title** — imperative, one line.
- **Ships** — the observable behaviour that exists after this slice and not before.
- **Touches** — the layers and rough files involved.
- **Done when** — an acceptance check phrased so it can become a failing test.
- **Blocked by** — other slices, by title. This is what forms the dependency graph.

### Slice 1 is always a tracer bullet

The first slice must go end to end through every layer with the thinnest possible
functionality: one field, one endpoint, one rendered value, hardcoded where necessary.
Its purpose is to prove the wiring, not to deliver value. Everything after it thickens
the path the tracer bullet opened.

### Sizing

Each slice must be completable by one agent in one clean context window. If a slice
needs more than roughly a dozen files or spans two unrelated subsystems, split it.
Prefer many small slices over few large ones — small slices produce small pull requests,
and small pull requests are the only kind that get reviewed properly.

### Blocking, not phases

Do not write "Phase 1 / Phase 2 / Phase 3". Sequential phases serialise work that could
run in parallel. Express only real dependencies via **Blocked by**, so the result is a
directed acyclic graph. Two slices with no path between them can be built concurrently.

## Finish

End with a short summary: number of slices, which ones are unblocked at the start, and
the critical path. Then ask whether to turn the slices into a tracked backlog.
