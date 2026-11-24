---
name: dev-loop
description: Drive one Linear issue through two agents in Herdr - a developer that follows core:tdd and a reviewer that runs core:review, both configured in loop-models.json - including their review rounds. Use when auto-dev calls it, or when the user asks for dev-loop on an issue.
argument-hint: <ISSUE> [--base <branch>]
disable-model-invocation: true
---

## Role and limits

You are the **conductor** for the issue in $ARGUMENTS. It is developed on its own branch, cut
from the base branch (`--base`, default `main`). You write no production code and no tests: the
developer follows `core:tdd`, the reviewer runs `core:review`, and you route work between them.

This skill never merges and never moves the issue to Done. When `auto-dev` calls it, it ends
after **Hand-off** and the report goes back to `auto-dev`. When the user calls it, it goes on
with **Closing out**.

Names, files and the agent config are under **Reference** at the end.

## Before anything

1. Load the `herdr` and `planning:linear` skills. `HERDR_ENV` must be `1`; if it is not, stop.
2. Run this plugin's `bin/preflight.sh` (`../../bin/preflight.sh` relative to this skill's base
   directory). If it fails, stop and show its output. When `rig:auto-dev` called you, skip it:
   the `auto-dev` script has already run it.
3. Resolve both roles as **Agent config** describes. Any stop it calls for happens now, before
   **Groundwork**.

## Groundwork

1. Read the issue, its project, the PRD named in its Context and the ADRs in its Constraints
   (`planning:linear`). Check its `blocked-by` relations: if a blocker is neither Done nor
   labelled `auto-merged`, stop, because the code it needs is not on the base branch.
2. Create the issue branch from the base branch per `core:git` (`feat/fau-42-<slug>`) and set
   the issue In Progress.
3. Write `.auto-dev/<ISSUE>/task.md`, the brief for the developer, who remembers nothing else:

   ```md
   # <ISSUE> <title>
   Branch: <branch> (already checked out; stay on it)

   ## Working rules
   Follow <absolute path of core/skills/tdd/SKILL.md in ~/.claude/plugins/marketplaces/unslop>,
   only its sections "Before the first cycle", "The cycle", "Anti-cheating rules",
   "What to test", "Loop discipline" and step 1 of "Finish". Commit at each green per
   <absolute path of core/skills/git/SKILL.md>. Follow CLAUDE.md and AGENTS.md.
   Never touch Linear, never push, never merge, never switch branch.

   ## What to build
   <goal, acceptance criteria, out of scope and constraints copied from the issue, plus the
   binding parts of the ADRs>

   ## Notes
   <from the issue, plus anything you learned reading the code>
   ```

## Spawning the agents

1. `herdr tab create --label <ISSUE> --cwd "$PWD" --no-focus [--env ...]`: the developer pane is
   `.result.root_pane.pane_id`.
2. `herdr pane split <developer pane> --direction right --cwd "$PWD" --no-focus [--env ...]`: the
   reviewer pane is `.result.pane.pane_id`.
3. Wait for the shell prompt before `agent start`: `herdr pane wait-output <pane> --match "$(basename "$PWD")" --timeout 20000`.
4. Start each role (`build-<id>` on the developer pane, `check-<id>` on the reviewer pane) with
   `herdr agent start <name> --kind <tool> --pane <pane> -- <args>`:

| Role config | `<args>` | `--env` on the pane |
|---|---|---|
| claude | `[--model <model>] [--effort <effort>] --permission-mode auto` | none |
| opencode, no `model` | `--auto` | none |
| opencode with `model` | `--standalone --auto` | `OPENCODE_CONFIG_CONTENT={"agents":{"rigbuild":{"mode":"primary","model":"<model>[#<effort>]"}},"default_agent":"rigbuild"}` |

Only `--standalone` gives the pane its own opencode server, which reads that config; otherwise
the TUI attaches to the shared background server and ignores it.

An agent `blocked` at startup: read its pane. If it shows Claude's "Do you trust this folder?"
dialog, stop and tell the user to open `claude` once in this repository and accept it. Never
answer that dialog.

## Build phase

```sh
herdr agent prompt build-<id> "Read .auto-dev/<ISSUE>/task.md and do exactly what it says. When every criterion is green, write a short summary to .auto-dev/<ISSUE>/build-r1.md (what you built, test names per criterion, the final test, typecheck and lint output) and reply DONE." --wait --timeout 3600000
```

`--wait` may return while the agent is still working. For this and every other prompt in this
skill: as long as `herdr agent get <name>` does not report `idle` or `done`, run
`herdr agent wait <name> --timeout 1800000`.

Judge the outcome from git and the files, never from the developer's words:
`git log <base>..<branch>`, `build-r<N>.md`, and the `## Verification` commands of CLAUDE.md,
run by you.

