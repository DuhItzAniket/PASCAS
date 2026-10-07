# Phase 33 — 2D Function Plotting

## Objective

`y = f(x)` as screen polylines with adaptive point sampling.

## Implementation

`rendering/graph2d/pms.sampler.pas` (`PMS.Sampler`): one evaluation per
pixel column over the viewport, recursive midpoint subdivision where
the curve bends (tolerance-scaled, depth 4, hard-capped), screen-space
output with move/draw flags. First draft's fixed-array "refinement"
was dead code (index math could never subdivide) — rewritten as genuine
recursive subdivision and verified by point counts.

## Tests

In `tests/unit/test_graph.lpr` (parabola/sine density). **Passed.**
