# Code structure

```text
FSoilTH/
├── app/FSoilTH.F90              standalone driver
├── src/core/                    parameters, constants, grid and state
├── src/physics/                 hydrology and heat processes
├── src/numerics/                reusable solvers
├── src/io/                      NetCDF utilities
├── cases/maqu_2022-06/          first development case
├── config/machines/             build profiles
├── docs/                        model documentation
├── Makefile
└── mkdocs.yml
```

## Current modules

| Layer | Modules | Current responsibility |
|---|---|---|
| Core | `ModelParameterMod`, `SoilParameterMod`, `SoilConstantMod` | Run parameters, soil parameters and constants |
| State | `SoilTypeMod` | Grid/state types and prototype initialization |
| Physics | `SoilHydrologyMod`, `SoilTemperatureMod` | Hydraulic/thermal properties and solvers |
| Numerics | `TridiagonalMod` | Tridiagonal linear-system solver |
| I/O | `EmptyNetcdfMod`, `NetcdfReadMod`, `NetcdfWriteMod` | NetCDF utility routines |
| Application | `FSoilTH.F90` | Current prototype call chain |

## Intended evolution

The next architecture stage will separate grid, state and initialization; split physical properties from equation solvers; unify NetCDF error handling; and expose a driver-independent model lifecycle. Module splitting will occur only after regression tests protect the existing behavior.
