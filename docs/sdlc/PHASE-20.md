# Phase 20 — Symbolic Differentiation

## Objective

Differentiate constants, variables, powers, sums, products, quotients,
and elementary functions — with readable output.

## Implementation

`core/calculus/pms.diffsym.pas` (`PMS.DiffSym`): product/quotient/chain
rules, constant-exponent power rule, general `u^v` via logarithmic
differentiation, full function table (trig, inverse trig, hyperbolic,
exp/ln/log/sqrt). Non-smooth (`abs/floor/...`) and multi-arg shapes →
`ceUnsupported`. Every result passes through the simplifier:
`d/dx(x^2) = 2*x`, `d/dx(x·sin x) = sin(x)+x*cos(x)`.

## Tests

Golden cases in `tests/unit/test_cas.lpr`. **Passed.**
