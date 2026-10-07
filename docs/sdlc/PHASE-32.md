# Phase 32 — 2D Coordinate System and Viewport

## Objective

World↔screen mapping, zoom-around-point, drag panning, nice axis ticks.

## Implementation

`rendering/graph2d/pms.viewport.pas` (`PMS.Viewport`): `VDefault`,
`VWorldToScreen`/`VScreenToWorld` (roundtrip-tested), `VZoom`
(factor < 1 zooms in, cursor point fixed), `VPanPixels` (drag-style:
content follows the cursor), `VNiceTicks` (smallest 1/2/5×10ⁿ step
within budget — the first draft could exceed MaxTicks and was fixed).

## Tests

In `tests/unit/test_graph.lpr`. **Passed.**
