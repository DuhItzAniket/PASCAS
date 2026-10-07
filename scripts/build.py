"""Build helper: compiles Pascal targets. Orchestration only — math stays in Pascal."""
import os, subprocess, sys

FPC_CANDIDATES = [
    r"C:\lazarus\fpc\3.2.2\bin\i386-win32\fpc.exe",  # dev machine bundle
    "fpc",  # PATH (CI installs fpc via apt)
]
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

LAZBUILD_CANDIDATES = [
    r"C:\lazarus\lazbuild.exe",  # dev machine bundle
    "lazbuild",  # PATH (CI installs lazarus via apt)
]

def find_lazbuild():
    for c in LAZBUILD_CANDIDATES:
        try:
            subprocess.run([c, "--version"], capture_output=True, check=True)
            return c
        except (OSError, subprocess.CalledProcessError):
            continue
    return None

def find_fpc():
    for c in FPC_CANDIDATES:
        try:
            subprocess.run([c, "-iV"], capture_output=True, check=True)
            return c
        except (OSError, subprocess.CalledProcessError):
            continue
    raise SystemExit("FPC not found — install Lazarus (bundles FPC) or fpc.")

def unit_paths():
    return [os.path.join(ROOT, d) for d in (
        "core", "core/ast", "core/parser", "core/evaluator", "core/numeric",
        "core/complex", "core/rational", "core/bigint", "core/algebra",
        "core/polynomial", "core/calculus", "core/equations", "core/matrices",
        "core/statistics", "core/units", "core/constants",
        "rendering/math", "rendering/graph2d", "rendering/graph3d",
    ) if os.path.isdir(os.path.join(ROOT, d))]

def compile_target(fpc, src, out):
    cmd = [fpc, "-Mobjfpc", "-Sh"]
    for p in unit_paths():
        cmd += ["-Fu" + p]
    os.makedirs(os.path.dirname(out), exist_ok=True)
    subprocess.run(cmd + ["-o" + out, src], check=True)

if __name__ == "__main__":
    fpc = find_fpc()
    print("Using FPC:", fpc)
    compile_target(fpc, os.path.join(ROOT, "app/desktop/pmscalc.lpr"),
                   os.path.join(ROOT, "bin/pmscalc" + (".exe" if os.name == "nt" else "")))
    laz = find_lazbuild()
    if laz is None:
        print("lazbuild not found — skipping LCL desktop app (console built OK)")
    else:
        print("Using lazbuild:", laz)
        subprocess.run([laz, os.path.join(ROOT, "app/desktop/pmstudio.lpi")], check=True)
    print("Build OK")
