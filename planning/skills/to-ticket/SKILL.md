---
name: to-ticket
description: Turn a grilling session about a small change into a single Linear issue, skipping the PRD.
argument-hint: "[Linear project or parent issue, optional]"
disable-model-invocation: true
---

Turn the grilling session in this conversation into **one** ticket. This is the short path for small
changes. Bigger work goes through `/planning:to-prd` → `/planning:to-tickets`.

First read `../_shared/workflow.md` (relative to this skill's directory). It defines the pipeline, what a vertical slice
is, the ticket template, and the duplicate and recovery rules.

## 1. Check the input

Look back through this conversation for a `/planning:grill-me` session with settled decisions. If there is
none, **stop** and suggest running `/planning:grill-me` first. Don't write a ticket from guesses.

Optional argument: a Linear project or parent issue to attach the ticket to.

Check access to Linear (`linear` skill), and validate any project or parent issue, **before writing
ADRs**.

## 2. Check the size

Apply `_shared/workflow.md` §2 to what was settled. If it would take **more than one slice**, stop.
Explain briefly why (list the slices you see) and suggest `/planning:to-prd`. Continue only if the user
explicitly says to proceed anyway.

## 3. Extract ADRs

Read `../to-adr/SKILL.md` (relative to this skill's directory) and apply sections 2-4. Small changes often have no new
ADR candidates; still retain existing constraints that apply.

## 4. Draft the ticket

Apply `_shared/workflow.md` §3, with the "Standalone change" context line (or "Part of …" if attached
to a project).

- If something was assumed but never confirmed, list it to the user as an open question instead of
  baking it into the ticket.
- List in Constraints the ADRs that apply, including any just created.

Show the title and body to the user and **wait for approval**. Iterate until they approve.

## 5. Create it

Following the `linear` skill and `_shared/workflow.md` §4, create the issue. If an argument was given,
attach it there (`--project` or `--parent`).

Reply with the ticket link, the ADRs created (if any), and any open questions left.
