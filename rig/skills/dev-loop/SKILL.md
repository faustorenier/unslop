---
name: dev-loop
description: Develop one Linear issue with two agents in Herdr - a developer that follows core:tdd and a reviewer that runs core:review, each set in loop-models.json - and drive their review rounds. Use when auto-dev calls it, or when the user asks for dev-loop on an issue.
argument-hint: <ISSUE> [--base <branch>]
disable-model-invocation: true
---

Develop the issue in $ARGUMENTS on its own branch, cut from the base branch (`--base`, default
`main`). You are the orchestrator: you write no production code and no tests yourself. The
developer follows `core:tdd`, the reviewer runs `core:review`; you route work between them.

This skill never merges and never moves the issue to Done. Called by `auto-dev`, it ends at step 5
and the report goes back to `auto-dev`. Called by the user, it also runs step 6.

Load the `herdr` and `planning:linear` skills first. `HERDR_ENV` must be `1`; if it isn't, stop.
Then run `bin/preflight.sh` from this plugin (`../../bin/preflight.sh` relative to this skill's
base directory); if it fails, stop and show its output. Skip it when `rig:auto-dev` called you:
the `auto-dev` script already ran it.

Names used below, with `<id>` the issue ID in lowercase (`fau-42`):

- work dir `.auto-dev/<ISSUE>/` (gitignored), reviews `.reviews/<ISSUE>-r<N>.md`
- agents `dev-<id>` (developer) and `rev-<id>` (reviewer)

## Agents

Read `loop-models.json` at the repository root (the project's shared default), then
`loop-models.local.json` if it exists (a personal, gitignored choice): each role it names
replaces that role from the shared file. Each role has the same shape:

```json
{
  "developer": { "tool": "opencode" },
  "reviewer": { "tool": "claude", "model": "sonnet", "effort": "high" }
}
```

- File or role missing → `developer: {"tool": "opencode"}`, `reviewer: {"tool": "claude", "model": "sonnet"}`.
- `tool`: `claude` or `opencode`. Anything else → stop with `unsupported tool <tool>`.
- `model` missing → the tool's own default (claude: the user's default model; opencode: the model
  last used in its TUI).
  - claude: an alias (`opus`, `sonnet`, `haiku`) or a full model name.
  - opencode: `provider/model`, as `opencode models` lists it (`opencode/deepseek-v4.1-flash-free`).
- `effort` missing → the tool's default.
  - claude: `low`, `medium`, `high`, `xhigh` or `max`.
  - opencode: a variant of the model; names depend on the model (DeepSeek V4.1 Flash Free:
    `low`, `high`, `max`). Needs `model`: `effort` without `model` → stop with that reason. An
    unknown variant makes the agent fail to start: stop and report the error the pane shows.
- Both roles on the same tool and model is allowed; say so in the report as a weaker review.

## 1. Prepare

1. Read the issue, its project, the PRD its Context names and the ADRs in its Constraints
   (`planning:linear`). Check its `blocked-by` relations: a blocker that is neither Done nor
   labelled `auto-merged` → stop, the code it needs is not on the base branch.
2. From the base branch, create the issue branch per `core:git` (`feat/fau-42-<slug>`). Set the
   issue In Progress.
3. Write `.auto-dev/<ISSUE>/brief.md` for the developer, who has no memory of anything else:

   ```md
   # <ISSUE> <title>
   Branch: <branch> (already checked out; stay on it)

   ## How to work
   Follow <absolute path of core/skills/tdd/SKILL.md in ~/.claude/plugins/marketplaces/unslop>,
   only its sections "Before the first cycle", "The cycle", "Anti-cheating rules",
   "What to test", "Loop discipline" and step 1 of "Finish". Commit at each green per
   <absolute path of core/skills/git/SKILL.md>. Follow CLAUDE.md and AGENTS.md.
   Never touch Linear, never push, never merge, never switch branch.

   ## Goal / Acceptance criteria / Out of scope / Constraints
   <copied from the issue, plus the binding parts of the ADRs>

   ## Agent notes
   <from the issue, plus anything you learned reading the code>
   ```

## 2. Open the agents

1. `herdr tab create --label <ISSUE> --cwd "$PWD" --no-focus [--env ...]`; the developer pane is
   `.result.root_pane.pane_id`.
2. `herdr pane split <developer pane> --direction right --cwd "$PWD" --no-focus [--env ...]`; the
   reviewer pane is `.result.pane.pane_id`.
3. Before `agent start`, wait for the shell prompt: `herdr pane wait-output <pane> --match "$(basename "$PWD")" --timeout 20000`.
4. Start each role with `herdr agent start <name> --kind <tool> --pane <pane> -- <args>`:

| Role config | `--env` on the pane | `<args>` |
|---|---|---|
| claude | none | `[--model <model>] [--effort <effort>] --permission-mode auto` |
| opencode, no `model` | none | `--auto` |
| opencode with `model` | `OPENCODE_CONFIG_CONTENT={"agents":{"devloop":{"mode":"primary","model":"<model>[#<effort>]"}},"default_agent":"devloop"}` | `--standalone --auto` |

