# Source-code layout

- `core/`: model parameters, physical constants, soil grid/state types and initialization.
- `physics/`: soil hydrology and soil heat-transfer calculations.
- `numerics/`: reusable numerical solvers.
- `io/`: NetCDF file creation, reading and writing.

The existing Fortran module and file names are intentionally retained in this first structural refactor. Renaming and splitting modules should be performed later, together with regression tests, so that file movement is not mixed with changes to scientific behaviour.
