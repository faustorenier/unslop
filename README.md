# claude-skills

Personal Claude Code plugin marketplace (`fausto-skills`). Each top-level folder is a plugin
(a bundle of skills). Skills are invoked as `<bundle>:<skill>`, e.g. `core:tdd-loop`.

| Bundle | Skills | Enable |
|---|---|---|
| `core` | git-pr-conventions, tdd-loop, systematic-debugging, fresh-context-review, typescript-clean-code | user scope, always |
| `planning` | grill-me, to-ticket, to-prd, to-adr, to-tickets, linear | user scope, always |
| `web` | design-taste-frontend, product-ui, a11y, seo-aeo-best-practices, vercel-react-best-practices | per project |
| `sanity` | content-modeling-best-practices | per project |
| `python` | python-clean-code | per project |

## Install (once per machine)

```
/plugin marketplace add faustorenier/claude-skills
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

1. From the project root, once per bundle (`web`, `sanity`, `python`):

   ```
   claude plugin install web@fausto-skills --scope project
   ```

   This writes `enabledPlugins` to `<project>/.claude/settings.json`. Use `--scope local` instead
   to enable it only for yourself (`.claude/settings.local.json`, usually git-ignored).

2. Add the marketplace source to the same file. The install command does not write it, and
   without it Claude Code on another machine or for a collaborator cannot find `fausto-skills`:

   ```json
   {
     "extraKnownMarketplaces": {
       "fausto-skills": {
         "source": { "source": "github", "repo": "faustorenier/claude-skills" }
       }
     },
     "enabledPlugins": {
       "web@fausto-skills": true
     }
   }
   ```

3. Commit `.claude/settings.json`. Whoever opens the project is prompted to add the marketplace
   and install the bundle; they need read access to this private repo.

4. Check: `claude plugin list` shows the bundle with `Scope: project`, and a new session in the
   project lists `web:*` skills while sessions elsewhere do not.

Update a project bundle after a push: `claude plugin update web@fausto-skills --scope project`.

## Optional third-party skills per project

Official or widely used skills that complement `web`. Install them only in the projects that
use the library. `npx skills add` copies files into `<project>/.claude/skills/`: commit them,
and re-run the command to update.

| Skill | Use with | Install (from the project root) |
|---|---|---|
| shadcn/ui (official) | `product-ui` in projects with `components.json` | `npx skills add shadcn/ui` |
| accessibility (addyosmani, MIT) | audit-oriented alternative or complement to `a11y` | `npx skills add addyosmani/web-quality-skills --skill accessibility --agent claude-code` |

## Workflow

| Situation | Path |
|---|---|
| New change, feature or product | `/planning:grill-me` → one slice: `/planning:to-ticket`; more: `/planning:to-prd` → `/planning:to-tickets` (ADRs via `to-adr`, rules in `planning/skills/_shared/workflow.md`) |
| Behaviour change with clear scope | plan mode → `tdd-loop` → verification |
| Bug | `systematic-debugging` → failing test → `tdd-loop` |
| Visual work (layout, animation, 3D) | no TDD; describe what to check visually |
| Landing, portfolio, marketing site | `design-taste-frontend` + `seo-aeo-best-practices` + `a11y` |
| Dashboard, admin, forms, tables | `product-ui` + `a11y`; logic through `tdd-loop` |
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
   the model cannot invoke them and their description costs no context. Today:
   `planning:grill-me`, `planning:to-ticket`, `planning:to-prd`, `planning:to-adr`, `planning:to-tickets`.
3. Push, then update as shown in Install. Do not add `version` to
   `plugin.json`: without it the commit SHA is the version, so every push is picked up.
