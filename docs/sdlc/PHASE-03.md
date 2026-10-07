# Phase 03 — Architecture and Technical Specification

## Objective

Freeze the layered architecture, module boundaries, and cross-cutting rules
before any code is written.

## Decisions (see docs/adr/)

- ADR-001 Pascal-first: shared FPC core, LCL desktop, Pas2JS web.
- ADR-002 Single AST for evaluator/simplifier/diff/plot/print/serialize.
- ADR-003 Hand-written recursive-descent parser (no generator dependency).
- ADR-004 Doubles for floats + separate exact Rational/BigInt types.
- ADR-005 Desktop: Lazarus/LCL native controls.
- ADR-006 Web: Pas2JS-compiled core + thin HTML/JS shell, offline-first.
- ADR-007 Graphs: CPU adaptive sampling in Pascal, Canvas only strokes.
- ADR-008 Sessions: versioned JSON, URL-hash sharing, no backend.

## Module boundaries

`core/` (pure Pascal, FPC+Pas2JS clean) ← `rendering/` (sampling math) ←
`app/` + `platform/` (LCL / DOM adapters). Tests are console assert-runners.

Full spec: `docs/architecture/ARCHITECTURE.md`.

## Correction to Phase 01

Re-audit found the complete toolchain bundled at `C:\lazarus`
(FPC 3.2.2, lazbuild 4.8, pas2js 1.5.1); compile-and-run verified.
Prior "not installed" finding was a PATH-only check error. No blockers remain.

## Tests / build

Spec-only phase; verification = Phase 04 skeleton compiles against it.
