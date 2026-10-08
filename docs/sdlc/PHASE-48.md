# Phase 48 — Production CI/CD and Release Automation

## Objective

Push-button releases that cannot ship red code.

## Implementation

- `ci.yml` gains `build-web` (pinned pas2js Linux zip → build →
  Node verify). Jobs: lint-docs, build-core, test-core,
  build-desktop, build-web.
- `release.yml` (new): version tags trigger the full gate
  (build+units+golden+web+package) then publish a GitHub Release with
  the web bundle and generated notes. Desktop binaries stay
  maintainer-attached (`package.py`) — documented in the workflow
  header — because only the web artifact builds deterministically on
  hosted runners today.
- ADR-009 records the two-workflow split and the pinning policy.

## Verification

Workflow YAML parsed locally; job commands mirror verified local
commands one-to-one. Runner-side proof arrives with the first push.
