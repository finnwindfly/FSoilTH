# Scope and design

## Model identity

**FSoilTH** abbreviates **F**rozen **Soil** **T**hermo-**H**ydrology. It identifies the model domain and coupled-process scope without tying the project to frost heave or another single application. The conservative frozen-soil water–heat core is the foundation, while vapor, dry air, mechanics and land-surface coupling are explicit extensions.

The primary computational domain is a vertical soil column. Initial applications target seasonally frozen ground and permafrost on the Tibetan Plateau, but the governing interfaces and validation strategy are intended to remain geographically general.

## Design principles

### Conservation before complexity

Every model level must expose water and energy residuals. A more detailed configuration is accepted only when it passes the same conservation, convergence and benchmark tests as the simpler core.

### Configurable process hierarchy

Advanced processes are switches within a controlled hierarchy. This makes it possible to ask whether vapor, air pressure or deformation improves observable behavior under identical forcing and parameter assumptions.

### Equation–code–test traceability

Each implemented equation should map to a Fortran module, parameter source, unit convention and verification case. The online documentation is part of the model, not a separate narrative written after development.

### Driver-independent physics

Physics routines should receive state, parameters, forcing and time step through explicit interfaces. NetCDF and site-specific data handling remain in the driver layer, supporting future use of the same core beneath CTSM/CLM surface processes.

## Intended system boundary

The long-term soil domain includes:

- liquid water, ice and water vapor;
- soil heat storage, conduction, advection and phase-change latent heat;
- optional dry-air mass and pressure effects;
- ground ice, layer-thickness change and selected deformation processes;
- configurable upper and lower water and energy boundaries.

Snow, vegetation and evapotranspiration will initially be represented by minimal replaceable boundary modules. They are necessary for site forcing but are not the first scientific novelty of FSoilTH.

## Current implementation boundary

The current repository contains prototype soil-grid/state types, hydraulic and thermal routines, tridiagonal numerics and NetCDF utilities. It does not yet contain a verified frozen-soil solver, complete time driver, conservative diagnostics or validated surface boundary model.

See [Process hierarchy](process-hierarchy.md) and [Roadmap](../development/roadmap.md).
