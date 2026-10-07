# Phase 35 — Multi-Expression Desmos-style Workspace

## Objective

Expression list: independently editable, hidable, reactive entries.

## Implementation

`rendering/graph2d/pms.workspace.pas` (`PMS.Workspace`): owns a
`TDepStore`, one AST per entry, per-viewport sample cache keyed by a
version counter bumped on every change. Sampling refreshes referenced
variables first (lazy `Define` leaves them unevaluated otherwise — a
bug of exactly that shape was caught by tests). Visibility toggles,
delete/clear, per-entry colors.

## Tests

In `tests/unit/test_workspace.lpr` (add/sample/hide/reactive/param/
implicit/delete). **Passed.**
