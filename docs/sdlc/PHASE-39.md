# Phase 39 — 3D Graphing

## Objective

Architecture first, then `z = f(x,y)` — no GPU until measurement says so.

## Implementation

`rendering/graph3d/pms.graph3d.pas` (`PMS.Graph3D`): heightfield
sampling with per-point budget and hole flags, orthographic projection
(azimuth/elevation) — `P3Project`/`P3Sample` tested (origin→center,
21² grid all good). Desktop: `TGraph3DForm` wireframe (rows + columns,
holes break the stroke) with azimuth/elevation sliders, opened from the
2D graph window. Stays in the ADR-007 software lane; surface shading
and picking are documented next steps, not this phase.

## Tests

In `tests/unit/test_workspace.lpr`. **Passed.** Desktop builds and
launches (headless smoke).
