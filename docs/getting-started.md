# Getting started

## Requirements

FSoilTH currently requires:

- GNU Make
- GNU Fortran (`gfortran`)
- NetCDF-C
- NetCDF-Fortran

## FinnsMac profile

The `finnsmac` profile uses version-independent Homebrew paths under `/opt/homebrew/opt/` and validates the macOS dynamic-library links.

```bash
make MACHINE=finnsmac doctor
make finnsmac
make run-finnsmac
```

Inspect the selected environment:

```bash
make MACHINE=finnsmac print-config
make MACHINE=finnsmac verify-link
```

Clean the profile:

```bash
make MACHINE=finnsmac clean
```

## Generic profile

Use the generic profile when `gfortran`, `nf-config` and `nc-config` are available on `PATH`:

```bash
make MACHINE=generic
make MACHINE=generic run
```

## Build outputs

```text
build/<machine>/bin/fsoilth
build/<machine>/obj/
build/<machine>/mod/
build/bin/fsoilth            active executable symlink
```

Run `make help` for the complete command list.

## What the current run means

!!! danger "Not yet a site simulation"
    The current driver initializes hard-coded prototype states and calls water and heat routines once. It does not yet consume the complete Maqu inputs or advance over the forcing time coordinate. Successful execution therefore confirms the build and call chain, not model validity.

Current `NaN` values are a known initialization and physics-chain problem. The M0 milestone must remove them before scientific evaluation begins.

## Documentation preview

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-docs.txt
mkdocs serve
```

Strict build check:

```bash
mkdocs build --clean --strict
```
