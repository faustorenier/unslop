---
name: figma-reader
description: Reads a Figma page via MCP and extracts screens, components, user flows and annotations. Use when the user provides a Figma URL, mentions design, UI, screens, or components to implement.
allowed-tools: mcp__figma
disable-model-invocation: true
---

# Figma reader

Ask the user:
> "Incolla il link della pagina Figma (o scrivi 'skip' se non hai un design)."

If skip: note "No Figma design provided" and continue.

If URL provided:
1. Read the design context from the Figma page via MCP
2. Extract: screens, components, user flows, annotations, spacing and color tokens
3. Produce a summary with this structure:

## Figma summary
### Screens found
[list with name and purpose]

### Key components
[list of reusable components identified]

### User flows
[described as steps]

### Design tokens
[colors, spacing, typography if available]

### Notes
[anything unusual or worth flagging]
