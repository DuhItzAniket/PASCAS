# ADR-008 — Session persistence: versioned JSON, URL-hash sharing

Status: accepted.

Sessions serialize to versioned JSON (`{"schemaVersion":1,...}`) with a
`PMS.Session` migrator for older schemas. Sharing levels: (1) JSON
export/import file, (2) compressed state in URL hash — no backend. A sharing
service only if a backend ever exists for other reasons.

Consequence: never serialize pointers/handles; viewport, expressions,
variables only.
