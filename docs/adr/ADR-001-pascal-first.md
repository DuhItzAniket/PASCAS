# ADR-001 — Pascal-first architecture

Status: accepted.

Core math is implemented in Object Pascal (FPC dialect), shared by desktop
(Lazarus/LCL) and web (Pas2JS) targets. No Python/SymPy/JS-math in the core
path; JS exists only as a thin browser-API shim.

Consequence: core units may use only RTL units that exist in both FPC and
Pas2JS (`SysUtils`, `Math`, `Classes`). Verified per-phase by compiling the
same sources with `fpc` and `pas2js`.
