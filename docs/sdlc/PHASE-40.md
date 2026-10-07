# Phase 40 — Session Management and Sharing

## Objective

Save/load/import/export/versioned sessions plus backend-free sharing.

## Implementation

`rendering/graph2d/pms.session.pas` (`PMS.Session`): hand-rolled JSON
(writer + depth-capped recursive parser — no fpjson, so the unit stays
FPC/Pas2JS-clean with locale-independent numbers either way).
Definitions persist as re-parseable *text* (grammar-evolution-proof);
viewport world bounds, angle mode, entry kinds/visibility persist;
unknown fields are skipped (forward-compatible), unknown schemas
refused (`ceUnsupported`), garbage refused (`ceSyntax`). Sharing:
Level 1 JSON files (`.pmsession`), Level 2 URL-hash (`#...`
percent-encoded) with copy + paste-into-expression-box import in the
graph window. No backend (per ADR-008).

## Tests

`tests/unit/test_session.lpr` (JSON engine, save/load roundtrip,
viewport/angle/visibility restore, hash roundtrip, refusals).
**Passed.**
