# User guide

## Calculator

Type an expression, press Enter (or `=`). `2 + 3 * 4` → `14`.
`2x`, `3(x+1)`, `2sin(x)` work. `Ans` reuses the last result; history
persists between runs (double-click recalls; Up/Down walks it). `M+`
`M-` `MR` `MC` are the memory register. `RAD`/`DEG`/`GRAD` switches
angle mode. Ctrl+C copies the result; Ctrl+G opens the graph.

Functions: sin cos tan asin acos atan sinh cosh tanh ln log exp sqrt
cbrt abs floor ceil round. Constants: pi e phi tau sqrt2 sqrt3 plus SI
physics (c G h hbar kB Na R me mp qe). Postfix: `5!`, `50%`.
`7 mod 3`. Variables: `a = 2` then `a*3`.

Errors never crash: division by zero, `log(-3)`, unknown names, and
unparseable input each explain themselves with a position.

## Graph window

Add `y = f(x)` expressions (each plotted in its own color; uncheck to
hide). Parametric as `x(t);y(t)`, polar as `r(t)`, implicit as `F(x,y)`.
Drag pans, wheel zooms, click picks an inspection point. Variables
are workspace-scoped and the Sliders button binds every one of them to
a live slider.

Analysis (select a `y=f(x)` row first): Roots, Extrema, Intersect (with
the next visible curve), Area over the view, Tangent at the clicked
point. Variables are workspace-scoped: type `a = 2` into the expression
box and Add it (definitions are accepted there too), then Sliders binds
it live. Save/Load store `.pmsession` files; Link copies a URL-hash that
restores the whole workspace — paste it into the expression box to
import. The same links work in the web app.

## 3D

Open from the graph window (`3D...`). Enter `z = f(x,y)` over
`[-5,5]²`; drag the azimuth/elevation sliders to rotate the wireframe.

## Web app

Same engine, compiled to JavaScript — everything runs locally, offline
after first load. Expression list, sliders, `localStorage` resume, and
share links behave like the desktop graph window.

## Limits worth knowing

- Exact display (`1/2` instead of `0.5`) is not shown in v1.
- Complex results display in the solver path only where implemented;
  full `i`-arithmetic in expressions is a roadmap item.
- `Int64` past 2^53 is approximate in the browser (exact on desktop).
- Symbolic integration covers the documented rule subset and says so
  otherwise.
