# Phase 38 — Advanced Graph Analysis

## Objective

Roots, intersections, extrema, tangents, area, inspection — on graph
expressions, in the graph window.

## Implementation

`rendering/graph2d/pms.analysis.pas` (`PMS.Analysis`): sign-scan +
bisection roots, difference-roots intersections, dense-scan +
golden-section extrema, central-difference tangents, adaptive-Simpson
area, point inspection — all over caller-expanded expressions with the
store context. Desktop: Roots/Extrema/Intersect/Area/Tangent buttons +
click-to-inspect crosshair in the graph window memo. Verified:
`x²−4` roots ±2, min at 0, tangent at 2, area −16/3, sin=cos at π/4.

## Tests

In `tests/unit/test_workspace.lpr`. **Passed.**
