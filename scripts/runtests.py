"""Test runner: compiles + executes every tests/unit/test_*.lpr assert-runner."""
import glob, os, subprocess, sys
from build import find_fpc, unit_paths  # ponytail: reuse, no second path scheme

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def main():
    fpc = find_fpc()
    runners = sorted(glob.glob(os.path.join(ROOT, "tests/unit/test_*.lpr")))
    if not runners:
        print("No test runners yet — nothing to run.")
        return 0
    fails = 0
    bindir = os.path.join(ROOT, "bin")
    os.makedirs(bindir, exist_ok=True)
    for src in runners:
        name = os.path.splitext(os.path.basename(src))[0]
        exe = os.path.join(bindir, name + (".exe" if os.name == "nt" else ""))
        cmd = [fpc, "-Mobjfpc", "-Sh"] + ["-Fu" + p for p in unit_paths()]
        r = subprocess.run(cmd + ["-o" + exe, src], capture_output=True, text=True)
        if r.returncode != 0:
            print(f"COMPILE-FAIL {name}\n{r.stderr}"); fails += 1; continue
        r = subprocess.run([exe], capture_output=True, text=True)
        print(f"--- {name}: {'PASS' if r.returncode == 0 else 'FAIL'}")
        print(r.stdout, end="")
        if r.returncode != 0:
            print(r.stderr, end=""); fails += 1
    print(f"{len(runners) - fails}/{len(runners)} runners passed.")
    return 1 if fails else 0

if __name__ == "__main__":
    sys.exit(main())
