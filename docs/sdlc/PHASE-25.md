# Phase 25 — Limits and Advanced Calculus

## Objective

Foundational limit engine: exact where possible, numeric with a
stability contract otherwise.

## Implementation

`core/calculus/pms.limits.pas` (`PMS.Limits`): direct substitution →
simplify-and-retry (removable factors) → two-sided numeric approach
requiring agreement *and* round-to-round stability. Consistent blowup
surfaces as ±Infinity (useful for asymptote detection in Phase 38);
`lim sin(x)/x = 1` verified; two-sided `1/x` at 0 honestly diverges.

## Tests

In `tests/unit/test_calc2.lpr`. **Passed.**
