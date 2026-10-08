"""Golden gate: runs tests/golden/cases.txt through the shipped pmscalc
binary and compares with absolute+relative tolerance. Fails on any
mismatch, parse failure, or calculator error line."""
import os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ABS_TOL = 1e-9
REL_TOL = 1e-9


def num(s):
    s = s.strip()
    if "/" in s:  # exact fractions like 1/2 stay readable in the file
        a, b = s.split("/", 1)
        return float(a.strip()) / float(b.strip())
    return float(s)


def load_cases():
    cases = []
    section = None
    with open(os.path.join(ROOT, "tests/golden/cases.txt")) as f:
        for no, raw in enumerate(f, 1):
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line == "[eval]":
                section = "eval"
                continue
            if section != "eval" or "=" not in line:
                continue
            expr, want = line.rsplit("=", 1)
            cases.append((no, expr.strip(), num(want)))
    return cases


def main():
    cases = load_cases()
    if not cases:
        print("No golden cases found.")
        return 1
    exe = os.path.join(ROOT, "bin/pmscalc" + (".exe" if os.name == "nt" else ""))
    if not os.path.isfile(exe):
        print("pmscalc missing — run scripts/build.py first.")
        return 1
    r = subprocess.run([exe] + [c[1] for c in cases], capture_output=True,
                       text=True)
    got = r.stdout.splitlines()
    fails = 0
    for (no, expr, want), line in zip(cases, got):
        try:
            actual = float(line.strip())
        except ValueError:
            print(f"FAIL line {no}: {expr!r} -> {line!r} (want {want})")
            fails += 1
            continue
        tol = ABS_TOL + REL_TOL * abs(want)
        if abs(actual - want) > tol:
            print(f"FAIL line {no}: {expr!r} = {actual} (want {want})")
            fails += 1
        else:
            print(f"ok: {expr} = {actual}")
    if len(got) != len(cases):
        print(f"FAIL: {len(cases)} cases, {len(got)} outputs")
        fails += 1
    print(f"{len(cases) - fails}/{len(cases)} golden cases passed.")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
