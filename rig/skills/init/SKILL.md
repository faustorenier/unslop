---
name: init
description: Set up a project for the rig workflow - git and GitHub repo, a Linear team, CLAUDE.md workflow and verification sections, AGENTS.md, loop-models.json - in an empty folder or an existing repository. Use when the user runs /rig:init.
argument-hint: "[product name]"
disable-model-invocation: true
---

Prepare the current folder for `/rig:dev-loop` and the `auto-dev` loop. Product name: $ARGUMENTS
(empty → ask). Templates are in `templates/` next to this file; the rig scripts are in
`../../bin/` relative to this skill's base directory.

Rules for the whole run:

- **Never overwrite.** An existing file gets only what it is missing; show the exact addition first.
- **Ask before anything outside the folder**: creating a GitHub repo, a Linear team, the
  `~/.local/bin/auto-dev` link, a commit. Show the command, run it only after a yes.
- Gather the answers step by step, then show the full list of changes once, before writing files.

## 1. Diagnose

Report in a short table what exists and what is missing:

- Git repository, branch `main`, `origin` remote on GitHub.
- Stack: package manager (`package-lock.json` → npm, `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn),
  scripts for typecheck, test, build, lint.
- `CLAUDE.md` (and whether it has `## Workflow` and `## Verification`), `AGENTS.md`,
  `loop-models.json`, `.linear.toml`, `.gitignore` entries `.auto-dev/` and `.reviews/`.

## 2. Repository

Only for what is missing:

1. No git repository: `git init -b main`.
2. No stack yet (nothing to build or test): the stack is the user's choice, never this skill's.
   Ask which scaffolding command to use (`npx create-next-app@latest .`, `npm create vite@latest .`,
   ...). Run it on a yes, or let the user run it, then diagnose again. Without a stack the rig has
   no verification commands, so stop until one exists.
3. No `origin`: offer `gh repo create <kebab-name> --private --source=. --remote=origin`. The
   first push waits for the commit in step 6.

## 3. Linear team

One team per product (see `planning:linear`, "New team").

- `.linear.toml` present → show its team (`linear team id --no-input`) and keep it.
- Otherwise list the teams (`linear team list --no-input`) and propose a new team: name = product,
  key = 2–4 capital letters from the name. On a yes, follow "New team" in `planning:linear`:
  create, check the In Review status, `linear config --team <KEY> --sort manual --no-input`,
  `linear team autolinks` (needs the `origin` remote). The user can pick an existing team instead.

## 4. Project files

1. **Verification commands**: from the detected scripts, in this order: typecheck, lint, test,
   build, written for the package manager (`npm run test`, `pnpm test`, ...). They must exit on
   their own: a watch-mode `test` script needs a non-watch form (`vitest run`). Confirm the list
   with the user. No commands at all → stop: the rig needs at least one check.
2. **`CLAUDE.md`**: from `templates/claude-sections.md`, with `{{VERIFICATION_COMMANDS}}` replaced
   by the confirmed commands, one per line. No `CLAUDE.md` → create it with a `# <Product>` title
   and both sections. Existing → append only the missing section; an existing `## Verification`
   is kept as it is, and its commands are the ones the rig uses.
3. **`AGENTS.md`**: from `templates/AGENTS.md` with the same commands. Existing → append only the
   lines it lacks, never rewrite.
4. **`loop-models.json`**: copy `templates/loop-models.json` if missing. Say what it sets
   (developer Claude Sonnet, reviewer Claude Opus, both `high`) and that `/rig:dev-loop` reads it.
5. **`.gitignore`**: add the lines of `templates/gitignore` that are missing.

## 5. This machine

Once per machine, skip what is already in place:

- `~/.local/bin/auto-dev` must be a link to `~/.claude/plugins/marketplaces/unslop/rig/bin/auto-dev.sh`.
  Missing → offer `ln -s` (create `~/.local/bin` if needed, and check it is on `PATH`).
- `herdr --version` and `herdr integration status`: `claude` and `opencode` (if used in
  `loop-models.json`) should be `current`. Otherwise give the `herdr integration install <name>`
  command; the user runs it.

## 6. Close

1. Run `../../bin/preflight.sh`. Outside Herdr its Herdr check fails: say so, it is expected here,
   and every other check must pass.
2. Show `git status` and offer one commit, `chore: set up rig workflow`, with the files this run
   created or changed. Commit and push (`git push -u origin main`) only after a yes.
3. End with the next steps: open Herdr in this folder, `/planning:grill-me` for the first feature,
   then `/rig:dev-loop <ISSUE>` or `auto-dev "<project>"`.
