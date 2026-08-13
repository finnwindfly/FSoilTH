# FSoilTH

## A configurable frozen-soil thermo-hydrology model

FSoilTH is a one-dimensional Fortran research model for studying coupled water and heat transport in seasonally frozen ground and permafrost. Development begins with Tibetan Plateau site applications and is structured toward global site evaluation and future CTSM/CLM coupling.

!!! warning "Research prototype"
    FSoilTH is not yet a validated scientific release. The code can be compiled and the prototype driver can run, but the Maqu forcing loop, conservative freeze–thaw core and formal verification suite are still under development. Current output may contain `NaN` values.

<div class="grid cards" markdown>

-   :material-snowflake:{ .lg .middle } **Frozen-soil core**

    ---

    Liquid water, heat transport and phase change form the intended conservative model foundation.

-   :material-layers-triple:{ .lg .middle } **Configurable complexity**

    ---

    Vapor, dry air and deformation are introduced as testable extensions rather than assumed necessities.

-   :material-chart-bell-curve-cumulative:{ .lg .middle } **Verification first**

    ---

    Conservation diagnostics, analytical solutions, benchmark experiments and site evaluation define model readiness.

-   :material-earth:{ .lg .middle } **From columns to land models**

    ---

    Stable state and flux interfaces are planned for multi-site studies and future CTSM/CLM coupling.

</div>

## Scientific questions

1. How do liquid-water migration, phase change and heat transport control freezing fronts and active-layer dynamics?
2. When do vapor and dry-air processes become observable in high-altitude and other cold-region soils?
3. How do ground ice and deformation connect subsurface physics to frost heave, thaw settlement and infrastructure risk?
4. Which detailed processes remain important when moving from a soil column to regional and global land applications?

## Model hierarchy

```text
FSoilTH → FSoilTH-V → FSoilTH-VA → FSoilTH-M → FSoilTH-CLM
   TH         + vapor     + dry air    + mechanics    + land coupling
```

The hierarchy is a research roadmap. Only capabilities marked as implemented and verified in a versioned release should be used in scientific experiments.

## Current status

| Area | Status | Next gate |
|---|---|---|
| Build system | Working on FinnsMac and generic profiles | Continuous integration |
| Soil grid and state | Prototype | Correct geometry and validated initialization |
| Water and heat solvers | Prototype | Remove `NaN`, add convergence and conservation tests |
| NetCDF I/O | Utility modules present | Connect case inputs, forcing loop and output |
| Maqu case | Inputs organized | Reproducible end-to-end simulation |
| Freeze–thaw | Planned core | Stefan and frozen-soil benchmarks |
| Vapor, air, deformation | Planned extensions | Process-specific ablation experiments |

## Start here

- [Build and run the prototype](getting-started.md)
- [Understand the model scope](model/overview.md)
- [Review the development roadmap](development/roadmap.md)
- [Inspect the Maqu development case](cases/maqu.md)
