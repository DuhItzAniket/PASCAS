# Architecture — PascalMath Studio

Product name is centralized in `core/appname.pas` (`PMS.AppName`): change it
there once, every target follows. No other file hardcodes the product name.

## Layers

```text
app/desktop  — Lazarus/LCL shell, thin. Owns widgets only.
app/web      — HTML/CSS shell + Pas2JS-compiled Pascal controller, thin.
core/        — Pure Pascal math engine. No LCL, no DOM, no file I/O.
               Compiles under FPC AND Pas2JS from the same sources.
rendering/   — Viewport math + sampling in core-compatible Pascal;
               actual pixels via LCL/Canvas on desktop, Canvas2D on web.
platform/    — Adapters: desktop widgets, browser bindings, storage.
tests/       — Console assert-runners compiled with FPC. No frameworks.
```

Dependency rule: **core depends on nothing but RTL (`SysUtils`, `Math`).
Everything else depends on core. Never the reverse.** Any unit importing
LCL/Web units from `core/` is a bug.

## Core units (one per phase, smallest real thing)

| Unit | Phase | Contents |
|------|-------|----------|
| `PMS.AppName` | 04 | product-name constant |
| `PMS.Types` | 06 | error codes, `TEvalContext`, result records |
| `PMS.Lexer` | 07 | tokenizer |
| `PMS.AST` | 08 | node hierarchy (root owns children) |
| `PMS.Parser` | 08 | recursive-descent parser, implicit `*` |
| `PMS.ASTUtils` | 09 | clone, print, JSON serialize |
| `PMS.Eval` | 10 | tree-walking numeric evaluator |
| `PMS.Funcs` | 11 | scientific functions + domain checks |
| `PMS.Consts` | 12 | constant registry, DEG/RAD/GRAD |
| `PMS.Complex` | 15 | complex record + ops |
| `PMS.Rational` | 16 | exact rationals, canonical reduction |
| `PMS.BigInt` | 17 | precision abstraction (see ADR-004) |
| `PMS.Simplify` | 18 | rule-based simplifier |
| `PMS.Poly` | 19 | polynomial abstraction |
| `PMS.DiffSym` | 20 | symbolic differentiation |
| `PMS.DiffNum` | 21 | finite differences |
| `PMS.IntNum` | 22 | trapezoidal/Simpson/adaptive |
| `PMS.IntSym` | 23 | rule-based antiderivatives |
| `PMS.Solve` | 24 | bisection/Newton/secant + quadratics |
| `PMS.Limits` | 25 | limit engine + numeric fallback |
| `PMS.Matrix` | 26 | matrix/vector ops, det/inv/gauss |
| `PMS.LinAlg` | 27 | LU/QR/eigen/SVD |
| `PMS.Stats` | 28 | descriptive stats + regression |
| `PMS.Prob` | 29 | distributions |
| `PMS.Units` | 30 | dimensional analysis |
| `PMS.Deps` | 31 | variables/functions + dependency graph |
| `PMS.Viewport` | 32 | coordinate transforms |
| `PMS.Sampler` | 33 | adaptive function sampling |
| `PMS.Workspace` | 35 | multi-expression list |
| `PMS.Analysis` | 38 | roots/intersections/extrema/tangent |
| `PMS.Session` | 40 | versioned JSON save/load/share |

Graphing extras (36, 37, 39) extend `PMS.Sampler`/`PMS.Workspace`, not new
worlds: sliders = bound variables, parametric/polar/implicit = sampler
modes, 3D = `z=f(x,y)` heightfield behind an architecture stub.

## Cross-cutting rules

- **Security:** the parser is the only entry for user text. Hard limits:
  input ≤ 4096 chars, depth ≤ 64, ops ≤ 10000, matrix dim ≤ 64,
  sampler ≤ 4096 points, solver ≤ 200 iterations. Errors are structured
  (`TCalcError`), never exceptions to the UI, never a crash.
- **Numerics:** exact types (rational/integer) preserved until a function
  forces float. Float asserts use abs+rel tolerance, never exact equality.
- **Memory:** AST root frees children (`TObjectList`-style ownership, manual
  `Free`). No globals holding user state; contexts passed explicitly.
- **Pas2JS compatibility:** core uses only `SysUtils`, `Math`, `Classes`
  (TStringList/TList where needed). No `Windows`, no file I/O, no threads
  in core. Platform code handles I/O, workers, storage.
- **Tests:** every math unit ships a `tests/unit/test_<name>.lpr`
  assert-runner. Golden cases live in `tests/golden/cases.txt`.
