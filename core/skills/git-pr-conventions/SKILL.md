---
name: git-pr-conventions
description: Enforces Conventional Commits v1.0.0 for commit messages, PR titles, and branch naming. Use when writing a commit message, creating a pull request, naming a branch, writing a changelog, or when the user mentions git, PR, commit, fix, feature, improvement, breaking change, or versioning.
allowed-tools: Bash(git *)
---

# Git & PR conventions

## Commit message format
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | When | SemVer |
|---|---|---|
| `feat` | New feature (your "feature") | MINOR |
| `fix` | Bug fix (your "fix") | PATCH |
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
- Footer: `Closes #123`, `Refs #456`
- One logical change per commit

## PR title

Same format as commit subject: `<type>[scope]: <description>`

## PR body template
```
## Summary
## Changes
## Testing
## Breaking changes
Closes #<issue>
```

## Gotchas

- `improvement` is valid per spec but has no SemVer impact — use it for UX/DX polish
- `refactor` ≠ `improvement`: refactor is pure structural, improvement changes observable behaviour
- Never bundle unrelated changes in one commit
- `feat!` is a breaking change even without a BREAKING CHANGE footer
