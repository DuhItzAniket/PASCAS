# Phase 50 — Final Release and Project Handover

## Objective

Close the 50-phase plan with a tagged, reproducible v0.1.0.

## Release checklist

- [x] `scripts/gate.py` fully green (build, 18 runners, 14 goldens,
      Node web-verify, web build)
- [x] Desktop links and launches (headless smoke)
- [x] Browser app verified in headless Chrome (eval + entries, no errors)
- [x] `package.py` produces desktop + web archives
- [x] CHANGELOG `0.1.0`, ROADMAP all-COMPLETE, PROJECT-STATUS closed
- [x] Tag `v0.1.0` created locally
- [ ] Push `main` + tag to `origin` (needs the owner's credentials —
      see handover)
- [ ] CI turns green on the remote (first-push proof)
- [ ] GitHub Release published (manual: attach desktop zip from
      `package.py` to the tag release; web bundle attaches via CI)

## Deferred (deliberate, with reasons)

- Command palette / omni-box (needs a menu shell; web candidate).
- Matrix literal `[[..]]` input + grid editor (syntax first).
- GPU 3D, surface shading, picking (software wireframe suffices now).
- Exact rational display (engine ready via `PMS.Rational` + folding).
- Full `i`-arithmetic in expressions (`PMS.Complex` + solver use it).
- Sharing service backend (ADR-008: only with a backend for other reasons).
- OS-theme following, installer, auto-update (zip + PWA cache suffice).
- Web Workers for sampling (replots are milliseconds; revisit on profile).

## Handover

- Toolchains: FPC 3.2.2 + Lazarus 4.8 at `C:\lazarus` (PATH-independent,
  scripts resolve it); pas2js 2.2.0 + RTL at `C:\pas2js-2.2.0`
  (override with `PAS2JS_EXE`); Node for verification.
- Daily loop: `python scripts/gate.py`. Release loop: bump
  `PMSVersion`, CHANGELOG entry, `git tag vX.Y.Z`, push, attach
  desktop zip.
- Known quirks (all documented where they live): FPC bare self-name =
  result variable (parens rule); lazbuild `-B` after `.lfm` edits;
  `TPaintBox` has no `TabOrder`; pas2js needs `rtl.run()` in the page;
  `localStorage.getItem` null-bridge.
