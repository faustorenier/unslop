---
name: a11y
description: Operational WCAG 2.2 AA checklist and WAI-ARIA APG patterns for interactive components — semantics, keyboard, focus management, contrast, forms, motion. Use when building or reviewing UI, interactive components (dialog, menu, tabs, combobox, disclosure, toast), forms, or when the user mentions accessibility, a11y, WCAG, ARIA, screen readers, keyboard navigation, focus or contrast.
---

# Accessibility (WCAG 2.2 AA)

Target is WCAG 2.2 level AA. Accessibility is built while writing the component, not added
in an audit at the end.

## Order of preference

1. **Native HTML** — `<button>`, `<a href>`, `<label>`, `<dialog>`, `<details>`, `<select>`,
   `<table>`. They come with roles, states and keyboard support for free.
2. **Tested primitives** — Radix / shadcn/ui for dialog, menu, popover, tabs, combobox.
3. **Hand-written ARIA** — only when 1 and 2 cannot do it, following the APG pattern in
   `references/apg-patterns.md` exactly. No ARIA is better than wrong ARIA.

Never put `onClick` on a `<div>` or `<span>`. Links navigate, buttons act.

## Checklist while writing code

**Structure and semantics**
- One `<h1>` per page; headings in order, no levels skipped for styling.
- Landmarks: `<header>`, `<nav>` (with `aria-label` if more than one), `<main>`, `<footer>`.
- `<html lang>` set; `lang` on passages in another language.
- Page `<title>` unique and descriptive; update it on client-side route changes.
- Lists are `<ul>`/`<ol>`, tabular data is `<table>` with `<th scope>`.

**Text alternatives**
- Informative images: `alt` describing the purpose. Decorative: `alt=""`.
- Icon-only buttons: accessible name via `aria-label` or visually hidden text.
- SVG icons next to text: `aria-hidden="true"`.
- Video: captions; audio: transcript.

**Contrast and colour**
- Text 4.5:1; large text (24px, or 18.66px bold) 3:1.
- UI components and focus indicators against adjacent colours: 3:1 (1.4.11).
- Check placeholder, disabled-looking-but-enabled, and text over images. Both themes.
- Colour is never the only signal: errors also have text or an icon, links in prose are
  underlined.

**Keyboard and focus**
- Everything operable with the mouse is operable with the keyboard; no keyboard traps.
- Tab order follows visual order. Never use positive `tabindex`.
- Focus is always visible: use `:focus-visible` with a clear outline, never
  `outline: none` without a replacement.
- Focus not obscured (2.4.11): sticky headers, cookie banners and chat widgets must not
  cover the focused element; use `scroll-padding-top`.
- Skip link to `<main>` as the first focusable element on content-heavy pages.
- After a client-side navigation, move focus to the new page's `<h1>` or main region.
- When content is removed (row deleted, dialog closed), move focus somewhere sensible, never
  leave it on `<body>`.

**Pointer and targets**
- Target size at least 24×24 CSS px, or enough spacing (2.5.8). Prefer 44px on touch.
- Dragging has a single-pointer alternative (2.5.7): sortable lists also get move buttons.
- No action fires on pointer down; it fires on up/click and can be cancelled.

**Forms**
- Every input has a programmatic label (`<label for>` or wrapping `<label>`).
- Required fields marked in text, not only with colour or `*` alone; use `required`.
- Errors: text linked with `aria-describedby`, `aria-invalid="true"` on the field, focus the
  first invalid field on submit.
- Correct `type` and `autocomplete` tokens (`email`, `current-password`, `one-time-code`).
- Accessible authentication (3.3.8): allow paste and password managers; no cognitive puzzles
  without an alternative.
- Redundant entry (3.3.7): do not make users retype information they already gave in the
  same process.
- Status updates (saved, 3 results found) announced with a polite live region.

**Layout and zoom**
- Content works at 320 CSS px wide without horizontal scroll (reflow, 1.4.10).
- Text resizable to 200% without loss; no fixed heights on text containers.
- Respects user text spacing overrides (1.4.12): no clipped text.

**Motion**
- Respect `prefers-reduced-motion: reduce`: remove parallax, scroll-jacking, large
  transforms and autoplay; keep opacity fades at most. Content stays reachable.
- Anything that moves, blinks or auto-updates for more than 5 seconds can be paused.
- Nothing flashes more than 3 times per second.

**Consistency**
- Help (contact, chat, FAQ link) is in the same place on every page (3.2.6).
- Same component, same name, same behaviour across the app.

## Interactive components

For dialog, menu button, tabs, combobox, disclosure/accordion, and toast/live region, read
`references/apg-patterns.md` before writing or reviewing the component: roles, keyboard
interaction and focus rules for each.

## Testing

- Keyboard pass: complete the main flow with Tab, Shift+Tab, Enter, Space, Esc, arrows only.
- Screen reader spot check on the changed component (VoiceOver: Cmd+F5) — name, role, state
  announced correctly.
- Automated: `jest-axe` in component tests, `@axe-core/playwright` in e2e if the project
  has them. Automated tools catch only part of the issues; a clean run is not conformance.
- Browser audit: the `chrome-devtools-mcp:a11y-debugging` skill — **only when the user asks**,
  never on your own initiative.

When reporting, cite the WCAG success criterion number for each finding (e.g. 1.4.3).
