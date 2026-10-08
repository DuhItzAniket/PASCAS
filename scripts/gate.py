"""Release gate (Phase 45): the full scripted quality check in one go.
Runs: console+LCL build, all unit runners, golden cases through the
shipped binary, Pas2JS transpile + Node verification, web build.
Headless-safe; GUI/browser-DOM smokes stay manual (see PHASE-45)."""
import os, subprocess, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PY = sys.executable

STEPS = [
    ("build (console+LCL)", [PY, "scripts/build.py"]),
    ("unit runners", [PY, "scripts/runtests.py"]),
    ("golden cases", [PY, "scripts/golden.py"]),
    ("web verify (pas2js+node)", [PY, "scripts/verify_web.py"]),
    ("web build", [PY, "scripts/build_web.py"]),
]


def main():
    fails = 0
    for name, cmd in STEPS:
        print(f"===== gate: {name} =====")
        r = subprocess.run(cmd, cwd=ROOT)
        if r.returncode != 0:
            print(f"GATE FAIL: {name}")
            fails += 1
    if fails:
        print(f"GATE: {fails} step(s) failed — do not release.")
        return 1
    print("GATE: all scripted checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
