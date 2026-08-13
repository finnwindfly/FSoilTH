# Generic compiler and NetCDF discovery profile.

ifeq ($(origin FC),default)
FC := gfortran
endif

NF_CONFIG ?= nf-config
NC_CONFIG ?= nc-config

NETCDF_FFLAGS := $(shell $(NF_CONFIG) --fflags 2>/dev/null)
NETCDF_C_LDFLAGS := $(filter -L%,$(shell $(NC_CONFIG) --libs 2>/dev/null))
NETCDF_LIBS := $(NETCDF_C_LDFLAGS) $(shell $(NF_CONFIG) --flibs 2>/dev/null)
RPATH_FLAGS :=
