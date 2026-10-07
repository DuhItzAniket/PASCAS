# Phase 21 — Numerical Differentiation

## Objective

Forward/backward/central finite differences with documented error order.

## Implementation

`core/calculus/pms.diffnum.pas` (`PMS.DiffNum`): the expression plus the
context *is* the function (scoped `EvalAt` saves/restores the variable,
no procedural types to port). Central is O(h²) with a scale-aware
default step; limitations (truncation vs cancellation) documented in the
unit header.

## Tests

In `tests/unit/test_calc2.lpr` (`x^2` at 3, `sin` at 0). **Passed.**
