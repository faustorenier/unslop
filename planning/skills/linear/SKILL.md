---
name: linear
description: Read and update issues, projects and relations on Linear with the `linear` CLI. Use whenever a task touches Linear - reading an issue or its project, changing status, creating issues, commenting, setting "blocked by" relations or writing a decision back.
argument-hint: <what to do, e.g. "read <issue-ID>" or "move <issue-ID> to In Review">
allowed-tools: Bash(linear *)
---

Work on Linear through the `linear` CLI (schpet/linear-cli, already authenticated on the workspace `faustorenier`).
This skill supersedes the Linear MCP server. Docs: https://github.com/schpet/linear-cli.

Each repository belongs to one team, named in its `.linear.toml` (written by `linear config`). With that file,
omit `--team` and the CLI uses the repository's team; `linear team id --no-input` prints it. There is no default team.
If `.linear.toml` is missing:

- Interactive session: ask the user which team the repository belongs to (`linear team list --no-input`), or whether
  to create one (see New team). Then run `linear config --team <KEY> --sort manual --no-input` and tell the user to
  commit `.linear.toml`.
- Headless run (`claude -p`, auto-dev): stop and say the repository has no `.linear.toml`. Never guess a team.

Always pass `--no-input` so a missing value fails instead of waiting on a prompt, and `--yes` to commands that ask
for confirmation. Use `--json` when you need to parse output. When unsure of a flag, run `linear <command> --help`.

## Reading

```sh
linear issue view <issue-ID> --no-input                 # description and comments
linear issue view <issue-ID> --json --no-input          # includes project, state, relations
linear issue relation list <issue-ID> --no-input
linear project list --no-input
linear project view "<project>" --no-input            # the project overview holds the agreed design
linear issue query --project "<project>" --no-input
linear issue query --search "<text>" --no-input
```

`issue list` shows only issues assigned to you; use `issue query` to see the team's issues. Before starting
an issue, read both the issue and its project.

## Status

Workflow states: Backlog, Todo, In Progress, In Review, Done, Canceled, Duplicate. Labels: Feature, Bug, Improvement.

```sh
linear issue update <issue-ID> --state "In Progress" --no-input
linear issue update <issue-ID> --state "In Review" --no-input
```

Set In Progress before the first change and In Review when tests and verification pass; move it back to In Progress
if the user finds a problem. **Never set Done**: the user closes issues.

Do not use `linear issue start`: it checks out a branch named the Linear way, which breaks the branch naming in
`core:git`. Create the branch with git and set the state with `linear issue update <issue-ID>`.

## Writing

Write long Markdown to a file in the scratchpad and pass it with `--description-file`, `--body-file` or
`--content-file`, instead of quoting it on the command line.

```sh
linear issue create --project "<project>" --title "..." \
  --description-file <file> --label Feature --state Backlog --no-input --yes
linear issue update <issue-ID> --description-file <file> --no-input
linear issue comment add <issue-ID> --body-file <file> --no-input --yes
linear issue relation add <issue-ID> blocked-by <issue-ID> --no-input
linear project create --name "<project>" --description "<≤255 chars>" \
  --content-file <file> --status backlog --no-input
linear project update "<project>" --content-file <file> --no-input
```

`--description` on `project update` is the 255 character summary; the design lives in the overview (`--content`).
Updating a description replaces it: read the current text first, edit it, then write the whole text back.

Write issue text short and for people, in English, with implementation details in a collapsible "Agent notes"
section at the end. Linear's collapsible syntax (both the brackets and the closing `+++` are required):

```md
+++ [Agent notes]

Implementation details.

+++
```

To mention an issue or a person, paste its plain Linear URL (`linear issue url <issue-ID>`); `@name` and Markdown links
do not create mentions. Run `linear markdown` for the full reference.

## New team

One team per product. Create a team only when the user asks:

1. `linear team create --name "<Product>" --key <KEY> --no-input --yes`.
2. `linear team states <KEY> --no-input` must list **In Review** (type started). If it is missing, ask the user to
   add it in Linear (team settings, Workflow): the statuses above rely on it.
3. From the repository root: `linear config --team <KEY> --sort manual --no-input`, then commit `.linear.toml`.
4. `linear team autolinks`, so issue IDs in commits and PRs link to Linear.

The labels Feature, Bug and Improvement belong to the workspace, so a new team already has them.

## Anything else

`linear api '<graphql>'` sends a raw GraphQL request, and `linear schema` prints the schema. Exit code 3 means not
found, 4 authentication, 5 Linear unavailable (a write may still have gone through: check before retrying).
