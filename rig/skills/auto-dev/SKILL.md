---
name: auto-dev
description: Take the next unblocked issue of a Linear project from start to finish with no human approval, then merge it into the project's integration branch and push it. One issue per run; the auto-dev script calls it in a loop. Use only when the user or that script asks for auto-dev.
argument-hint: <Linear project, e.g. "Todo CLI"> [--base <branch>]
disable-model-invocation: true
---

This skill runs **a single** iteration of the automatic development loop for the Linear project
in $ARGUMENTS, then stops. The session is headless (`claude -p`) and nobody is there to answer:
never ask, decide. Load the `planning:linear` skill before anything else; it governs every Linear
command (team, `--no-input`, states).

## Contract

**Integration branch** (`<base>` in the commands below): set with `--base <branch>`. Every issue
branches from it and merges back into it. Without the flag it is `auto/<project-slug>`; it is
`main` only when passed explicitly.

**Authorization**: invoking this skill is the user's standing authorization to commit, merge and
push to the integration branch. It never covers `main`, unless `main` is the integration branch.

**Verdict**: the `auto-dev` script reads your **final line of output**, so that line must be
exactly one of:

| Line | Meaning |
|---|---|
| `AUTO_DEV: NEXT <ISSUE>` | the issue is merged into the integration branch and pushed |
| `AUTO_DEV: DONE` | the project has nothing left to develop |
| `AUTO_DEV: FAILED <ISSUE or -> <one-line reason>` | you stopped; nothing broken reached the integration branch |

## Starting state

1. The working tree must be clean.
2. Run `git fetch`. If the integration branch does not exist locally or on `origin`, create it
   from `origin/main` and push it with `-u`.
3. Check it out and run `git pull --ff-only`.

If any of the three fails, stop with `FAILED - <reason>`.

4. `HERDR_ENV` must be `1`, because `dev-loop` depends on Herdr. Otherwise stop with
   `FAILED - not inside Herdr`.
5. The team label `auto-merged` must exist (`linear label list`); create it if it is missing.

## Choosing the issue

Fetch every issue of the project in every state: `linear issue query --project "<P>" --json`
(the team flag is in `planning:linear`). Then sort them with these terms:

- **Settled**: Done, or carrying the `auto-merged` label.
- **Ignored**: Canceled or Duplicate.
- **Pending**: neither settled nor ignored.
- **Unblocked**: a pending issue whose blockers (the `blocked-by` relations listed by
  `linear issue relation list <ISSUE>`) are all settled.

Decide in this order; the first rule that applies wins:

1. An issue is **In Progress** without `auto-merged`: an earlier run broke halfway through it.
   Stop with `FAILED <ISSUE> left In Progress by an earlier run` so the user can look at it.
2. Nothing is pending: if the integration branch is not `main`, make sure a PR from it into
   `main` exists (`gh pr list --head <base>`). If there is none, open it per `core:git`, titled
   `feat: <project>`, with a body of one line per issue merged into the integration branch and a
   `Closes <ISSUE>` line for each. Then print `AUTO_DEV: DONE`. You never merge that PR.
3. Pending issues exist but none is unblocked: stop with `FAILED - no unblocked issue left`.
4. Otherwise take the unblocked issue with the lowest number.

## Building it

Run `dev-loop` on the issue against the integration branch: read `../dev-loop/SKILL.md` (relative
to this skill's base directory) and follow it to the letter. It cannot be invoked as a skill,
because it is user-only. It takes care of the brief, the branch, the In Progress status and the
developer and reviewer agents. Wherever it tells you to report to the user, do not stop: keep
that report for **Wrapping up the issue**.

A review finding still open once the review rounds are over is **blocking** when it is:

- a bug
- a broken acceptance criterion
- a security issue
- a broken rule from CLAUDE.md or from an ADR the issue lists

Style and taste findings never block. If a blocking finding is left, go to **When it breaks**
with that reason.

## Checks in place of a human

All of them must pass. When one fails, the developer gets up to 2 extra rounds to fix it
(through `dev-loop`'s developer pane). Still failing → **When it breaks**.

1. On the issue branch, every command under `## Verification` in CLAUDE.md.
2. Every acceptance criterion maps to a test that exists and passes; write down how each one was
   verified. A "Then the user sees…" criterion cannot be verified headless: it does not block,
   note it as a visual check for **Wrapping up the issue**.
3. If CLAUDE.md describes a real-app check (dev server, browser through `chrome-devtools-cli`),
   run it as described, then stop every server you started and close the browser tabs.

## Landing on the integration branch

The only source of changes is this issue's branch.

1. Commit any remaining work on the branch per `core:git`: one commit, or a few if they read
   better.
2. `git checkout <base>`, `git pull --ff-only`, then
   `git merge --no-ff <branch> -m "Merge branch '<branch>' (<ISSUE>)"`.
3. On a merge conflict, run `git merge --abort` and go to **When it breaks**.
4. Run the `## Verification` commands again, this time on the integration branch. If they fail,
   run `git reset --hard ORIG_HEAD` (it undoes only the merge; the branch keeps the work) and go
   to **When it breaks**.
5. `git push origin <base>`, then delete the issue branch locally. **No deploys, ever. No push to
   `main` unless `main` is the integration branch.**

## Wrapping up the issue

- Move it to **In Review** and add the `auto-merged` label with
  `linear issue update <ISSUE> --add-label auto-merged` (`--label` would replace the other
  labels). **Never set it to Done**: the user does the testing and merges the integration branch
  into `main`.
- Comment on the issue with the merge commit hash, the integration branch, what was built, how
  each acceptance criterion was verified, the visual checks left for the user, and any review
  findings left open as non-blocking.
- Check that no process you started is still running. Do not close the Herdr tabs: once the
  `auto-dev` script reads your verdict, it closes every tab and pane the run opened.
- Print `AUTO_DEV: NEXT <ISSUE>`.

## When it breaks

- First commit any unfinished work on the issue branch, as `wip(<scope>): <message>`. Then leave
  that branch alone: no merge, no push, no delete. The integration branch must hold only what it
  held before, and you must be back on it with a clean working tree.
- Keep the issue **In Progress** and comment on it: what failed, the output that shows it, the
  branch name and the open findings.
- Stop any process you started. Do not close the Herdr tabs: after a failure the script keeps
  them, so the user can read the agents.
- Print `AUTO_DEV: FAILED <ISSUE> <reason>`.
