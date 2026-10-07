# Phase 09 — AST Utilities and Serialization

## Objective

One shared toolkit over the AST for printer, UI, tests, and (later)
session persistence. No second representation anywhere.

## Implementation

`core/ast/pms.astutils.pas` (`PMS.ASTUtils`): `Pretty` (precedence-aware,
`2+3*4`, `(2+3)*4`, `-(2^2)`, `2*sin(x)`), `Serialize` (s-expressions for
tests/sessions), `NodeCount`, `TreeDepth`, preorder `Walk`.

## Tests

`tests/unit/test_astutils.lpr`: pretty/sexpr/count/depth/walk cases.
**Passed.**
