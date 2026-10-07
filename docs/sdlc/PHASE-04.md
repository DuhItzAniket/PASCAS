# Phase 04 — Build System and Project Skeleton

## Objective

Reproducible local builds from day one; no empty project.

## What was built

- `core/pms.appname.pas` (`PMS.AppName`) — centralized product name/version.
- `app/desktop/pmscalc.lpr` — console front-end skeleton (LCL GUI: Phase 13).
- `app/web/index.html` + `app/web/pmsweb.pas` — web shell skeleton (Phase 42).
- `scripts/build.py` — finds FPC (`C:\lazarus\...` bundle or PATH), compiles
  with `-Fu` over all core/rendering dirs. Orchestration only.
- `scripts/runtests.py` — compiles + runs every `tests/unit/test_*.lpr`.
- `tests/golden/cases.txt` — seed golden cases.

## Build verification (actually executed)

```text
python scripts/build.py  -> 29 lines compiled, 0.2 sec, Build OK
./bin/pmscalc.exe        -> PascalMath Studio v0.1.0 (console skeleton)
```

Toolchain: FPC 3.2.2 (i386-win32 bundle). Dotted unit names verified.
