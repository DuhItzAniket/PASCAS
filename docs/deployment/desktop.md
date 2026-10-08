# Desktop build & packaging

## Requirements

- Lazarus with bundled FPC (dev machine: `C:\lazarus`, FPC 3.2.2 +
  lazbuild 4.8). CI installs `lazarus` via apt.
- Python 3 for orchestration scripts only.

## Build

```sh
python scripts/build.py        # console (fpc) + LCL app (lazbuild -B)
```

`-B` forces a full rebuild: lazbuild does not reliably notice `.lfm`
edits. `TPaintBox` (and other `TGraphicControl`s) have no `TabOrder` —
setting it breaks form streaming at startup (exit 217).

`DefaultFormatSettings.DecimalSeparator` is pinned to `'.'` in both
`.lpr` mains: expression syntax is locale-independent.

## Package

```sh
python scripts/package.py      # dist/PascalMathStudio-<plat>-<ver>.zip
```

Portable archives: `pmscalc` + `pmstudio` + README/LICENSE/CHANGELOG.
No installer in v1 (documented choice); the zip runs from any folder.
History lives in the OS app-config dir, never next to the binary.
