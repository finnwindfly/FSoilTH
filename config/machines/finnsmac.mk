# Machine profile for Finn's Apple Silicon MacBook with Homebrew in /opt/homebrew.
# Full dylib paths are intentional: they prevent Conda/base or stale @rpath
# libraries from being selected at link time.

HOMEBREW_PREFIX ?= /opt/homebrew
BREW := $(HOMEBREW_PREFIX)/bin/brew

# Use Homebrew's version-independent opt symlinks. Do not use Cellar paths here:
# the Cellar directory changes whenever a formula is upgraded.
NETCDF_PREFIX := $(HOMEBREW_PREFIX)/opt/netcdf
NETCDFF_PREFIX := $(HOMEBREW_PREFIX)/opt/netcdf-fortran
GCC_PREFIX := $(HOMEBREW_PREFIX)/opt/gcc

FC := $(HOMEBREW_PREFIX)/bin/gfortran

NETCDFF_MOD := $(NETCDFF_PREFIX)/include/netcdf.mod
NETCDFF_DYLIB := $(NETCDFF_PREFIX)/lib/libnetcdff.dylib
NETCDF_DYLIB := $(NETCDF_PREFIX)/lib/libnetcdf.dylib

NETCDF_FFLAGS := -I$(NETCDFF_PREFIX)/include
NETCDF_LIBS := $(NETCDFF_DYLIB) $(NETCDF_DYLIB)
RPATH_FLAGS := \
	-Wl,-rpath,$(NETCDFF_PREFIX)/lib \
	-Wl,-rpath,$(NETCDF_PREFIX)/lib \
	-Wl,-rpath,$(GCC_PREFIX)/lib/gcc/current
