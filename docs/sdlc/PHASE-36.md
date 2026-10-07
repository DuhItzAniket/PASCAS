# Phase 36 — Sliders and Interactive Parameters

## Objective

Bind a variable to a slider; the graph updates immediately.

## Implementation

Core: `TWorkspace.BindParam/UnbindParam/ParamInfo` (range + step over
an existing store variable; `SetVar` does the rest through the version
counter). Desktop: graph window "Detect sliders" binds every store
variable (−5..5) and builds live trackbars. Propagation is the Phase 31
dependency graph — no new evaluation path.

## Tests

Bind/set/resample covered in `tests/unit/test_workspace.lpr`.
**Passed.** Live drag verified by manual UI check (headless here).
