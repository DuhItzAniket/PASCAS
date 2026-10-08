# Testing

## Suites (all executable, all green at v0.1.0)

| Suite | Runner | What |
|-------|--------|------|
| Unit | `scripts/runtests.py` → 18 `test_*.lpr` assert-programs | every math unit, parser, errors |
| Golden | `scripts/golden.py` → `tests/golden/cases.txt` | shipped `pmscalc` binary, tolerance-aware |
| Web | `scripts/verify_web.py` | core transpiled, executed under Node |
| Desktop | `lazbuild` + launch smoke | links, starts, no streaming crash |
| Browser | headless Chrome `--dump-dom` | eval result in live DOM, no console errors |
| Gate | `scripts/gate.py` | all of the above scripted, one command |

## Tolerances

Float asserts use absolute+relative tolerance (`1e-9`..`1e-12` typical;
distribution tails document wider bands). Exactness is asserted only
where mathematically guaranteed (rationals, integers, small factorials).

## Rules (enforced by review, not tooling)

- Never claim a test passed without executing it (every phase doc cites
  executed output).
- Golden cases run through the shipped binary, not just harnesses.
- New parser/function behavior ships with a regression case.
- The web target re-verifies numeric behavior under Node — FPC tests
  alone do not cover the browser path.
