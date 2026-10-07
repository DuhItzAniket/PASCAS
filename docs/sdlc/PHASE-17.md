# Phase 17 — Arbitrary Integer / Precision Abstraction

## Objective

A precision-aware integer abstraction the engine can rely on without
being coupled to any bigint implementation.

## Implementation

`core/bigint/pms.bigint.pas` (`PMS.BigInt`): method-style API
(`BAdd/BSub/BMul/BPow/BFact/BGCD/BFromStr/BToStr/...`) over an Int64
backend with checked arithmetic — overflow is `ceOverflow`, never a
wrap. Callers never touch the field, so a digit-array backend slots in
later untouched. Marked with a `ponytail:` ceiling comment. Verified:
`20! = 2432902008176640000` exact, `2^62` exact, `21!`/`2^63` overflow
honestly, `Low(Int64)` subtraction edge exact.

## Tests

`tests/unit/test_bigint.lpr` (17 checks). **Passed.**
