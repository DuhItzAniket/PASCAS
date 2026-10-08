# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| latest  | ✅ |

## Reporting a Vulnerability

Do not open a public GitHub issue for security vulnerabilities.

Report vulnerabilities privately via GitHub's Security Advisory feature:
https://github.com/DuhItzAniket/PASCAS/security/advisories/new

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix if known

You will receive a response within 7 days.

## Security Practices

- No credentials, tokens, or secrets in source code or commits
  (scanned 2026-10-08: clean).
- Controlled expression language only — user text never reaches
  `eval`-equivalents on any target; the parser is the sole entry point.
- Hard input limits enforced in one place (`PMS.Types`): 4096-char
  input, depth 64, 10000 ops, matrix dim 64, 200 solver iterations,
  4096 samples, 20 adaptive levels. Pathological input yields structured
  errors, never hangs or crashes (fuzz-shaped cases in test_parser).
- Web: DOM writes escape user-derived strings (`EscHTML`); math runs
  locally, no data leaves the browser; no inline event handlers.
- Dependencies (reviewed 2026-10-08): zero third-party math/runtime
  dependencies. Core uses FPC RTL only. Desktop adds LCL (ships with
  Lazarus). Web adds the pas2js 2.2.0 RTL (`packages/rtl`, COPYING.FPC —
  FPC's modified LGPL with static-linking exception, compatible with
  this MIT project; `rtl.js` vendored from that distribution).
  No CVEs apply (no network, crypto, or parsing libraries).
- Static analysis: `fpc -vwnh` clean apart from two reviewed
  flow-analysis false positives (managed-result init) and removed dead
  parameters; CI compiles with warnings visible on every push.
