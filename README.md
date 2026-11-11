# claude-skills

Personal Claude Code plugin marketplace (`fausto-skills`). Each top-level folder is a plugin
(a bundle of skills). Skills are invoked as `<bundle>:<skill>`, e.g. `core:tdd-loop`.

| Bundle | Skills | Enable |
|---|---|---|
| `core` | git-pr-conventions, commit, tdd-loop, systematic-debugging, fresh-context-review, typescript-clean-code | user scope, always |
| `planning` | grill-me, prd-writer, slice-backlog, github-project-setup, docs-reader, figma-reader | user scope, always |
| `web` | design-taste-frontend, seo-aeo-best-practices, vercel-react-best-practices | per project |
| `sanity` | content-modeling-best-practices | per project |
| `python` | python-clean-code | per project |

## Install (once per machine)

```
/plugin marketplace add <owner>/claude-skills
/plugin install core@fausto-skills
/plugin install planning@fausto-skills
```

GitHub is the only source. After a push, refresh the catalog and then the installed bundles,
and restart Claude Code:

```
claude plugin marketplace update fausto-skills
claude plugin update core@fausto-skills
claude plugin update planning@fausto-skills
```

## Enable a bundle in one project

Add to `<project>/.claude/settings.json` (commit it, so collaborators get the same setup):

```json
{
  "extraKnownMarketplaces": {
    "fausto-skills": { "source": { "source": "github", "repo": "<owner>/claude-skills" } }
  },
  "enabledPlugins": {
    "web@fausto-skills": true
  }
}
```

## Workflow

| Situation | Path |
|---|---|
| Vague brief, new product or feature | `/planning:grill-me` → `prd-writer` → `slice-backlog` → `github-project-setup` (asks first) |
| Behaviour change with clear scope | plan mode → `tdd-loop` → verification |
| Bug | `systematic-debugging` → failing test → `tdd-loop` |
| Visual work (layout, animation, 3D) | no TDD; describe what to check visually |
| Done, before merge | `fresh-context-review` (runs in a forked context) or `/code-review` |

## Ralph loop + TDD recipe

`ralph-loop` is the outer loop (re-feeds the prompt on stop), `tdd-loop` is the discipline inside
each iteration. Run it on a feature branch: `tdd-loop` commits at each green and Ralph reads the
git history to see previous work.

```
/ralph-loop "Work on issue #42 using the core:tdd-loop skill. One acceptance criterion per
iteration. Output <promise>ALL_GREEN</promise> only when every criterion is green and the
full suite passes." --completion-promise ALL_GREEN --max-iterations 20
```

Always set `--max-iterations`. Review the result outside the loop with `fresh-context-review`.

## Adding or editing a skill

Work in any clone of this repo, never in `~/.claude/plugins/marketplaces/`, which Claude Code
overwrites on update.

1. Create `<bundle>/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Use `disable-model-invocation: true` for skills that should run only via `/<bundle>:<name>`:
   the model cannot invoke them and their description costs no context. Today: `core:commit`,
   `planning:grill-me`, `planning:docs-reader`, `planning:figma-reader`.
3. Push, then update as shown in Install. Do not add `version` to
   `plugin.json`: without it the commit SHA is the version, so every push is picked up.
