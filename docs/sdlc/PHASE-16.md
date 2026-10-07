# Phase 16 — Rational Arithmetic

## Objective

Exact fractions with canonical reduction — capable of `1/3+1/6 = 1/2`.

## Implementation

`core/rational/pms.rational.pas` (`PMS.Rational`): `Num/Den` (Den > 0,
gcd-reduced), add/sub/mul/div/neg/inv with cross-cancellation and
checked overflow (`ceOverflow`, never wrap), overflow-safe compare with
float fallback, `RFromFloat` via continued fractions (π → 355/113 at
den ≤ 1000, the true best approximant), formatting. The simplifier
(Phase 18) uses this for constant folding; the Double evaluator is
unchanged.

## Tests

`tests/unit/test_rational.lpr` (19 checks, incl. the spec's `1/3+1/6`
and `2/7*7/4`). **Passed.**
