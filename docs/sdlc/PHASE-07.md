# Phase 07 — Lexer

## Objective

Tokenize user input with a hand-written scanner: no regex, no locale
dependence, structured errors with positions.

## Implementation

`core/parser/pms.lexer.pas` (`PMS.Lexer`): `Tokenize` recognizes numbers
(`42`, `3.14`, `.5`, `1.5e-3`), identifiers, `+ - * / ^ ( ) , = ! %`.
Whitespace skipped. Anything else → `ceSyntax` + 1-based position.
Inputs over `PMSMaxInputLen` → `ceTooComplex`. Malformed exponents
(`1e`) → `ceSyntax`.

## Tests

`tests/unit/test_lexer.lpr` (10 checks): token shapes, scientific
notation, leading-dot floats, all operators, invalid char position,
dangling exponent, length limit. **Passed.**
