# Phase 22 — Numerical Integration

## Objective

Trapezoidal, Simpson, and adaptive Simpson with error estimation.

## Implementation

`core/calculus/pms.intnum.pas` (`PMS.IntNum`): `ITrap`/`ISimp` (Simpson
auto-evens N) plus `IAdaptSimp` — recursive Richardson-corrected
adaptive Simpson, depth capped at 20 with an interval guard;
non-convergence reported. Verified: `∫x² = 1/3`, `∫sin = 2` over 0..π.

## Tests

In `tests/unit/test_calc2.lpr`. **Passed.**
