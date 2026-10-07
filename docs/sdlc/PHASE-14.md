# Phase 14 — Calculator UX and History

## Objective

Make the calculator pleasant for repeated use: persistent history,
recall keys, memory register, copy support.

## Implementation (all in `mainform.pas`)

- History persists to `%AppData%/PascalMathStudio/history.txt` (cap 200),
  loaded at startup, saved at exit; all file I/O wrapped so it can never
  break startup or evaluation.
- Up/Down in the expression box walks history (guarded `FNavLock` so
  programmatic recall doesn't reset the walk position).
- Memory row: M+ M− MR MC (+/− negate-wrap). Register is session-volatile
  by design; `Ans` (core context) covers result reuse.
- Ctrl+C copies the result, or the focused history line; inside the edit
  box the native selection copy is left alone.
- Failed evaluations are never added to history; `FLastOK` gates M+/M−.

## Build verification

`lazbuild` clean (346 lines, no warnings in `mainform`), GUI smoke test
alive-3s OK.
