# Maqu development case: June 2022

Maqu is the first site selected for connecting FSoilTH to observationally based surface, initial and forcing data on the Tibetan Plateau.

## Inputs

| File | Intended content |
|---|---|
| `forcedata_30T_MAQU202206.nc` | Surface water and energy forcing |
| `initialdata_MAQU_20220601.nc` | Initial soil temperature and liquid water |
| `surfacedata_MAQU.nc` | Sand, clay and organic-matter information |

The files are stored under `cases/maqu_2022-06/input/`.

## Current limitation

!!! warning
    The standalone driver does not yet read all inputs or iterate over the 1440 forcing records. The case is organized but not operational.

Before scientific use, the workflow must resolve:

- whether the forcing interval is 30 minutes or 3 hours;
- time coordinate, calendar and time-zone conventions;
- flux signs, units and accumulated-versus-instantaneous definitions;
- soil layer centers and interfaces;
- initialization of liquid water, ice and temperature;
- texture and organic-matter definitions;
- data provenance, processing history and licence.

## Completion criteria

A completed Maqu case will provide:

1. a version-controlled configuration file;
2. validated and documented inputs;
3. a complete forcing time loop;
4. NetCDF state and flux output;
5. water and energy balance diagnostics;
6. comparison against soil temperature and moisture observations;
7. a reproducible plotting and evaluation workflow.
