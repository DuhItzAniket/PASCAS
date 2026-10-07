# ADR-003 — Hand-written recursive-descent parser

Status: accepted.

No parser generator (no extra tool dependency, no generated blobs in the
repo). A hand-written recursive-descent parser with explicit precedence
levels handles implicit multiplication at the grammar level, not via regex
preprocessing.

Consequence: grammar extensions are manual but local; every new operator
gets parser tests the same commit.
