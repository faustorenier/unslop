---
name: fresh-context-review
description: Reviews a diff, branch, or pull request against its acceptance criteria from a forked clean context, as an adversarial reviewer who did not write the code. Use when the user asks to review changes, review a PR, check a branch before merge, or says the implementation is done and needs checking.
argument-hint: "[PR number | branch | Linear issue ID]"
context: fork
---

# Fresh context review

You run in a forked context with no memory of how this code was written. Keep it that way:
review from the diff and the requirements only. Read the code as written, not as intended.

Target: $ARGUMENTS (empty → the current branch against its base branch).

This skill checks the change against what was asked. For a broad bug hunt with no
acceptance criteria, the built-in `/code-review` is the better tool.

## Setup

1. Get the diff (`gh pr diff`, or `git diff <base>...HEAD`). Find the Linear issue ID in the
   target or the branch name (`feat/fau-42-…` → `FAU-42`) and read the issue and its project
   with the `linear` skill, then the PRD its Context names and the ADRs in its Constraints.
   No issue → review against the PR description, flagging that as a weakness.
2. Read the acceptance criteria **first**, before the code. This is what you are checking
   against — not your own idea of what the code should look like.
3. If the diff is too large to hold comfortably in a clean context, stop: say the PR
   needs splitting rather than reviewing it badly.

## What to check, in order

**1. Does it do what was asked?**
Walk each acceptance criterion and point at the code and the test that satisfies it.
Anything unmatched is a finding. Anything in the diff matching no criterion is scope
creep — also a finding.

**2. Are the tests real?**
This is where AI-written code fails most often. Look for:
- Tests asserting on mocks the test itself configured.
- Tests that would pass against an empty implementation.
- Tests written after the fact to describe existing behaviour rather than required
  behaviour.
- Weakened assertions, added tolerances, `skip`, `only`, commented-out cases.
- Missing boundary and error cases that the contract promises.

Sanity check: mentally break the implementation. If no test goes red, the test is decoration.

**3. Correctness**
Concurrency, idempotency, retries, partial failure. Null and empty. Off-by-one. Time
zones and clocks. Unhandled promise rejections. Resource cleanup. Error swallowing.

**4. Security**
Injection, authorisation checks on every new entry point, secrets in code or logs, PII
in telemetry, unvalidated input crossing a trust boundary, dependency additions.

**5. Architecture**
Does the change fit the module boundaries that already exist, or does it punch through
them? Does it make a module shallower (more exports, less encapsulated)? Is there
duplication of something that already exists elsewhere in the codebase? Does it respect
every ADR the issue lists? A violation is a finding that names the ADR.

**6. Slop**
Functionally correct but wrong in taste: invented abstractions with one caller, defensive
code for impossible states, comments restating the code, inconsistent naming, dead
parameters, config that nothing reads, `any` used to silence the type checker.

## Reporting

Report only findings you would defend. For each one give: the file and line, what is
wrong in one sentence, and a concrete failure scenario — inputs or state that produce
the wrong outcome. A finding with no failure scenario is a preference, and preferences
go in a separate, clearly-labelled list at the end.

Rank by severity. State plainly if nothing is wrong.

## After review

Do not fix anything: you are the reviewer. End with a recommendation per finding — a
one-line correction the author would obviously accept, or a follow-up ticket via
`/planning:to-ticket`. The main session asks the user before creating any issue. Manual QA of the end-to-end behaviour is
still required: the review checks the code, not the system.
