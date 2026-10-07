# Phase 11 — Scientific Functions

## Objective

All spec scientific functions with domain checking, honoring DEG/RAD/GRAD.

## Implementation

`core/evaluator/pms.funcs.pas` (`PMS.Funcs`): sin cos tan asin acos atan
sinh cosh tanh ln log(exp base-10) exp sqrt cbrt abs floor ceil round.
Case-insensitive names. Conventions: `round` is half-away-from-zero,
`cbrt` is real for negatives (Newton-polished to machine precision —
raw `Power(x,1/3)` errs ~1e-7 on exact cubes), `tan` returns the float
naturally, overflow (`exp(1000)`) → `ceOverflow`.

## Tests

Covered by `tests/unit/test_eval.lpr` (degree-mode `sin(90)=1`,
`asin(1)=90`, domain errors for `sqrt(-1)`/`ln(-1)`/`asin(2)`).
**Passed.**
