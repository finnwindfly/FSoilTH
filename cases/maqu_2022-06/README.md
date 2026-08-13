# Maqu development case: June 2022

This directory contains the current Maqu inputs selected for the first FSoilTH site-integration case.

## Input files

| File | Intended purpose |
|---|---|
| `input/forcedata_30T_MAQU202206.nc` | Surface water and energy forcing for June 2022 |
| `input/initialdata_MAQU_20220601.nc` | Initial soil temperature and liquid-water state |
| `input/surfacedata_MAQU.nc` | Soil texture and organic-matter information |

## Current status

These inputs have been organized as a canonical development case, but the current standalone driver does not yet read all three files or advance over the forcing time coordinate. Running the executable is therefore not yet a Maqu simulation.

## Metadata requiring confirmation

- The forcing file contains 1440 time records, consistent with 30-minute data for a 30-day month, while an existing global attribute describes a 3-hour resolution.
- Flux sign conventions, units, time zone/calendar and missing-value treatment must be documented and checked.
- Soil layer centers, interfaces, texture definitions and organic-matter units must be reconciled with FSoilTH state conventions.
- Data provenance, processing history and reuse licence must be recorded before publication.

The completed case will include a configuration file, validated input metadata, model output and water/energy balance diagnostics.
