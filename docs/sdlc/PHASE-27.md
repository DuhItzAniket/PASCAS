# Phase 27 — Advanced Linear Algebra

## Objective

LU, QR, eigenvalues/vectors, SVD with numerical honesty.

## Implementation

`core/matrices/pms.linalg.pas` (`PMS.LinAlg`): `LUDecomp` (partial
pivot, `P·A = L·U` verified), `QRDecomp` (modified Gram-Schmidt,
`Q'Q = I` verified), `EigenSym` (cyclic Jacobi for symmetric matrices;
nonsymmetric spectra → `ceUnsupported`, documented v1 scope),
`EigenPower` (dominant pair, general square), `MSVD` via the symmetric
Gram matrix with singular values sorted descending. Verified:
SVD `[[3,2],[2,3]]` → σ = 5,1 with reconstruction.

## Tests

`tests/unit/test_linalg.lpr` (8 checks). **Passed.**
