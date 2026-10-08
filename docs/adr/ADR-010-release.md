# ADR-010 — Release strategy

Status: accepted.

Portable archives over installers for v1 (`package.py` zips versioned
from `PMS.AppName`): zero-install, zero-elevation, trivially verifiable.
Web deploys as static files anywhere (no server component exists).
GitHub Releases carry the web bundle plus auto-generated notes; the
CHANGELOG is the human record. No auto-update mechanism — the PWA
service worker rotates caches by version name, and desktop users
re-download the zip.

Consequence: releases are cheap and reproducible; first-run friction is
one unzip.
