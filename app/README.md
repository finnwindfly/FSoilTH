# Standalone application

`FSoilTH.F90` is the current standalone FSoilTH driver. It remains outside `src/` so that the modules under `src/` can evolve into a reusable model library for tests and future coupling applications.

The driver is currently a prototype call-chain test. It does not yet implement a complete forcing time loop or a validated Maqu simulation.
