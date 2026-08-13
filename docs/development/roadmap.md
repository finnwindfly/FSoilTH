# Development roadmap

## M0 — Reproducible baseline

- Remove out-of-bounds access and `NaN` values.
- Correct soil-layer center and interface geometry.
- Establish `initialize → advance → diagnostics → finalize`.
- Introduce forcing time stepping, `real64`, SI units and input validation.
- Add debug/release builds, tests, restart output and conservation residuals.

**Exit gate:** an unfrozen annual case runs without invalid values and passes water/energy, time-step and grid-convergence thresholds.

## M1 — Conservative frozen-soil thermo-hydrology

- Implement unfrozen-water and freezing-characteristic relationships.
- Couple freeze-induced suction, ice impedance and latent heat.
- Add nonlinear iteration and adaptive time stepping.
- Verify against Stefan solutions, INTERFROST-style benchmarks and laboratory experiments.

## M2 — Minimum land-surface boundary

- Rain/snow partitioning and a minimal snow scheme.
- Surface energy closure, bare-soil evaporation and root uptake.
- Replaceable upper and lower water/energy boundary conditions.

## M3 — Vapor and dry air

- Add FSoilTH-V and FSoilTH-VA configurations.
- Quantify when additional gas-phase physics changes observable behavior.

## M4 — Ground ice and deformation

- Separate pore ice, excess ice and segregation ice.
- Begin with excess-ice melt and thaw settlement.
- Add frost-heave mechanics only with an explicit validation strategy.

## M5 — Multi-site and land-model integration

- Evaluate seasonal and permafrost sites on the Tibetan Plateau and beyond.
- Combine surface-flux networks with soil and permafrost observations.
- Establish offline CTSM comparison, then an optional FSoilTH soil backend.

The milestone order is intentional: new complexity does not proceed ahead of a reproducible, conservative and verified core.
