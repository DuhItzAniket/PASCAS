# Phase 23 — Symbolic Integration Foundation

## Objective

Antiderivatives for the rules we can stand behind; structured
`ceUnsupported` for everything else.

## Implementation

`core/calculus/pms.intsym.pas` (`PMS.IntSym`): constants, `x`, `x^n`
(`n≠-1`), `1/x` and `1/(ax+b)` → `ln`, `sin/cos/exp` of `x` or linear
`ax+b` (with `1/a` correction), sums, constant multiples/quotients.
Indefinite only (+C left to presenters; definite goes through IntNum).
Results simplified, e.g. `∫(2x+3) = 2*x^2/2+3*x`. `x·sin(x)` and
`sin(x²)` honestly refuse.

## Tests

Golden + refusal cases in `tests/unit/test_cas.lpr`. **Passed.**
