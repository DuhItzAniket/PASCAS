# Phase 24 — Equation Solver

## Objective

Bisection, Newton, secant with convergence reporting, plus exact linear
and quadratic solutions (complex included).

## Implementation

`core/equations/pms.solve.pas` (`PMS.Solve`): the three iterative
methods over AST expressions (scoped binding, iteration counts out,
`ceNoConvergence` with teeth — unbracketed bisection and zero-derivative
Newton refuse). Linear/quadratic coefficients come from *fitting*
(`f(0)`, `f(±1)`) and every fit is verified by back-substitution, so
`sin(x)` is rejected, not hallucinated. Quadratics use the stable
Citizen-q form and return `TComplex` roots (`x²+1 → ±i`, first real use
of `PMS.Complex`).

## Tests

In `tests/unit/test_calc2.lpr` (bisection/Newton/secant on `√2`,
linear, quadratic pair, complex pair, rejection). **Passed.**
