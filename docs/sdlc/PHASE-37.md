# Phase 37 — Parametric, Polar and Implicit Graphs

## Objective

`x(t),y(t)`, `r(θ)`, and `F(x,y) = 0` alongside `y = f(x)`.

## Implementation

In `PMS.Sampler` + `PMS.Workspace` entry kinds (`xt;yt` split on `;`,
polar over `[0,2π]`, implicit string is `F` directly): parametric/polar
trace with gap flags; implicit uses marching squares with edge-linear
interpolation and saddle fanning (verified: unit circle found at
`(1,0)`, `(0,±1)` with 44 segments on a 120² grid).

## Tests

Polar radius, implicit segment cases in `tests/unit/test_graph.lpr`;
entry kinds in `test_workspace.lpr`. **Passed.**
