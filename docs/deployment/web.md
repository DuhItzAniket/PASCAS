# Web deployment

## Toolchain (pinned)

Pascal-to-JS: **pas2js 2.2.0**, official release zips (compiler + RTL):

- Windows (dev): `https://downloads.freepascal.org/fpc/contrib/pas2js/2.2.0/pas2js-windows-2.2.0.zip`
  unpacked to `C:\pas2js-2.2.0` (any location works — set `PAS2JS_EXE`
  to the `pas2js` binary if elsewhere).
- CI (Linux): same page, `pas2js-linux-2.2.0.zip`, unpacked to
  `/tmp/pas2js`; `PAS2JS_EXE` points at
  `/tmp/pas2js/pas2js-linux-2.2.0/bin/x86_64-linux/pas2js`.

The Lazarus-bundled pas2js 1.5.1 ships **no RTL** and is not used.

## Build

```sh
python scripts/build_web.py    # app/web/pmsweb.js (+ refresh rtl.js)
python scripts/verify_web.py   # transpile probe + run under Node
```

`app/web/rtl.js` (the pas2js runtime bridge) is refreshed from the
toolchain on every web build; the committed copy is a fallback only.

## Serve

Any static file server. Production needs HTTPS (service-worker
requirement; `localhost` is exempt for testing):

```sh
cd app/web && python -m http.server 8000
```

## Browser support

Evergreen Chrome/Edge/Firefox (pointer events, canvas2d, localStorage,
service workers). No build step besides `build_web.py`.

## Sharing / offline

- `#hash` URLs carry the full session (copy via Copy link).
- `localStorage` keeps the last workspace automatically.
- `sw.js` caches the shell versioned (`pms-v1`); updates invalidate by
  cache-name bump. All math is local — offline works after first load.

## Pascal-compatibility notes (core must stay FPC+Pas2JS clean)

Fixes applied while porting (see PHASE-42): `Tan`/`Sinh`/`Tanh` as
one-line identities (missing from pas2js Math), `ArcTan2` via
quadrants, no static-array copies out of const records, no nested
anonymous arrays, no `SizeOf`/`DefaultFormatSettings`, parenthesized
self-calls (same FPC quirk rule as native).

Known precision caveat: pas2js numbers are doubles, so `Int64` values
beyond 2^53 lose exactness in the browser. Rational/BigInt libraries
transpile and run, but exactness past 2^53 is a desktop-only guarantee.
