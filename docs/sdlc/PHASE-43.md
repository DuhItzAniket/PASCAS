# Phase 43 — Web Desmos-style Experience

## Objective

Multi-expression workspace in the browser with sliders, persistence,
and touch-friendly input.

## Implementation (all in `app/web/`)

- Expression list: add/hide/delete per entry with color dots (same
  palette as desktop); all visible entries plot together.
- Sliders: one button binds every store variable (−5..5); HTML range
  inputs drive `SetVar` → instant replot.
- Persistence: `localStorage` session snapshot on every settled change;
  `#hash` share links import on load (paste any link, it restores).
- Input: pointer events unify mouse + touch pan; wheel zoom; responsive
  canvas sizing; keyboard via native inputs.
- Deliberately skipped: Web Workers — full replots cost milliseconds at
  our sample caps, so worker plumbing buys nothing yet (revisit if a
  profile says otherwise).

## Verification

Headless Chrome: eval result, rendered entry row, no console errors.
