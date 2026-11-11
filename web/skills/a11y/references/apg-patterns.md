# WAI-ARIA APG patterns

Condensed from the WAI-ARIA Authoring Practices Guide (https://www.w3.org/WAI/ARIA/apg/).
Prefer Radix/shadcn primitives, which implement these; use this to build or review one.

## Dialog (modal)

- Native `<dialog>` opened with `showModal()`, or `role="dialog"` + `aria-modal="true"`.
- Accessible name: `aria-labelledby` pointing at the dialog title. `aria-describedby` optional.
- On open: focus the first focusable element, or the least destructive action for
  confirmations, or the title (`tabindex="-1"`) when content is long.
- Tab / Shift+Tab cycle inside the dialog; background is inert (`inert` attribute or
  `showModal()`).
- Esc closes. On close, focus returns to the element that opened it.
- Alert dialogs (confirm destructive actions): `role="alertdialog"`, focus on the safe
  button.

## Menu button and menu

For action menus (Edit, Duplicate, Delete) — not for site navigation, which is a list of links.

- Trigger: `<button aria-haspopup="menu" aria-expanded="false|true" aria-controls>`.
- Menu: `role="menu"`, items `role="menuitem"` (or `menuitemcheckbox` / `menuitemradio`).
- Enter, Space or Down Arrow opens and focuses the first item; Up Arrow opens on the last.
- Up/Down move between items (wrap around), Home/End first/last, typing a character jumps to
  the next item starting with it.
- Enter activates and closes. Esc closes and returns focus to the trigger. Tab closes and
  moves on.
- Roving focus: only one item has `tabindex="0"` at a time, or use `aria-activedescendant`.

## Tabs

- `role="tablist"` (with `aria-label` or `aria-labelledby`), each tab `role="tab"` with
  `aria-selected` and `aria-controls`, each panel `role="tabpanel"` with `aria-labelledby`.
- Only the selected tab is in the tab order (`tabindex="0"`, others `-1`).
- Left/Right arrows move between tabs (Up/Down if vertical, with
  `aria-orientation="vertical"`); Home/End first/last.
- Automatic activation (arrow selects) when panels render instantly; manual activation
  (arrow focuses, Enter/Space selects) when panels load data.
- Tab from the tablist moves into the active panel; give the panel `tabindex="0"` if it has
  no focusable content.

## Combobox (autocomplete / searchable select)

- Input `role="combobox"` with `aria-expanded`, `aria-controls` pointing at the listbox,
  and `aria-autocomplete="list"` (or `both` with inline completion).
- Popup `role="listbox"`, options `role="option"` with `aria-selected`.
- Focus stays in the input; the highlighted option is exposed with
  `aria-activedescendant`.
- Down Arrow opens and moves through options, Up Arrow moves back, Enter selects and closes,
  Esc closes (second Esc clears), Alt+Down opens without moving.
- Announce result counts ("5 results") with a polite live region; announce "no results".
- Visible label always; never rely on the placeholder.

## Disclosure and accordion

- Disclosure: `<button aria-expanded aria-controls>` toggling a region. Native
  `<details>/<summary>` is acceptable for simple cases.
- Accordion: each header is a heading (`<h3>`) containing the button. Enter/Space toggle.
  Optional: Up/Down between headers, Home/End first/last.
- Do not hide content with only CSS while `aria-expanded="true"` says it is open; keep state
  and visibility in sync.

## Toast and live regions

- Status messages: a container with `role="status"` (polite) present in the DOM **before**
  the message is inserted; changing text inside it is what gets announced.
- Errors that need attention now: `role="alert"` (assertive). Use sparingly.
- Toasts do not steal focus. If a toast has an action (Undo), it must also be reachable by
  keyboard (shortcut or a focusable region) and must not disappear while focused or hovered.
- Auto-dismiss at least 5 seconds, longer for longer text; pausable on hover/focus.
- Never put the only copy of an actionable error in a toast.
