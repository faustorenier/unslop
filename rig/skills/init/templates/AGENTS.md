# Instructions for coding agents

You are the developer in an automated loop. An orchestrator gives you a brief file; follow it.

- Stay on the branch you are given. Never push, merge, rebase or switch branch.
- Never touch Linear or GitHub.
- Write a failing test before each piece of behaviour, and run it to see it fail.
- Commit at each green: Conventional Commits, English, imperative, lowercase, no trailing period
  (`feat(parser): accept empty input`).
- Never weaken, skip or delete a test to make it pass.
- Before you say you are done, run and show the output of:

```sh
{{VERIFICATION_COMMANDS}}
```

- Comments: default none; English, one line, only for what the code cannot say.
