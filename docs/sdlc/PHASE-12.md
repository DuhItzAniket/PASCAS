# Phase 12 — Constants and Calculator Modes

## Objective

Central constant registry; DEG/RAD/GRAD and real/complex mode handling.

## Implementation

- `core/constants/pms.consts.pas` (`PMS.Consts`): pi e phi tau sqrt2
  sqrt3 + SI physics (c G h hbar kB Na R me mp qe). One table, no
  literals elsewhere. Evaluator lookup order: user variables → `Ans` →
  constants (users may shadow, documented).
- Modes: `TEvalContext.AngleMode` drives trig (`PMS.Funcs.ToRad/FromRad`);
  new `TEvalContext.NumberMode` (`nmReal` default): real-mode domain
  errors stay until Phase 15 fills the complex branch.

## Tests

Covered by `tests/unit/test_eval.lpr` (`2pi`, `phi`, `tau`, `ln(e)`,
degree/radian switching). **Passed.**
