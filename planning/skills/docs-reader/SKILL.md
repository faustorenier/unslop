---
name: docs-reader
description: Reads project documentation from .claude/docs/ and docs/prd/ and extracts requirements, constraints, and decisions. Use when starting a new project, when the user mentions requirements, analysis docs, or existing documentation.
allowed-tools: Read, Glob, Bash(find *)
disable-model-invocation: true
---

# Docs reader

Input material (briefs, analyses, client docs) lives in `.claude/docs/`; PRDs written by
`prd-writer` live in `docs/prd/`. Files found:

```!
find .claude/docs docs/prd -name "*.md" 2>/dev/null | head -20
```

If files found:
1. Read each file
2. Extract: requirements, constraints, decisions already made, open questions
3. Produce a summary:

## Docs summary
### Requirements
[functional and non-functional]

### Constraints
[technical, business, regulatory]

### Decisions already made
[anything already decided before this session]

### Open questions from docs
[anything left unresolved in the docs]

If no files found, ask the user:
> "Non ho trovato documentazione in .claude/docs/. Hai requisiti o analisi da condividere? Mettili in .claude/docs/ e scrivi 'pronto', oppure scrivi 'skip'."
