"""Web verification: compiles app/web/p2jsverify.pas with Pas2JS and runs
it under Node. The Pascal core executes as JavaScript; failures here mean
the browser build is broken even if FPC tests pass."""
import os, subprocess, sys

CANDIDATES = [
    os.environ.get("PAS2JS_EXE") or "",
    r"C:\pas2js-2.2.0\pas2js-windows-2.2.0\bin\i386-win32\pas2js.exe",
    "pas2js",
]
VERSION = "2.2.0"  # pinned; CI downloads the same official zip
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

UNIT_DIRS = ["core", "core/ast", "core/parser", "core/evaluator",
             "core/numeric", "core/complex", "core/rational", "core/bigint",
             "core/algebra", "core/polynomial", "core/calculus",
             "core/equations", "core/matrices", "core/statistics",
             "core/units", "core/constants", "rendering/math",
             "rendering/graph2d", "rendering/graph3d", "app/web"]


def find_pas2js():
    for c in CANDIDATES:
        try:
            subprocess.run([c, "-iW"], capture_output=True, check=True)
            return c
        except (OSError, subprocess.CalledProcessError):
            continue
    raise SystemExit("pas2js not found — see docs/deployment/web.md")


def main():
    p2js = find_pas2js()
    print("Using pas2js:", p2js)
    outdir = os.path.join(ROOT, "bin", "webtest")
    os.makedirs(outdir, exist_ok=True)
    out = os.path.join(outdir, "p2jsverify.js")
    cmd = [p2js, "-Tnodejs", "-Jc"] + ["-Fu" + os.path.join(ROOT, d)
                                       for d in UNIT_DIRS]
    subprocess.run(cmd + ["-o" + out,
                           os.path.join(ROOT, "app/web/p2jsverify.pas")],
                   check=True)
    node = "node"
    r = subprocess.run([node, out], capture_output=True, text=True)
    print(r.stdout, end="")
    if r.returncode != 0 or "WEB-VERIFY ALL PASS" not in r.stdout:
        print(r.stderr, end="")
        return 1
    print("Web verification OK (core runs as JavaScript)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
