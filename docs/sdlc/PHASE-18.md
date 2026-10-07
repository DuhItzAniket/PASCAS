# Phase 18 — Simplification Engine

## Objective

Rule-based algebraic simplification over the single AST.

## Implementation

`core/algebra/pms.simplify.pas` (`PMS.Simplify`): bottom-up, pure
(input untouched). Closed subtrees fold through the evaluator
(`2*3`, `sin(0)`, `ln(1)` vanish with zero extra rules); symbolic rules
cover `x+0`, `x-0`, `x-x`, `x*1`, `x*0`, `x/1`, `x/x`, `x^0`, `x^1`,
`0^x` (positive const), `1^x`, `--x`. Fixpoint loop capped at 16.
Documented domain assumptions: finite reals, `x/x`-style rules assume
`x<>0`. Variables case-sensitive (evaluator parity); functions and
constants case-insensitive.

## Tests

In `tests/unit/test_cas.lpr` (18 simp cases). **Passed.**
