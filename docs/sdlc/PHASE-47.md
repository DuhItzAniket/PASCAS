# Phase 47 — Desktop Packaging

## Objective

Reproducible portable builds for Windows (and Linux when built there).

## Implementation

- `scripts/package.py`: version read from `PMS.AppName` (never typed
  twice), platform-aware archives —
  `PascalMathStudio-win-x64-0.1.0.zip` (5.6MB, both exes + docs),
  `pascalmath-web-0.1.0.zip` (static-host bundle). Missing binaries
  fail loudly with the exact build command.
- `docs/deployment/desktop.md`: requirements, `-B` rebuild rule,
  locale pin, packaging, no-installer decision.
- `dist/` is gitignored build output.

## Verification

Both archives produced locally and listed.
