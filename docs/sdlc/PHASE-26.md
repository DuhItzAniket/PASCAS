# Phase 26 — Matrix and Vector Engine

## Objective

Reusable matrix library (never GUI-only): create, operate, solve.

## Implementation

`core/matrices/pms.matrix.pas` (`PMS.Matrix`): row-major 0-based
`TMatrix`, add/sub/mul/scalar/transpose/trace, determinant via
partial-pivot LU (singular → 0, not an error), Gauss-Jordan inverse,
rank, `Ax=b` solve. Singular systems are `ceNoConvergence`;
dimensions `ceInvalidMatrixDim`. Copy-on-write detach (`Copy(D)`)
wherever factoring mutates — record assignment shares the array.
Golden `det([[1,2],[3,4]]) = -2` covered at API level (literal
`[[..]]` syntax arrives with the UI phases).

## Tests

`tests/unit/test_matrix.lpr` (13 checks). **Passed.**
