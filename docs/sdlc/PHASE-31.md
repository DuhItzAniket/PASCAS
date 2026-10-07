# Phase 31 — Dependency and Reactive Evaluation Engine

## Objective

`a = 2`, `f(x) = a*x+b`: definitions with a dependency graph where
changing `a` updates everything downstream.

## Implementation

`core/algebra/pms.deps.pas` (`PMS.Deps`): `TDepStore` owns a context
plus var/func entries with cached ASTs. Key design: user calls are
*inlined by substitution* (pure transform, depth-capped), so the Double
evaluator remains the only numeric path — no duplicated logic.
Dirty flags propagate transitively; evaluation is DFS with a visiting
stack (cycles → `ceUnsupported`). `EvalFunc` materializes variable
dependencies before binding params (a real bug of that exact shape was
caught by tests and fixed). Verified: `f(4)=11`, slide `a→5`,
`f(4)=23`, nested `g(y)=f(y)+b`, chained `c=a`, cycle refusal.

## Tests

In `tests/unit/test_units_deps.lpr`. **Passed.**
