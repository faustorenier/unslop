---
name: tdd-loop
description: Enforces strict red-green-refactor test-driven development — a failing test that is run and observed failing before any implementation exists. Use when implementing a feature, fixing a bug, picking up a backlog issue, or whenever the user mentions TDD, tests first, red-green-refactor, or asks for the implementation to be test-driven.
---

# TDD loop

Red, green, refactor. One cycle per acceptance criterion. No shortcuts.

## The cycle

### 1. RED — write one failing test

- Write **one** test for **one** acceptance criterion. Not a suite. One.
- The test asserts on **observable behaviour through the public interface**. Never on
  private functions, internal state, or implementation details — those tests block the
  refactor step and get deleted within a month.
- **Run it. Watch it fail. Show the failure output.**
- Check *why* it failed. A test that fails with `ReferenceError` or a typo has proven
  nothing. It must fail on the assertion, for the reason you intended.
- If it passes immediately, the behaviour already exists or the test is wrong. Stop and
  work out which. Do not proceed.

### 2. GREEN — make it pass, minimally

- Write the least code that turns this test green. Not the general solution. Not the
  next three criteria.
- Run the test. Show it passing.
- Run the **whole** suite. A green new test with three old ones broken is a red cycle.

### 3. REFACTOR — with the safety net on

- Now improve the code: naming, duplication, extraction, boundaries.
- Behaviour must not change. Tests must not change.
- Run the suite after each meaningful edit.
- This step is not optional. Skipping it is how test-driven code becomes unmaintainable
  while staying green.

Then return to RED for the next criterion.

## Anti-cheating rules

These exist because writing the test and the implementation together is the default
failure mode, and it produces tests that assert whatever the code happens to do.

- **Never** write implementation and its test in the same edit, the same file write, or
  the same tool call. The failing run must exist between them.
- Never weaken, skip, comment out, or add a tolerance to a test to make it pass. If a
  test is wrong, say it is wrong and explain why before touching it.
- Never assert something trivially true (`expect(true).toBe(true)`, asserting on a mock
  you just configured, snapshotting whatever the current output is).
- Never mock the thing under test. Mock only what you do not own: network, clock,
  filesystem, third-party SDKs.
- Do not chase a coverage percentage. Cover behaviour and edges; coverage is a symptom,
  not a goal.

If a test cannot be written before the code — genuinely exploratory work, an unknown
third-party API — say so explicitly, spike it in a throwaway branch, then delete the
spike and start the real work from RED.

## What to test

- Happy path, once, per behaviour.
- Every boundary: empty, one, many, max, over max.
- Every error path the contract declares, including the message or code the caller
  depends on.
- Concurrency and idempotency where the contract promises them.
- Do not test the framework, the language, or generated code.

## Loop discipline

- Announce each phase: `RED: <criterion>`, `GREEN`, `REFACTOR`.
- Commit at each green, before refactoring, with the criterion in the message.
- If a cycle takes more than a few minutes of work, the step is too big. Shrink it.
- When all criteria for the issue are green and the suite passes, stop. Do not add
  speculative features, do not "improve" adjacent code, do not widen the scope.
