---
name: commit
description: Typecheck, summarize changes, and output an English conventional commit message
---

Run `npx tsc --noEmit`. If it fails, report errors and stop.
Then run `git diff --stat` and `git diff`.
Output ONE conventional commit message in English (feat/fix/chore/refactor/style/test), imperative subject <=72 chars, plus a short body listing the touched areas.
Do NOT run git commit. Just print the message in a code block.
