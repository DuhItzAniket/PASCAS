# Phase 05 — CI Foundation

## Objective

Every push/PR compiles the core and runs all test runners automatically.

## Jobs (all live, not placeholders)

- `lint-docs` — required project files present.
- `build-core` — installs FPC via apt, runs `scripts/build.py`.
- `test-core` — runs `scripts/runtests.py` (all `test_*.lpr` runners).

`build-desktop` (lazbuild LCL) and `build-web` (pas2js) activate in
Phases 13 and 42 with the same pattern.

## Verification

Workflow is YAML-valid and mirrors the exact local commands verified in
Phase 04. Runner-side execution happens on first push to origin.
