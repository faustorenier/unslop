---
name: git
description: Enforces Conventional Commits v1.0.0 for commit messages, PR titles, and branch naming. Use when writing a commit message, creating a pull request, naming a branch, writing a changelog, or when the user mentions git, PR, commit, fix, feature, improvement, breaking change, or versioning.
allowed-tools: Bash(git *)
---

# Git & PR conventions

Single source of truth for git in every project. Other skills (`core:tdd`) defer here.

## When to commit

- Run `git commit` only when the user asks, or inside `core:tdd` on a feature branch.
- Never commit on `main`/`master`. Create a branch first (see Branch naming).
- Otherwise, end the task with the commit message as a copy-pasteable block.
- Keep any `Co-Authored-By` trailer the harness asks for.

## Commit message format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | When | SemVer |
|---|---|---|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `improvement` | Improves existing behaviour, no new feature or bug fix | none |
| `refactor` | Code restructure, no behaviour change | none |
| `perf` | Performance improvement | none |
| `chore` | Tooling, deps, build, no production code | none |
| `docs` | Documentation only | none |
| `test` | Tests only | none |
| `ci` | CI/CD config | none |
| `style` | Formatting, whitespace | none |

Breaking change: append `!` after type, or add `BREAKING CHANGE:` footer.

## Rules

- Description: imperative, present tense, lowercase, no trailing period
- Subject line ≤ 72 characters
- Scope: optional noun in parentheses — `fix(parser):`, `feat(api):`
- Body: explain *why*, not what. Wrap at 72 chars
- Footer: `Closes <issue>`, `Refs <issue>` (see Issue IDs)
- One logical change per commit
- Always English, even when the conversation is in another language

## Issue IDs

`<issue>` is the ID in the project's tracker, written the way that tracker recognises it:

| Tracker | In footers and PR body | In branch names |
|---|---|---|
| GitHub Issues | `#42` | `42` |
| Linear | `FAU-42` | `fau-42` |

Never write `#42` for a Linear issue: GitHub reads it as its own issue or PR number, and Linear
does not link it. With the Linear GitHub integration, the ID in the branch name links the PR and
`Closes FAU-42` moves the issue when the PR merges.

## Branch naming

`<type>/<issue>-<short-slug>`, lowercase, hyphens: `feat/42-login-form`, `fix/fau-108-cart-total`.
No issue → `<type>/<short-slug>`. Type is one of the commit types above.

## PR title

Same format as commit subject: `<type>[scope]: <description>`

## PR body template
```
## Summary
## Changes
## Testing
## Breaking changes
Closes <issue>
```

## Gotchas

- `improvement` is valid per spec but has no SemVer impact — use it for UX/DX polish
- `improvement` is rejected by commitlint `config-conventional`. If the project uses it,
  use `feat`/`fix` instead, or ask before adding the type to the commitlint config
- `refactor` ≠ `improvement`: refactor is pure structural, improvement changes observable behaviour
- Never bundle unrelated changes in one commit
- `feat!` is a breaking change even without a BREAKING CHANGE footer
