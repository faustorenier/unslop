---
name: product-ui
description: Builds product interfaces — dashboards, admin panels, back-office tools, data tables, forms with validation, and loading/empty/error states — with semantic design tokens (Tailwind 4 @theme) on shadcn/Radix primitives. Use when building or reviewing app screens, CRUD views, forms, tables, or design tokens. Not for landing pages or portfolios (use design-taste-frontend).
---

# Product UI

Product screens are used daily by people who want to finish a task. Clarity, speed and
predictability beat novelty. Every rule below serves that.

## Hierarchy and density

- One primary action per view, visually dominant. Secondary actions are outline or ghost;
  destructive actions are never primary and always confirm or allow undo.
- Tight type scale: page title, section title, body, caption. Three weights at most.
- Density follows usage: a table an operator scans all day is compact (32–40px rows); a
  settings page used twice a year is airy. Never shrink touch targets below 24px.
- Layout: persistent navigation, page header (title + primary action + filters), content.
  Do not hide primary navigation behind a menu on desktop.
- Numbers and units: tabular figures (`tabular-nums`), consistent locale formatting via
  `Intl.NumberFormat` / `Intl.DateTimeFormat`, never hand-built strings.

## Every data view has four states

Design and build all four, not just success:

| State | Rule |
|---|---|
| Loading | Skeleton that mirrors the final layout (same rows, columns, card sizes). No full-page spinner for partial data. Keep previous data visible while refetching. |
| Empty | Distinguish **first use** (explain the value, one call to action) from **no results** (say which filters are active, offer "clear filters"). |
| Error | Say what failed in plain words, keep the user's input, offer retry. Log the technical detail, do not show stack traces. |
| Success | The real content. Long-running mutations show optimistic or pending feedback. |

Partial failure (one widget of a dashboard fails) degrades that widget only.

## Forms

- One schema (Zod) shared by client validation and server validation. The server is the
  authority; client validation is a convenience.
- Every input has a visible `<label>`. Placeholder is an example, never the label.
- Validate on blur and on submit; once a field has an error, revalidate on change so the
  error clears as soon as it is fixed. Never show errors while the user is still typing a
  field for the first time.
- Error text sits under the field, says how to fix it ("Use at least 8 characters"), and is
  linked with `aria-describedby` (see `a11y`).
- On failed submit, move focus to the first invalid field (React Hook Form does this with
  `shouldFocusError`) and show a summary only for long forms.
- Submit button: enabled until clicked, then disabled with a pending label while the request
  runs. Prevent double submit. Keep the form filled on server error.
- Group related fields with `<fieldset>`/`<legend>`. Use the right `type`, `inputMode` and
  `autocomplete` on every field.
- Long forms: sections or steps with saved progress; warn before leaving with unsaved changes.

Next.js: Server Actions + `useActionState` returning field errors from the same Zod schema.
SPA: React Hook Form + `zodResolver`.

## Tables

- Numbers right-aligned with tabular figures; text left-aligned; dates in one format.
- Above ~100 rows, sort, filter and paginate on the server, with state in the URL query so
  views are shareable and survive refresh.
- Row actions in a trailing menu; bulk actions appear when rows are selected, with a count.
- Sticky header always; sticky first column when the table scrolls horizontally.
- Truncate long text with a tooltip or expandable row, never let one cell break the layout.
- Mobile: do not squeeze a 10-column table. Prioritise columns or switch to a card list.
- Headless table logic: TanStack Table. Build the markup with real `<table>` elements.

## Design tokens (Tailwind 4)

Components use semantic tokens only. Raw palette values live in one place.

```css
@import "tailwindcss";

:root {
  --surface: oklch(0.99 0 0);
  --danger: oklch(0.58 0.22 27);
}
.dark {
  --surface: oklch(0.18 0 0);
  --danger: oklch(0.68 0.19 27);
}

@theme inline {
  --color-surface: var(--surface);
  --color-danger: var(--danger);
}
```

This yields `bg-surface`, `text-danger`, and dark mode switches by changing the variables,
not by adding `dark:` to every component.

- Name tokens by role (`surface`, `muted`, `border`, `primary`, `danger`, `success`), never by
  colour (`blue-500`) inside components.
- Spacing, radius and shadows also come from tokens. No arbitrary values (`p-[13px]`) unless
  matching an external constraint.
- Check every token pair for contrast in both themes (see `a11y`).

## Components: shadcn/ui and Radix

- Compose on top of the primitives. Never rebuild dialog, dropdown menu, popover, select,
  combobox or tabs by hand: focus trapping and keyboard support are what you would get wrong.
- Customise through tokens and variants (`cva`), not by forking each component's styles.
- If the official shadcn skill is installed in the project, follow it for the CLI and for
  adding components; it reads `components.json`.
- Toasts confirm completed actions; they never carry the only copy of an error the user must
  act on.

## Verification

- Logic (validation rules, state transitions, table query building) goes through `core:tdd`.
- Visual result: describe what to check — the four states, both themes, the narrowest
  breakpoint, keyboard-only use of the main flow — and let the user verify.
