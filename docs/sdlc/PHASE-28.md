# Phase 28 — Statistics Engine

## Objective

Descriptive statistics and regression over plain arrays.

## Implementation

`core/statistics/pms.stats.pas` (`PMS.Stats`): mean/median/mode,
population + sample variance/std, quartiles/percentiles (linear
interpolation), covariance/correlation, linear fit (slope/intercept/R²),
polynomial fit via normal equations solved by `PMS.Matrix`, residuals.
Empty/mismatched input is `ceDomain`.

## Tests

In `tests/unit/test_stats.lpr`. **Passed.**
