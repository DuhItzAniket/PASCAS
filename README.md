# PascalMath Studio (PASCAS)

A scientific computing application built in Free Pascal / Lazarus with a web target via Pas2JS.

v0.1.0 — all 50 implementation phases complete. See
[docs/sdlc/PROJECT-STATUS.md](docs/sdlc/PROJECT-STATUS.md),
[ROADMAP.md](ROADMAP.md), and [CHANGELOG.md](CHANGELOG.md).

## What it does

- Scientific calculation (console `pmscalc`, Lazarus GUI, browser)
- Expression parsing with implicit multiplication and a single AST
- CAS: simplification, differentiation, integration, equation solving
- Matrices, statistics, probability, units
- Interactive 2D/3D graphing with sliders and analysis tools
- Versioned sessions with URL-hash sharing, desktop and web
- Offline-first PWA; no backend, no accounts

## Quick start

Desktop (Windows/Linux with Lazarus):

```sh
python scripts/build.py            # console + LCL app
./bin/pmscalc "2 + 3 * 4"          # -> 14
# or open bin/pmstudio(.exe)
```

Web (any static host):

```sh
python scripts/build_web.py        # needs pas2js 2.2.0, see docs/deployment/web.md
cd app/web && python -m http.server
```

Quality gate (everything scripted):

```sh
python scripts/gate.py             # build + units + golden + web verify
```

## Vision

A genuine scientific-computing environment — not a student calculator — capable of:

- Scientific calculation
- Symbolic algebra (CAS)
- Interactive 2D/3D graphing
- Matrix and linear algebra
- Statistics and probability
- Unit and dimensional analysis
- Numerical methods

## Architecture

The mathematical core is implemented in Pascal and shared between the desktop (Lazarus) and web (Pas2JS) targets.

```
core/        — Pure Pascal mathematical engine
app/         — Desktop (Lazarus) and Web (Pas2JS) applications
rendering/   — Math rendering, 2D and 3D graphing
platform/    — Platform adapters (desktop / web)
tests/       — Unit, integration, regression, golden tests
docs/        — Architecture, SDLC, ADRs, user documentation
```

## Status

See [docs/sdlc/PROJECT-STATUS.md](docs/sdlc/PROJECT-STATUS.md) for current phase progress.

## Requirements

- Free Pascal (FPC) 3.2+
- Lazarus 3.x (desktop)
- Pas2JS (web)

## Building

See [docs/deployment/](docs/deployment/) for build instructions.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
