---
name: debug
description: Finds the root cause of a bug before any fix is proposed — reproduce, gather evidence, one hypothesis at a time, failing test, single fix. Use when encountering any bug, test failure, build failure, or unexpected behavior, before proposing fixes.
metadata:
  adapted-from: obra/superpowers systematic-debugging (MIT, see LICENSE)
---

# Systematic debugging

**No fix without a root cause.** A fix for a symptom you do not understand is a guess,
and guesses compound.

## 1. Investigate

- Read the whole error and stack trace: file, line, code. It often names the cause.
- Reproduce it reliably. Write down the exact steps. Not reproducible → gather more data,
  do not guess.
- Check what changed: `git diff`, recent commits, dependency bumps, config, env vars.
- Multi-layer systems (browser → API → service → DB, CI → build → deploy): log what enters
  and leaves each boundary, run once, and find **where** it breaks before asking why.
- Deep in the call stack: trace the bad value backwards to where it originates. Fix there,
  not where it surfaced.

## 2. Compare

- Find similar code in the same codebase that works. List every difference, however small.
- When following a pattern or library, read the reference implementation or docs fully
  (use Context7 for current library docs), not a skim.

## 3. Hypothesise

- One hypothesis, stated plainly: "X is the cause because Y".
- Test it with the smallest possible change, one variable at a time.
- Wrong → form a new hypothesis. Do not stack a second fix on top of the first.
- Don't know → say "I don't understand X". Do not pretend.

## 4. Fix

1. Write a failing test that reproduces the bug, and watch it fail for the right reason
   (follow `core:tdd`). No test framework → a one-off reproduction script.
2. One fix, for the root cause. No "while I'm here" changes.
3. Run the test and the whole suite. Confirm the original symptom is gone.

## Stop rules

- **Three failed fixes → stop.** Each fix revealing a new problem elsewhere means the
  design is wrong, not the hypothesis. Explain what you found and discuss with the user
  before attempting a fourth.
- Stop and go back to step 1 if you catch yourself thinking "just try X and see",
  "quick fix now, investigate later", or proposing fixes before tracing the data flow.
- Truly environmental or timing-dependent cause: document what you checked, add proper
  handling (retry, timeout, clear error) and logging. This is rare; usually the
  investigation was incomplete.

## Report

State the root cause in one sentence, the evidence for it, the fix, and the test that
now guards it.
