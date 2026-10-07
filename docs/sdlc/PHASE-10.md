# Phase 10 — Numeric Evaluator

## Objective

Evaluate any parsed expression to a Double with structured errors.

## Implementation

`core/evaluator/pms.eval.pas` (`PMS.Eval`): `EvalNode` (tree walk) +
`EvalText` (parse → eval → `Ans`). Covers numbers, variables, `Ans`,
`+ - * / ^ mod`, unary `-`/`!`/`%`, calls, assignment. Guards: division
by zero, `0^negative`, negative-base fractional power (real mode),
integer-only factorial (≤170, else overflow), op budget, cancellation.
`funcdef` nodes → `ceUnsupported` (evaluated Phase 31). `0^0 = 1`
(combinatorial convention, documented). All recursion uses parenthesized
calls (Phase 08 quirk rule).

Verified live: `bin/pmscalc "2 + 3 * 4"` → `14`.

## Tests

`tests/unit/test_eval.lpr` (shared with Phases 11–12): golden values,
variables/`Ans`, every structured error path. **Passed.**
