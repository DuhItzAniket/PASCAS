# Phase 06 — Core Domain Model

## Objective

Shared vocabulary for every later phase: structured errors, hard limits,
explicit evaluation context. No GUI yet.

## Implementation

`core/pms.types.pas` (`PMS.Types`):

- `TCalcError`: 14 structured codes (syntax → cancelled). Human text via
  `CalcErrorMessage`. UI never sees raw exceptions for user errors.
- Hard limits: input 4096 chars, depth 64, ops 10000, matrix dim 64,
  200 solver iterations, 4096 samples.
- `TEvalContext`: angle mode, `Ans`, op-budget counter (`CheckOps`),
  cancellation flag, name→value bindings. Explicitly owned (create/use/free).

## Tests

`tests/unit/test_types.lpr`: messages, defaults, set/get/overwrite,
budget exhaustion. **8/8 passed** via `scripts/runtests.py`.
