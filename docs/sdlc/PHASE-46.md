# Phase 46 — Security, Dependency and Code Review

## Objective

Review, fix, and record — then update the policy.

## Findings and fixes

- **XSS (fixed):** web entry/param text flowed into `innerHTML`;
  `textContent` is unbound in this RTL, so all DOM writes now pass
  through Pascal-side `EscHTML`. Desktop labels auto-escape.
- **Secrets scan:** clean (only policy prose matched).
- **Dependencies:** zero third-party math code. FPC RTL + LCL + pas2js
  2.2.0 RTL (COPYING.FPC exception, MIT-compatible). No CVEs apply.
- **Static analysis:** `fpc -vwnh` over the core — two managed-result
  flow-analysis false positives (reviewed, `SetLength`-initialized),
  one real dead-parameter cleanup (`SimpOnce` → `SimpPanel`).
- **Limits audit:** all DoS-relevant caps centralized in `PMS.Types`
  and honored by lexer/parser/evaluator/sampler/solver (worst case is a
  structured error).
- `SECURITY.md` updated with all of the above.

## Tests

No behavior changed except the XSS fix; full gate re-run green.
