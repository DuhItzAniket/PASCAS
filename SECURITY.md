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
- Input validation on all parser entry points
- No eval or dynamic code execution in the web target
- Dependencies reviewed for known CVEs before adoption
- Static analysis run as part of CI (Phase 46)
