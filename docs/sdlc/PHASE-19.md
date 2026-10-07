# Phase 19 — Polynomial Engine

## Objective

Reusable polynomial abstraction: construct, operate, evaluate, divide,
interpolate.

## Implementation

`core/polynomial/pms.poly.pas` (`PMS.Poly`): coefficient arrays, Horner
eval, add/sub/mul, `PDivMod` with remainder, derivative, integral,
monic Euclidean GCD (tolerance-guarded), Lagrange interpolation (also
the solver's coefficient extractor in Phase 24), printing
(`x^2-1`). Verified: `(x+1)(x-1)=x^2-1`, `(x^2-1)/(x-1)=x+1`,
`gcd(x^2-1,x-1)=x-1`.

## Tests

`tests/unit/test_poly.lpr` (10 checks). **Passed.**