| Situation | What to do |
|---|---|
| **Usage limit**, any role, any time: a pane shows a quota, rate or usage limit, or an upgrade/subscribe dialog ("Free limit reached", "usage limit", "rate limit", "subscribe") | Never answer or dismiss it. Stop at once with reason `<role> <tool> <model> hit its usage limit`, plus the reset time if shown. Look for it whenever a wait returns without the expected file. |
| `blocked` | Read the pane (`herdr agent read build-<id> --source recent-unwrapped --lines 120`). A question the brief already answers → answer it with `agent prompt`. A permission or approval dialog (a command or file action waiting for yes/no) is never answered, not even with no: stop and report the command it asked for. Anything else → stop and report it. |
| `timeout` | Check `herdr agent get build-<id>`. Still working → wait once more with `herdr agent wait build-<id> --timeout 1800000`. Then stop and report. |
| No commits, or `build-r<N>.md` missing | One follow-up prompt naming what is missing, then stop and report. |

## Check rounds (three at most)

For round N:

1. Prompt the reviewer, then wait as in **Build phase**:
   - claude: `/core:review <branch> — write the full report to .reviews/<ISSUE>-r<N>.md, then reply only with that path.`
   - opencode (it cannot load plugin skills): `Review branch <branch> against <base> exactly as
     <absolute path of core/skills/review/SKILL.md> says, for issue <ISSUE> (brief in
     .auto-dev/<ISSUE>/task.md). Do not fix anything. Write the full report to
     .reviews/<ISSUE>-r<N>.md, then reply only with that path.`

   Both prompts end with: "Work read-only: create no file except the report, and modify, move
   or delete nothing, temporary files included."
   From round 2 on, also add: "Previous reports are in .reviews/<ISSUE>-r*.md; say for each
   earlier finding whether it is fixed."
2. Read the report and sort its findings into **blocking** (bug, broken acceptance criterion,
   unreal test, security issue, broken rule from CLAUDE.md or an ADR) and **non-blocking**
   (style, taste, preferences). Drop a finding only when the report itself shows it is wrong.
3. Nothing blocking → **Hand-off**.
4. Otherwise list the blocking findings (file, line, failure scenario) in
   `.auto-dev/<ISSUE>/findings-r<N>.md` and prompt the developer: "Fix the findings in
   .auto-dev/<ISSUE>/findings-r<N>.md. A behaviour change goes through a new RED → GREEN cycle.
   Write .auto-dev/<ISSUE>/build-r<N+1>.md and reply DONE." Judge it as in **Build phase**, then
   start round N+1.

Blocking findings still open after round 3 stay open: put them in the report.

## Hand-off

End your output with:

- developer and reviewer as they actually ran (tool, model, effort)
- branch, commits (`git log --oneline <base>..<branch>`), and whether the `## Verification`
  commands pass on the branch
- each acceptance criterion with the test that covers it, and the visual checks left for a human
- open findings, blocking and non-blocking, with the review file each comes from

Leave every Herdr tab and pane open and every agent alive: the `auto-dev` script closes them, or
the user does after reading them.

## Closing out (user-invoked only)

This takes the place of steps 2–6 of "Finish" in `core:tdd`.

1. Run the `## Verification` commands yourself on the branch and show the output. If one fails,
   send the failure to the developer as a fix round (item 4 of **Check rounds**), at most once,
   then report.
2. If blocking findings are still open or a check still fails: leave the issue In Progress, give
   the report and stop.
3. Otherwise push the branch (`git push -u origin <branch>`) and open the PR against the base
   branch per `core:git`: a Conventional Commit title, and a body with what was built, the review
   rounds, the open findings and `Closes <ISSUE>`. Running `/dev-loop` authorizes this push and
   this PR; it never authorizes merging.
4. Move the issue to **In Review** (never Done, per `planning:linear`) and post one comment: the
   PR link, what was built, the test per acceptance criterion, the visual checks left for the
   user, and the non-blocking findings with their review file.
5. Give the report with the PR link. Reviewing and merging is up to the user.

## Reference

### Naming

`<id>` is the issue ID in lowercase (`fau-42`).

| What | Name |
|---|---|
| work dir (gitignored) | `.auto-dev/<ISSUE>/` |
| review reports | `.reviews/<ISSUE>-r<N>.md` |
| developer agent | `build-<id>` |
| reviewer agent | `check-<id>` |

### Agent config

Read `loop-models.json` at the repository root (the project's shared default), then
`loop-models.local.json` if it exists (a personal, gitignored choice): every role it names
replaces the same role from the shared file. Both roles have this shape:

```json
{
  "developer": { "tool": "opencode" },
  "reviewer": { "tool": "claude", "model": "sonnet", "effort": "high" }
}
```

| Field | Rule |
|---|---|
| file or role missing | `developer: {"tool": "opencode"}`, `reviewer: {"tool": "claude", "model": "sonnet"}` |
| `tool` | `claude` or `opencode`. Anything else → stop with `unsupported tool <tool>`. |
| `model` | Missing → the tool's own default (claude: the user's default model; opencode: the model last used in its TUI). claude takes an alias (`opus`, `sonnet`, `haiku`) or a full model name; opencode takes `provider/model`, as `opencode models` lists it (`opencode/deepseek-v4.1-flash-free`). |
| `effort` | Missing → the tool's default. claude: `low`, `medium`, `high`, `xhigh` or `max`. opencode: a variant of the model, whose names depend on the model (DeepSeek V4.1 Flash Free: `low`, `high`, `max`); it needs `model`, so `effort` without `model` → stop with that reason. An unknown variant makes the agent fail to start: stop and report the error the pane shows. |

The same tool and model on both roles is allowed; say so in the report as a weaker review.
