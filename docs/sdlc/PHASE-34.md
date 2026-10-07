# Phase 34 — Robust Graph Rendering

## Objective

Discontinuities, NaN, Infinity, asymptotes, oscillation — gaps, never
garbage strokes.

## Implementation

In `PMS.Sampler`: every point is validated (`ceNone`, finite);
`1/x` still opens a gap at the pole (verified: ≥2 move flags);
suspected jumps re-probe the midpoint and refuse to stroke across
unconfirmed asymptotes while keeping steep-but-continuous curves.
Related find: per-point op-budget reset (`EvalAt`, implicit grid) —
without it, long sample grids starved the shared budget and everything
after the first plot silently vanished.

## Tests

Asymptote-gap case in `tests/unit/test_graph.lpr`. **Passed.**
