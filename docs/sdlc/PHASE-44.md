# Phase 44 — PWA / Offline Web Support

## Objective

Installable, offline-capable web app with safe updates.

## Implementation (`app/web/`)

- `manifest.webmanifest` (name, colors, generated 192/512px sine-curve
  icons), theme-color + manifest + icon links in `index.html`.
- `sw.js`: versioned cache (`pms-v1`) precaching the full shell;
  cache-first fetch; old caches purged on activate; `skipWaiting` +
  `clients.claim`. Updates invalidate by bumping the cache name.
- Offline math was already free (zero network calls by design) — the
  worker only preserves the shell.

## Verification

Files served locally; registration line present (full install-prompt
check needs HTTPS hosting, covered by deployment docs).
