---
name: to-tickets
description: Turn the vertical slices of a PRD into agent-ready Linear issues with blocked-by relations, plus the ready set and critical path.
argument-hint: "<feature slug or Linear project>"
disable-model-invocation: true
---

Turn a PRD's vertical slices into Linear issues an agent can pick up cold, linked so the dependency
graph shows what can run in parallel.

First read `../_shared/workflow.md` (relative to this skill's directory). It defines the slice rules, the ticket
template, and the duplicate and recovery rules.

## 1. Check the input

The argument is the feature slug or the Linear project. Read `docs/prd/<slug>.md` and the project
(`linear` skill). If either is missing, **stop** and suggest `/planning:to-prd`. Don't invent slices.

Read the ADRs the PRD lists under Decisions.

## 2. Draft one ticket per slice

Apply `_shared/workflow.md` §3 to each slice, with the "Part of …" context line naming the slice.

- If a slice's acceptance criteria cannot be written as Given/When/Then, stop and say which slice is
  too vague; it needs fixing in the PRD first.
- If something was assumed but never confirmed, list it to the user as an open question instead of
  baking it into the ticket.

## 3. Check size and dependencies

- Re-check each ticket against `_shared/workflow.md` §2. A ticket that needs more than one clean
  context is split; tell the user and update the PRD's slice list to match.
- For each `Blocked by`, confirm one ticket **genuinely** cannot start until the other lands. Drop
  false dependencies.
- Verify the graph is acyclic. A cycle means two slices are really one, or a shared contract needs
  its own upstream ticket.
- Compute the **ready set** (no unfinished blockers) and the **critical path** (longest chain).

## 4. Show the plan

Show, in this order, and **wait for approval**. Iterate until they approve.

1. The graph as a mermaid `flowchart LR`.
2. Every ticket's title and body, in dependency order.
3. The ready set and the critical path.

## 5. Create them

Following the `linear` skill and `_shared/workflow.md` §4:

1. Create each issue in the project, in dependency order.
2. Add every `blocked-by` relation.

## 6. Reply

Reply with the issue links in dependency order, the ready set, the critical path, and how many agents
this backlog can keep busy at once.
