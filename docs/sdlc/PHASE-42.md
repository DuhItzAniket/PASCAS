# Phase 42 — Web Port Using Pascal + Pas2JS

## Objective

The shared core compiled to browser JavaScript — no math rewritten.

## Implementation

- Toolchain: pas2js **2.2.0** pinned (official zips, compiler + RTL;
  the bundled 1.5.1 ships no RTL). `scripts/build_web.py` transpiles
  `app/web/pmsweb.pas` → `pmsweb.js`; `docs/deployment/web.md` pins
  everything including CI paths.
- Core made FPC+Pas2JS-clean (verified by compiling *every* unit):
  `Tan`/`Sinh`/`Tanh` identities, `ArcTan2` quadrants, no static-array
  copies from const records, named grid-row types, no `SizeOf` /
  `DefaultFormatSettings`, parenthesized self-calls as ever.
- `app/web/`: `index.html` shell (loads `rtl.js`, program JS, calls
  `rtl.run()`), `pmsweb.pas` controller (eval + single plot + pan/zoom
  + share-link), `style.css`.
- Known caveat documented: `Int64` past 2^53 is approximate in browsers.

## Verification (actually executed)

- `verify_web.py`: core probe transpiled and run under Node — ALL PASS.
- Headless Chrome over local HTTP: `sin(pi/2)` evaluates to `1` in the
  live DOM, zero console errors.
