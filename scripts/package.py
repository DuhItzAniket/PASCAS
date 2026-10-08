"""Desktop + web packaging (Phase 47): reproducible portable archives.
Reads the version from core/pms.appname.pas (single source of truth).
Usage: python scripts/package.py [--web-only | --desktop-only]"""
import os, re, shutil, sys, zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EXE = ".exe" if os.name == "nt" else ""


def version():
    src = open(os.path.join(ROOT, "core/pms.appname.pas")).read()
    m = re.search(r"PMSVersion\s*=\s*'([^']+)'", src)
    if not m:
        raise SystemExit("PMSVersion not found")
    return m.group(1)


def plat():
    if os.name == "nt":
        return "win-x64"
    import platform
    return {"Linux": "linux-x64", "Darwin": "macos-arm64"}.get(
        platform.system(), "unknown")


def zipdir(zf, src, arc):
    for base, _, files in os.walk(src):
        for f in files:
            full = os.path.join(base, f)
            zf.write(full, os.path.join(arc, os.path.relpath(full, src)))


def desktop(v, p):
    out = os.path.join(ROOT, "dist",
                       f"PascalMathStudio-{p}-{v}.zip")
    required = [f"pmscalc{EXE}", f"pmstudio{EXE if os.name == 'nt' else ''}"]
    missing = [b for b in required
               if not os.path.isfile(os.path.join(ROOT, "bin", b))]
    if missing:
        print("missing binaries (run scripts/build.py first):",
              ", ".join(missing))
        return None
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        for b in required:
            zf.write(os.path.join(ROOT, "bin", b), b)
        for doc in ["README.md", "LICENSE", "CHANGELOG.md"]:
            zf.write(os.path.join(ROOT, doc), doc)
    print("desktop package:", out)
    return out


def web(v):
    out = os.path.join(ROOT, "dist", f"pascalmath-web-{v}.zip")
    src = os.path.join(ROOT, "app/web")
    need = ["index.html", "style.css", "pmsweb.js", "rtl.js",
            "manifest.webmanifest", "sw.js"]
    missing = [f for f in need if not os.path.isfile(os.path.join(src, f))]
    if missing:
        print("missing web files (run scripts/build_web.py first):",
              ", ".join(missing))
        return None
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zf:
        zipdir(zf, src, ".")
    print("web package:", out)
    return out


if __name__ == "__main__":
    v = version()
    print("version:", v)
    args = sys.argv[1:]
    ok = True
    if "--web-only" not in args:
        ok = desktop(v, plat()) is not None and ok
    if "--desktop-only" not in args:
        ok = web(v) is not None and ok
    sys.exit(0 if ok else 1)
