# Changelog

All notable changes to PascalMath Studio are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [0.1.0] — 2026-10-08 — all 50 phases

### Added
- Expression engine: lexer, recursive-descent parser (implicit
  multiplication, right-associative power), single AST, pretty printer,
  s-expression serialization
- Numeric evaluator with structured errors, scientific functions
  (DEG/RAD/GRAD), constants registry, real/complex mode flag
- Desktop calculator (Lazarus LCL): buttons, keyboard, history with
  file persistence, memory, Ans, angle toggle, dark mode, graph windows
- CAS: simplifier, polynomials, symbolic differentiation, numerical
  diff/integration, rule-based integration, bisection/Newton/secant +
  verified linear/quadratic solver, limits engine
- Numerics: complex, exact rationals, checked bigint abstraction,
  matrices, LU/QR/Jacobi-eigen/SVD, statistics, 7 distributions, units
- Dependency engine: variables, user functions, reactive re-evaluation,
  cycle detection
- Graphing: viewport, adaptive sampler, discontinuities, multi-expression
  workspace, sliders, parametric/polar/implicit, roots/extrema/tangent/
  area analysis, software 3D wireframe
- Sessions: versioned JSON + URL-hash sharing, desktop + web import/export
- Web (Pas2JS 2.2.0, Pascal-first): eval + plot + pan/zoom + workspace +
  sliders + localStorage + hash-share, PWA with offline service worker
- Quality: 18 assert-runners + golden file + Node-executed web
  verification + one-command release gate; CI (core/tests/desktop/web)
  and tag-triggered releases

### Fixed (found by tests, not by users)
- FPC objfpc bare self-name reads the result variable: parenthesized
  self-calls + loop-based unary parser
- Gamma-P series seed, Acklam central signs, °F offset, cbrt precision
- Sample-grid op-budget starvation, lazy-var materialization, SVD order

## [Unreleased]

### Added
- Repository initialized
- Project directory structure created
- Phase 01: environment audit completed
- Phase 02: repository and GitHub initialization in progress
- Root documentation: README, LICENSE, CONTRIBUTING, SECURITY, ROADMAP
- .gitignore for Pascal/Lazarus/Pas2JS/Node
- GitHub Actions CI skeleton
- docs/sdlc/PROJECT-STATUS.md
- docs/sdlc/PHASE-01.md
