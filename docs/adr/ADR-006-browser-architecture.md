# ADR-006 — Browser: Pas2JS-compiled Pascal + thin HTML shell

Status: accepted.

Web target compiles the same `core/` Pascal via Pas2JS; the HTML/CSS shell
and a minimal JS bridge handle only DOM/Canvas/storage APIs. All math runs
locally in the browser (offline-first); no per-calculation server calls, no
server required at all for v1.

Consequence: `core/` must stay Pas2JS-clean (see ARCHITECTURE.md). Web
Workers and service-worker PWA arrive in Phases 43–44 around the same core.
