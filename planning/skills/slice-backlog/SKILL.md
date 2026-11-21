---
name: slice-backlog
description: Turns PRD vertical slices into a dependency-ordered backlog — a DAG of issues with blocking relationships, agent-ready acceptance criteria, and a parallelisation plan. Use after a PRD exists and the user asks to break work down, create issues, plan the build order, or figure out what can run in parallel.
---

# Slice backlog

Converts vertical slices into issues that an autonomous agent can pick up cold, and a
graph that says what may run at the same time.

This skill produces the **plan and the issue bodies**. Creating them in a tracker
(GitHub, Linear, Jira) is a separate step — hand off to whatever tracker skill or CLI
the project uses once the plan is approved.

## Issue anatomy

An issue is agent-ready when an agent with zero prior context can complete it without
asking a question. Every issue contains:

```markdown
## Goal
One sentence. The observable behaviour that exists when this is done.

## Context
Links to the PRD section and the specific files/modules involved. Do not restate the
whole PRD — point at it.

## Acceptance criteria
- [ ] Given <state>, when <action>, then <observable outcome>
- [ ] ...
Each phrased so it converts directly into a failing test.

## Out of scope
What a well-meaning agent might do here that it must not.

## Blocked by
#<issue> — and why, in half a sentence.
```

If you cannot phrase the acceptance criteria as testable Given/When/Then, the slice is
still too vague. Go back to the PRD rather than writing a fuzzy issue.

## Building the graph

1. List every slice.
2. For each pair, ask whether one **genuinely** cannot start until the other lands.
   Shared file is not a dependency — shared *contract* is. Be strict: false dependencies
   serialise the whole build.
3. Verify it is acyclic. A cycle means two slices are really one slice, or a contract
   needs extracting into its own upstream slice.
4. Compute the **ready set** — issues with no unfinished blockers. These can run
   concurrently, one agent each, on separate branches.
5. Compute the **critical path** — the longest chain. This is the floor on delivery time;
   everything else is slack.

Render the graph as a mermaid `flowchart LR` so it can be read at a glance.

## Priority within the ready set

When more issues are ready than there are agents, order by:

1. **Critical bugs** — anything currently broken in main.
2. **Infrastructure** — things that unblock or speed up every later issue (CI, test
   harness, type checking, local env).
3. **Tracer bullets** — the thin end-to-end slice that proves a new path works.
4. **Quick wins** — small, low-risk, independently shippable.
5. Everything else, by critical-path position.

## Sizing check

Before finalising, re-check each issue against one clean context window. An issue that
needs the agent to read half the codebase is mis-sized. Split it, or extract the reading
into a preceding "understand and document X" issue.

## Handoff to a tracker — ALWAYS ASK FIRST

**Never create issues in any tracker on your own initiative.** The backlog is useful as a
plan on its own; a tracker is a separate decision the user makes every time.

When the backlog is approved, ask exactly once, and stop:

> "Vuoi che crei queste issue su GitHub (epiche, task, project board) o su Linear
>  (progetto, issue, relazioni blocked-by), oppure le lascio come piano qui?"

- **No, or no clear answer** → stop. Leave the backlog in the conversation, or write it to
  a markdown file if the user asks. Do not mention it again.
- **Yes** → hand off to the tracker skill the user chose: `github-project-setup` for GitHub,
  `linear` for Linear. If that skill is not available, drive the tracker CLI directly
  (`gh issue create`, `gh project create`; `linear issue create`, `linear issue relation add`)
  and still confirm the full structure before creating anything.

Pass along, so the tracker step does not re-derive them: the issue bodies as written,
the `Blocked by` edges, and the ready set.

## Output

1. The mermaid DAG.
2. The full issue bodies, in dependency order.
3. The ready set and the critical path.
4. A one-line parallelisation recommendation: how many agents this backlog can actually
   keep busy.
