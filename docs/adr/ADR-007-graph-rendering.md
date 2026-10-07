# ADR-007 — Graph rendering: CPU sampling, adaptive, Canvas output

Status: accepted.

Plotting is CPU-side adaptive sampling in portable Pascal (`PMS.Sampler`)
emitting polylines; LCL `TCanvas` (desktop) and Canvas2D (web) only stroke
them. No GPU dependency for 2D. 3D (Phase 39) reuses the sampler as a
heightfield behind a software-projected preview; real GPU work only if a
measured need appears.

Consequence: identical plot data on desktop and web; renderer bugs split
cleanly into sampler bugs (shared) vs stroking bugs (platform).