`--standalone` gives the pane its own opencode server, which reads that config; without it the
TUI attaches to the shared background server and ignores it.

If an agent is `blocked` at startup, read its pane. Claude's "Do you trust this folder?" dialog →
stop and tell the user to open `claude` once in this repository and accept it. Never answer it.

## 3. Develop

```sh
herdr agent prompt dev-<id> "Read .auto-dev/<ISSUE>/brief.md and do exactly what it says. When every criterion is green, write a short summary to .auto-dev/<ISSUE>/dev-r1.md (what you built, test names per criterion, the final test, typecheck and lint output) and reply DONE." --wait --timeout 3600000
```

`--wait` can return while the agent is still working. Until `herdr agent get <name>` reports
`idle` or `done`, run `herdr agent wait <name> --timeout 1800000`; this applies to every prompt
in this skill.

Judge the result from the files and git, not from the developer's words: `git log <base>..<branch>`,
`dev-r<N>.md`, and the `## Verification` commands of CLAUDE.md run by you.

- **Usage limit, any role, any time**: a pane showing a quota, rate or usage limit, or an
  upgrade/subscribe dialog ("Free limit reached", "usage limit", "rate limit", "subscribe"). Never
  answer or dismiss it. Stop at once with reason `<role> <tool> <model> hit its usage limit` and
  the reset time if shown. Check for it whenever a wait returns without the expected file.
- `blocked`: read the pane (`herdr agent read dev-<id> --source recent-unwrapped --lines 120`).
  A question the brief already answers → answer it with `agent prompt`. A permission or approval
  dialog (a command or file action waiting for yes/no) is never answered, not even with no: stop
  and report the command it asked for. Anything else → stop and report it.
- `timeout`: check `herdr agent get dev-<id>`. Still working → wait once more with
  `herdr agent wait dev-<id> --timeout 1800000`. Then stop and report.
- No commits, or `dev-r<N>.md` missing → one follow-up prompt naming what is missing, then stop
  and report.

## 4. Review rounds (at most 3)

For round N:

1. Prompt the reviewer, then wait as in step 3:
   - claude: `/core:review <branch> — write the full report to .reviews/<ISSUE>-r<N>.md, then reply only with that path.`
   - opencode (it cannot load plugin skills): `Review branch <branch> against <base> exactly as
     <absolute path of core/skills/review/SKILL.md> says, for issue <ISSUE> (brief in
     .auto-dev/<ISSUE>/brief.md). Do not fix anything. Write the full report to
     .reviews/<ISSUE>-r<N>.md, then reply only with that path.`

   Both prompts end with: "Work read-only: create no file except the report, and modify, move
   or delete nothing, temporary files included."
   From round 2, add: "Previous reports are in .reviews/<ISSUE>-r*.md; say for each earlier
   finding whether it is fixed."
2. Read the report. Sort findings into **blocking** (bug, broken acceptance criterion, unreal
   test, security issue, broken rule from CLAUDE.md or an ADR) and **non-blocking** (style,
   taste, preferences). Discard a finding only if the report itself shows it is wrong.
3. No blocking findings → go to step 5.
4. Otherwise write `.auto-dev/<ISSUE>/fix-r<N>.md` with the blocking findings (file, line,
   failure scenario) and prompt the developer: "Fix the findings in .auto-dev/<ISSUE>/fix-r<N>.md.
   A behaviour change goes through a new RED → GREEN cycle. Write .auto-dev/<ISSUE>/dev-r<N+1>.md
   and reply DONE." Judge it as in step 3, then start round N+1.

After round 3 the blocking findings still open stay open: report them.

## 5. Report

Return, as the last part of your output:

- developer and reviewer as run (tool, model, effort)
- branch, commits (`git log --oneline <base>..<branch>`), and whether the `## Verification`
  commands pass on the branch
- each acceptance criterion with the test that covers it, and the visual checks left for a human
- open findings, blocking and non-blocking, with the review file they come from

Leave every Herdr tab and pane open and the agents alive: the `auto-dev` script closes them, or the
user does after reading them.

## 6. Finish (only when the user called this skill)

This replaces steps 2–6 of "Finish" in `core:tdd`.

1. Run the `## Verification` commands yourself on the branch and show the output. If one fails,
   send the failure to the developer as a fix round (step 4.4), at most once, then report.
2. If blocking findings are still open or a check still fails: leave the issue In Progress, give
   the report and stop.
3. Otherwise push the branch (`git push -u origin <branch>`) and open the PR against the base
   branch per `core:git`: title as a Conventional Commit, body with what was built, the review
   rounds and open findings, and `Closes <ISSUE>`. Running `/dev-loop` authorizes this push and
   PR; it never authorizes merging.
4. Set the issue to **In Review** (never Done, per `planning:linear`) and post one comment: the
   PR link, what was built, the test per acceptance criterion, the visual checks left for the
   user, and the non-blocking findings with their review file.
5. Give the report with the PR link. The user reviews and merges.
