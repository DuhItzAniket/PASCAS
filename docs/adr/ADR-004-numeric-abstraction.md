# ADR-004 — Numeric abstraction (Double now, exact beside it)

Status: accepted.

Reals evaluate as `Double` (hardware, fast, Pas2JS-compatible). Exactness
comes from *separate* types used where they win: `PMS.Rational` for
fractions, `PMS.BigInt` as an abstraction over `Int64` now with a
digit-array upgrade path later. No global precision flag, no wholesale
BigFloat rewrite.

Consequence: `1/3+1/6` stays exact via rationals; transcendental functions
use Double. Documented per-function in `PMS.Funcs`.
