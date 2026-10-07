# PascalMath Studio (PASCAS)

A scientific computing application built in Free Pascal / Lazarus with a web target via Pas2JS.

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
