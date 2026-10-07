# Phase 13 — Desktop Calculator UI

## Objective

First user-facing milestone: a real Lazarus window — expression in,
result out — over the shared core. No math in the GUI layer.

## Implementation

- `app/desktop/pmstudio.lpi` — Lazarus project (LCL package declared,
  core dirs on the unit path, target `bin/pmstudio`). Builds with the
  bundled `lazbuild` 4.8 and CI's apt Lazarus alike.
- `app/desktop/mainform.pas` + `.lfm` — `TStudioForm`: expression edit,
  result label, history list, 30-button grid generated from a table
  (digits/ops/functions/actions), RAD/DEG/GRAD toggle, Enter=eval,
  Esc=clear, double-click history recall, `Ans` support via core context.
- `app/desktop/pmstudio.lpr` — program shell, product name from
  `PMS.AppName`.

## Build verification (actually executed)

```text
lazbuild app/desktop/pmstudio.lpi -> 1663 lines compiled, 5.4s, LINKED
launch bin/pmstudio.exe -> alive after 3s (no .lfm streaming crash), killed OK
```

Manual visual check of button layout still recommended (headless here).

## CI

`build-desktop` job activated (apt Lazarus + `lazbuild`), per Phase 05 plan.
