# ADR-009 — CI/CD architecture

Status: accepted.

Two workflows, split by trigger: `ci.yml` on every push/PR (lint-docs,
build-core, test-core, build-desktop, build-web) and `release.yml` on
version tags (full gate + web package + GitHub Release). All toolchains
pinned (apt `fpc`/`lazarus`, official pas2js 2.2.0 zips) — no floating
`latest`, no language-specific actions beyond checkout. Desktop release
binaries are built on maintainer machines (`scripts/package.py`) and
attached manually; only the web artifact is CI-published, because only
it builds deterministically on hosted runners today.

Consequence: tagging a release is one command, and the gate refuses to
publish on any scripted failure.
