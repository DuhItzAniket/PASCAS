# Phase 15 — Complex Number Engine

## Objective

Robust complex arithmetic as a pure value library (records in/out).

## Implementation

`core/complex/pms.complex.pas` (`PMS.Complex`): `TComplex` + add sub mul
div neg conj `|.|` arg, exp, principal ln/sqrt, sin/cos, general + integer
`pow` (exact integer path, no log-branch error), `CFormat`
(`3+4i`/`-i`/`2.5`). Failable ops (div/ln/pow) report `TCalcError`;
total ops stay total. Verified: `i^2=-1`, Euler `e^{iπ}=-1`,
`(3+4i)/(1-2i)=-1+2i`, `sqrt(3+4i)=2+i`.

Expression-level `i`/display integration is deliberately deferred to the
consumers that need values flowing (solver/workspace); the `nmComplex`
mode flag from Phase 12 is their branch point. No dead abstraction: the
solver (Phase 24) and linear algebra (Phase 27) build on this unit.

## Tests

`tests/unit/test_complex.lpr` (25 checks). **Passed.**
