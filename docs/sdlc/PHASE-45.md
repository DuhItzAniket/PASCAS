# Phase 45 — Comprehensive Testing and Quality Gate

## Objective

One command proves shippability; nothing ships on red.

## Implementation

- `scripts/gate.py`: build (console+LCL) → 18 unit runners → golden
  file through the shipped binary (14/14) → pas2js+Node web verify →
  web build. Any step red aborts the release.
- `scripts/golden.py` + `tests/golden/cases.txt`: `[eval]` cases via
  `pmscalc` with abs+rel tolerance (fraction-friendly `1/2` expectations);
  symbolic goldens live with their unit runners by explicit mapping.
- `docs/testing/testing.md`: suites, tolerances, and the honesty rules.
- Manual (headless here): desktop launch smoke, headless-Chrome DOM
  check (eval result present, no console errors).

## Verification

`gate.py` executed end-to-end: all scripted steps green.
