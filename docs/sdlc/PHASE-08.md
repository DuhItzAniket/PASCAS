# Phase 08 — Parser and AST

## Objective

One AST (ADR-002) built by a hand-written recursive-descent parser
(ADR-003), with implicit multiplication as grammar.

## Implementation

- `core/ast/pms.ast.pas` (`PMS.AST`): `TNumberNode`, `TVarNode`,
  `TUnaryNode` (`-`/`!`/`%`), `TBinaryNode` (`+ - * / ^ m`),
  `TFuncNode` (n-ary), `TAssignNode`, `TFuncDefNode` (evaluated Phase 31).
  Root owns children; `Clone` per node.
- `core/parser/pms.parser.pas` (`PMS.Parser`): precedence
  assign → additive → multiplicative (`*` `/` `mod`) → implicit
  (`2x`, `3(x+1)`, `2sin(x)`) → unary (loop-collapsed `--x`) →
  power (right-assoc, `2^3^2 = 512`, `2^-3`) → postfix (`!` `%`) →
  primary. Malformed input → `ceSyntax`/`ceRecursionLimit`, never a crash.
  Failed parses free all partial nodes exactly once (own/disown scheme).

## Compiler quirk (important)

FPC 3.2.2 objfpc: a bare self-name inside its own function body reads the
function's **result variable** instead of recursing (`Child := ParseAssign`
returned garbage, no call, plus a misleading "result not initialized"
warning). Mutual recursion is unaffected. Rule for this codebase:
**self-recursive calls always use parentheses** (`ParseAssign()`), and
unary +/- uses a loop instead of self-recursion. Regression tests check
child shapes (`a=2` child's value, chained `a=b=2` nesting), not just the
root type.

## Tests

`tests/unit/test_parser.lpr` (20+ checks): precedence/right-assoc shapes,
implicit mult, unary/power/postfix, assign/funcdef/call shapes, chained
assignment, 8 malformed inputs. **Passed.**
