# ADR-005 — Desktop: Lazarus/LCL, native controls

Status: accepted.

Desktop shell is Lazarus + LCL with native controls. No Electron/Qt/.NET.
Custom drawing (graph) uses standard `TCanvas`; BGRABitmap/OpenGL only if
measured drawing becomes the bottleneck (it hasn't).

Consequence: desktop builds need Lazarus (`lazbuild`), bundled at
`C:\lazarus` on the dev machine; CI installs `lazarus` via apt.
