"""Browser build: transpiles app/web/pmsweb.pas (Pascal core + DOM shell)
to app/web/pmsweb.js. Same pinned pas2js as verify_web.py."""
import os, subprocess, sys

VERSION = "2.2.0"
CANDIDATES = [
    os.environ.get("PAS2JS_EXE") or "",
    r"C:\pas2js-2.2.0\pas2js-windows-2.2.0\bin\i386-win32\pas2js.exe",
    "pas2js",
]
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


if __name__ == "__main__":
    import shutil
    p2js = find_pas2js()
    print("Using pas2js:", p2js)
    # the rtl.js runtime bridge ships with the compiler; refresh our copy
    rtl = os.path.normpath(os.path.join(os.path.dirname(p2js), "..", "..",
                                        "packages", "rtl", "rtl.js"))
    if os.path.isfile(rtl):
        shutil.copyfile(rtl, os.path.join(ROOT, "app/web/rtl.js"))
        print("rtl.js refreshed")
    else:
        print("WARNING: rtl.js not found next to compiler; using committed copy")
    cmd = [p2js, "-Tbrowser", "-Jc"] + ["-Fu" + os.path.join(ROOT, d)
                                        for d in UNIT_DIRS]
    subprocess.run(cmd + ["-o" + os.path.join(ROOT, "app/web/pmsweb.js"),
                           os.path.join(ROOT, "app/web/pmsweb.pas")],
                   check=True)
    print("Web build OK: app/web/pmsweb.js")
