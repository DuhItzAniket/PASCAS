# Phase 29 — Probability Engine

## Objective

Seven distributions with PDF/PMF + CDF (Normal also quantiled).

## Implementation

`core/statistics/pms.prob.pas` (`PMS.Prob`): Normal, Binomial,
Poisson, Uniform, Exponential, Student-t, Chi-square on top of one
special-function core (Lanczos `lnGamma`, A&S `erf`, regularized gamma,
continued-fraction incomplete beta). Two bugs caught by tests and fixed:
the gamma-P series seed and flipped Acklam central signs. Documented
accuracy (~1e-9 central quantile, ~1e-4 far tails); the test pins it
with a CDF↔quantile roundtrip grid, not just spot values.

## Tests

In `tests/unit/test_stats.lpr` (textbook values + roundtrip).
**Passed.**
