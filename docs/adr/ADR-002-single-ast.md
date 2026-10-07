# ADR-002 — Single AST for all subsystems

Status: accepted.

One node hierarchy (`PMS.AST`) serves evaluator, simplifier, differentiator,
plotter, printer, serializer. Root owns children; subsystems never invent
parallel expression representations.

Consequence: AST changes require updating all consumers, but that cost is
smaller than N divergent trees drifting apart.
