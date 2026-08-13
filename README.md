# FSoilTH

**A configurable frozen-soil thermo-hydrology model**

[![Documentation](https://img.shields.io/badge/docs-GitHub%20Pages-1976d2)](https://finnwindfly.github.io/FSoilTH/)
[![Documentation workflow](https://github.com/finnwindfly/FSoilTH/actions/workflows/docs.yml/badge.svg)](https://github.com/finnwindfly/FSoilTH/actions/workflows/docs.yml)

**[Read the model documentation](https://finnwindfly.github.io/FSoilTH/)**

FSoilTH is an open-source, one-dimensional Fortran model for investigating coupled water and heat transport in seasonally frozen ground and permafrost. It is being developed from Tibetan Plateau applications toward multi-site evaluation and future coupling with CTSM/CLM.

> [!IMPORTANT]
> FSoilTH is currently a research prototype. The repository can be compiled and the standalone driver can be executed, but the Maqu forcing is not yet connected to a complete time-stepping simulation and the current prototype may produce `NaN` values. It should not yet be used for scientific conclusions or engineering decisions.

## Scientific purpose

FSoilTH is designed around four questions:

1. How do liquid-water migration, freeze–thaw phase change, latent heat and heat transport control freezing fronts and active-layer dynamics?
2. Under which high-altitude or cold-region conditions do water vapor and dry-air transport materially affect observable soil states and surface fluxes?
3. How do ground ice and soil deformation influence frost heave, thaw settlement and infrastructure risk?
4. Which detailed frozen-soil processes remain important when moving from soil columns to multi-site and land-surface-model applications?

The development strategy is to establish a conservative and verifiable thermo-hydrological core before adding complexity:

```text
FSoilTH → FSoilTH-V → FSoilTH-VA → FSoilTH-M → FSoilTH-CLM
   TH         + vapor     + dry air    + mechanics    + land coupling
```

These labels describe the intended model hierarchy, not the capabilities of the current prototype.

## Current capability status

| Component | Status |
|---|---|
| One-dimensional soil grid and state types | Prototype |
| Soil hydraulic and thermal property routines | Prototype; initialization requires correction |
| Soil water and heat solvers | Prototype; verification pending |
| NetCDF utility modules | Present; not fully connected to the driver |
| Maqu input data | Included as a development case |
| Complete forcing time loop | Not yet implemented |
| Conservative freeze–thaw coupling | Planned core development |
| Vapor, dry air and deformation | Research roadmap |
| CTSM/CLM coupling | Long-term roadmap |

## Repository layout

```text
app/                         Standalone FSoilTH driver
src/core/                    Parameters, constants, grid and state types
src/physics/                 Soil hydrology and heat-transfer processes
src/numerics/                Numerical solvers
src/io/                      NetCDF input and output modules
cases/maqu_2022-06/input/    Maqu development-case inputs
config/machines/             Machine-specific build profiles
docs/                        MkDocs source documentation
mkdocs.yml                   Documentation configuration
Makefile                     Build, diagnostics and run entry point
```

## Build and run

Requirements:

- GNU Fortran (`gfortran`)
- NetCDF-C and NetCDF-Fortran
- GNU Make

On Finn's Apple Silicon MacBook with Homebrew:

```bash
make MACHINE=finnsmac doctor
make finnsmac
make run-finnsmac
```

The Conda environment is used for documentation and analysis tools; the
Fortran compiler and NetCDF libraries for the `finnsmac` build remain supplied
by Homebrew:

```bash
conda env create -f environment.yml
conda activate fsoilth
make finnsmac
make run-finnsmac
```

The machine-specific and active executable paths are:

```text
build/finnsmac/bin/fsoilth
build/bin/fsoilth
```

Useful commands:

```bash
make help
make MACHINE=finnsmac print-config
make MACHINE=finnsmac verify-link
make MACHINE=finnsmac clean
make clean-all
```

On another machine where `gfortran`, `nf-config` and `nc-config` are on `PATH`:

```bash
make MACHINE=generic
make MACHINE=generic run
```

## Maqu development case

The files under `cases/maqu_2022-06/input/` contain surface properties, initial conditions and forcing for June 2022. They are retained as the first integration case, but running `make run-finnsmac` does **not yet** constitute a Maqu simulation because the driver does not yet read all inputs or advance through the forcing time axis.

The next software milestone is a reproducible Maqu workflow with validated input metadata, a forcing loop, NetCDF output, and water and energy balance diagnostics.

## Documentation

Create or update the project environment and preview the documentation locally:

```bash
conda env create -f environment.yml     # first installation only
conda activate fsoilth
mkdocs serve
```

If the environment already exists, synchronize it with:

```bash
conda env update -n fsoilth -f environment.yml --prune
```

Validate it before publication:

```bash
mkdocs build --clean --strict
```

The model documentation is published through GitHub Pages at:

```text
https://finnwindfly.github.io/FSoilTH/
```

## Development priorities

1. Remove out-of-bounds access and `NaN` values; validate grid geometry and initialization.
2. Introduce `initialize → advance → diagnostics → finalize` and a forcing time loop.
3. Adopt `real64`, consistent SI units, input validation, restart output and conservation diagnostics.
4. Implement and verify conservative frozen-soil thermo-hydrology with standard benchmarks.
5. Add surface, snow and vegetation boundaries at the minimum complexity needed for site studies.
6. Evaluate vapor, dry-air and deformation processes through controlled model hierarchies.
7. Develop multi-site experiments and a stable CTSM/CLM coupling interface.

See the [documentation roadmap](docs/development/roadmap.md) for milestone definitions.

## Citation

FSoilTH has not yet reached its first scientific release. Until a versioned archive and DOI are available, cite the repository and the exact Git commit used. Preliminary citation metadata are provided in [`CITATION.cff`](CITATION.cff).

## People

- Creator and lead developer: Pengfei Xu
- Scientific sponsor: Xianhong Meng
- Northwest Institute of Eco-Environment and Resources, Chinese Academy of Sciences

## Name

**FSoilTH** abbreviates **F**rozen **Soil** **T**hermo-**H**ydrology. The name states the model domain and coupled-process scope without tying the project to frost heave or any single application, while vapor, dry air, mechanics and land-model coupling remain explicit extensions.
