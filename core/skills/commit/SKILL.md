---
name: commit
description: Typecheck, review the diff, and print a commit message that follows git-pr-conventions
disable-model-invocation: true
---

1. If the project has a `tsconfig.json`, run `npx tsc --noEmit`. If it fails, report the errors and stop.
2. Run `git status`, `git diff --stat` and `git diff` (staged and unstaged).
3. Write ONE commit message following the `git-pr-conventions` skill: type, optional scope,
   subject ≤ 72 chars, body explaining why. If the diff holds unrelated changes, say so and
   propose one message per logical change instead.
4. Print it in a code block. Do NOT run `git commit` unless the user asks.
