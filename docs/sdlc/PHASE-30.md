# Phase 30 — Units and Dimensional Analysis

## Objective

SI-based quantities: `5 kg * 9.81 m/s^2 = 49.05 N`.

## Implementation

`core/units/pms.units.pas` (`PMS.Units`): dimension vectors over
7 SI bases, ~45-unit registry, compound parsing (`kg*m/s^2`),
absolute temperatures with offsets (validated: 32°F/0°C → 273.15K),
add/sub with dimensional validation (`ceDomain` on mismatch),
alias display (`N`, `J`, `W`, `Pa`...). Case-SENSITIVE names, documented:
`F` = farad (`degF`), `C` = coulomb (`degC`), `S` = siemens (`s`).

## Tests

In `tests/unit/test_units_deps.lpr` (spec example + conversions +
refusals). **Passed.**
