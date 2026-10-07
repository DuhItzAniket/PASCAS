# Phase 41 — Professional UI/UX

## Objective

Layout, shortcuts, themes, and input polish that fit a desktop v1.

## Implementation

- Shortcuts: Enter evaluates everywhere; Esc clears; Ctrl+C copies
  result/history; Ctrl+G opens the graph; graph Ctrl+S/Ctrl+O
  save/load session.
- Dark mode toggle on both windows (graph paper/grid/axes recolor with
  the theme; curves keep their palette).
- Focus discipline: evaluation returns focus to the expression box with
  SelectAll; buttons are TabStop-free; history recall guards the walk
  position.
- Deferred with reasons: command palette (needs a menu/omni-box shell —
  web Phase 43 candidate), full OS-theme following (LCL app theming is a
  project of its own), matrix grid editor (needs `[[..]]` literal
  syntax first).

## Verification

`lazbuild -B` LINKED, launch smoke OK, 18/18 test runners green.
Visual/manual pass recommended (headless here).
