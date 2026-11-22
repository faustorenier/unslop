---
name: auto-dev
description: Develop the next unblocked issue of a Linear project end to end, with no human approval, then merge it into the project's integration branch and push it. One issue per run; the auto-dev script calls it in a loop. Use only when the user or that script asks for auto-dev.
argument-hint: <Linear project, e.g. "Todo CLI"> [--base <branch>]
disable-model-invocation: true
---

Run **one** iteration of the automatic development loop on the Linear project in $ARGUMENTS, then
stop. You run headless (`claude -p`): nobody answers questions, so never ask, decide. Load the
`planning:linear` skill first; every Linear command follows it (team, `--no-input`, states).

`--base <branch>` is the **base branch**: every issue branches from it and merges back into it.
Default `auto/<project-slug>`. It is `main` only when passed explicitly.

Your **last line of output** must be exactly one of these, because the `auto-dev` script reads it:

- `AUTO_DEV: NEXT <ISSUE>`: the issue is merged into the base branch and pushed.
- `AUTO_DEV: DONE`: nothing left to develop in the project.
- `AUTO_DEV: FAILED <ISSUE or -> <one-line reason>`: you stopped. Nothing broken reached the base branch.

Running this skill is the user's standing authorization to commit, merge and push to the base
branch. It never authorizes touching `main` unless `main` is the base branch.

## 1. Preflight

- The working tree must be clean. Run `git fetch`. If the base branch does not exist locally or on
  `origin`, create it from `origin/main` and push it with `-u`. Check it out and run
  `git pull --ff-only`. If any of these fails, stop with `FAILED - <reason>`.
- `HERDR_ENV` must be `1`, since `dev-loop` needs Herdr. If it isn't, stop with
  `FAILED - not inside Herdr`.
- Make sure the team label `auto-merged` exists (`linear label list`). If it doesn't, create it.

## 2. Pick the issue

List every issue of the project in every state (`linear issue query --project "<P>" --json`, see
`planning:linear` for the team flag).

- **Resolved** means Done, or labelled `auto-merged`. Canceled and Duplicate issues are ignored.
- **Candidates** are the issues that are not resolved and not ignored.
- An issue **In Progress** without `auto-merged` is a run that broke halfway. Stop with
  `FAILED <ISSUE> left In Progress by an earlier run` and let the user look at it.
- A candidate is **ready** when every issue that blocks it (`linear issue relation list <ISSUE>`,
  the `blocked-by` relations) is resolved.
- No candidates left: if the base branch is not `main`, make sure a PR from it into `main`
  exists (`gh pr list --head <base>`); if not, open it per `core:git`: title
  `feat: <project>`, body with one line per issue merged into the base branch and a
  `Closes <ISSUE>` line for each. Then print `AUTO_DEV: DONE`. Never merge that PR.
- Candidates left but none ready: stop with `FAILED - no unblocked issue left`.
- Otherwise take the ready candidate with the lowest number.

## 3. Develop

Run the `dev-loop` skill on the issue with the base branch: read `../dev-loop/SKILL.md` (relative
to this skill's base directory) and follow it exactly. It cannot be invoked as a skill, because
it is user-only. It handles the brief, the branch, the In Progress status and
the developer and reviewer agents. Wherever it says to report to the user, collect that report
for step 6 instead of stopping.

A review finding still open after the review rounds is **blocking** when it is a bug, a broken
acceptance criterion, a security issue or a broken rule from CLAUDE.md or an ADR the issue lists.
Style and taste findings are not blocking. If any blocking finding is left, go to step 7 with
that reason.

## 4. Verify, in place of the human test

Every check must pass. If one fails, give the developer up to 2 extra rounds to fix it (through
`dev-loop`'s developer pane). If it still fails, go to step 7.

1. Every command under `## Verification` in CLAUDE.md, on the issue branch.
2. Each acceptance criterion maps to a test that exists and passes. Write down how each criterion
   was verified. A "Then the user sees…" criterion cannot be verified headless: note it for step 6
   as a visual check, it does not block.
3. If CLAUDE.md describes a real-app check (dev server, browser through `chrome-devtools-cli`),
   run it as described, then stop every server you started and close the browser tabs.

## 5. Merge and push

Changes come only from this issue's branch.

1. On the branch, commit any remaining work per `core:git`. Use one commit, or a few if they read
   better.
2. `git checkout <base>`, `git pull --ff-only`, then
   `git merge --no-ff <branch> -m "Merge branch '<branch>' (<ISSUE>)"`.
3. A merge conflict: run `git merge --abort` and go to step 7.
4. Run the `## Verification` commands again on the base branch. If they fail, run
   `git reset --hard ORIG_HEAD` (only the merge is undone; the branch keeps the work) and go to
   step 7.
5. `git push origin <base>`, then delete the issue branch locally. **Never deploy. Never push to
   `main` unless it is the base branch.**

## 6. Close the issue

- Set the status to **In Review** and add the label `auto-merged` with
  `linear issue update <ISSUE> --add-label auto-merged` (`--label` replaces the other labels). **Never move it to Done**: the
  user does the testing and merges the base branch into `main`.
- Comment on the issue: the merge commit hash, the base branch, what was built, how each
  acceptance criterion was verified, the visual checks left for the user, and any review findings
  left open as non-blocking.
- Make sure no process you started is still running. Leave the Herdr tabs open:
  the `auto-dev` script closes every tab and pane the run opened once it reads your verdict.
- Print `AUTO_DEV: NEXT <ISSUE>`.

## 7. On failure

- Leave the issue branch as it is: don't merge it, don't push it, don't delete it. Make sure the
  base branch holds only what was there before, and that you are back on it with a clean working
  tree. Commit any unfinished work on the issue branch first, as `wip(<scope>): <message>`.
- Leave the issue **In Progress** and comment on it: what failed, the output that shows it, the
  branch name and the open findings.
- Stop any process you started. Leave the Herdr tabs open: the script keeps them after a failure,
  so the user can read the agents.
- Print `AUTO_DEV: FAILED <ISSUE> <reason>`.
