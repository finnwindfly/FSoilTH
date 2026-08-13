# FSoilTH build system
#
# Common commands:
#   make help
#   make finnsmac
#   make run-finnsmac
#   make MACHINE=finnsmac doctor

MACHINE ?= generic
MACHINE_FILE := config/machines/$(MACHINE).mk

ifeq ($(wildcard $(MACHINE_FILE)),)
$(error Unknown MACHINE='$(MACHINE)'. Available profiles: generic, finnsmac. Run 'make help')
endif

include $(MACHINE_FILE)

FCFLAGS ?= -O3 -Wall

BUILD_ROOT := build
PROFILE_BUILD_DIR := $(BUILD_ROOT)/$(MACHINE)
OBJ_DIR := $(PROFILE_BUILD_DIR)/obj
MOD_DIR := $(PROFILE_BUILD_DIR)/mod
BIN_DIR := $(PROFILE_BUILD_DIR)/bin
TARGET := $(BIN_DIR)/fsoilth

# Backward-compatible path used by earlier instructions and terminal sessions.
ACTIVE_BIN_DIR := $(BUILD_ROOT)/bin
ACTIVE_TARGET := $(ACTIVE_BIN_DIR)/fsoilth

vpath %.F90 app src/core src/physics src/numerics src/io

OBJ := \
	$(OBJ_DIR)/ModelParameterMod.o \
	$(OBJ_DIR)/SoilParameterMod.o \
	$(OBJ_DIR)/SoilConstantMod.o \
	$(OBJ_DIR)/TridiagonalMod.o \
	$(OBJ_DIR)/SoilTypeMod.o \
	$(OBJ_DIR)/EmptyNetcdfMod.o \
	$(OBJ_DIR)/NetcdfReadMod.o \
	$(OBJ_DIR)/NetcdfWriteMod.o \
	$(OBJ_DIR)/SoilHydrologyMod.o \
	$(OBJ_DIR)/SoilTemperatureMod.o \
	$(OBJ_DIR)/FSoilTH.o

.DEFAULT_GOAL := all

.PHONY: all help doctor print-config verify-link activate run rebuild clean clean-all finnsmac run-finnsmac

all: activate

help:
	@echo "FSoilTH build help"
	@echo ""
	@echo "Recommended commands for Finn's Mac:"
	@echo "  make finnsmac              Clean and build with the local Homebrew profile"
	@echo "  make run-finnsmac          Build if needed, then run the model"
	@echo "  make MACHINE=finnsmac doctor"
	@echo "                              Check compiler and NetCDF installation"
	@echo "  make MACHINE=finnsmac verify-link"
	@echo "                              Show and validate macOS dynamic-library links"
	@echo "  make MACHINE=finnsmac clean"
	@echo "                              Remove only Finn's Mac build products"
	@echo ""
	@echo "Generic/other machine commands:"
	@echo "  make MACHINE=generic       Build using gfortran, nf-config and nc-config"
	@echo "  make MACHINE=generic run   Run the generic build"
	@echo "  make MACHINE=<name> print-config"
	@echo "                              Print the selected compiler and library paths"
	@echo "  make clean-all             Remove all generated build products"
	@echo ""
	@echo "Executable paths after 'make finnsmac':"
	@echo "  build/finnsmac/bin/fsoilth  Machine-specific executable"
	@echo "  build/bin/fsoilth           Active symlink"
	@echo ""
	@echo "Note: 'make --help' is GNU Make's own option and cannot be replaced by"
	@echo "this project. Use 'make help' for FSoilTH project help."

doctor:
	@echo "Checking MACHINE=$(MACHINE)"
	@command -v "$(FC)" >/dev/null 2>&1 || { echo "Error: Fortran compiler not found: $(FC)"; exit 1; }
ifeq ($(MACHINE),finnsmac)
	@test -x "$(BREW)" || { echo "Error: Homebrew not found at $(BREW)"; exit 1; }
	@test -f "$(NETCDFF_MOD)" || { echo "Error: netcdf.mod not found: $(NETCDFF_MOD)"; echo "Try: brew reinstall netcdf netcdf-fortran"; exit 1; }
	@test -f "$(NETCDFF_DYLIB)" || { echo "Error: NetCDF-Fortran library not found: $(NETCDFF_DYLIB)"; exit 1; }
	@test -f "$(NETCDF_DYLIB)" || { echo "Error: NetCDF-C library not found: $(NETCDF_DYLIB)"; exit 1; }
else
	@command -v "$(NF_CONFIG)" >/dev/null 2>&1 || { echo "Error: nf-config not found"; exit 1; }
	@command -v "$(NC_CONFIG)" >/dev/null 2>&1 || { echo "Error: nc-config not found"; exit 1; }
endif
	@echo "Environment check: OK"

print-config:
	@echo "MACHINE         = $(MACHINE)"
	@echo "FC              = $(FC)"
	@echo "FCFLAGS         = $(FCFLAGS)"
	@echo "NETCDF_FFLAGS   = $(NETCDF_FFLAGS)"
	@echo "NETCDF_LIBS     = $(NETCDF_LIBS)"
	@echo "RPATH_FLAGS     = $(RPATH_FLAGS)"
	@echo "TARGET          = $(TARGET)"

$(TARGET): $(OBJ) | doctor $(BIN_DIR)
	$(FC) $(FCFLAGS) -o $@ $(OBJ) $(NETCDF_LIBS) $(RPATH_FLAGS)

$(OBJ_DIR)/%.o: %.F90 | $(OBJ_DIR) $(MOD_DIR)
	$(FC) $(FCFLAGS) $(NETCDF_FFLAGS) -J$(MOD_DIR) -I$(MOD_DIR) -c -o $@ $<

$(OBJ_DIR)/SoilTypeMod.o: $(OBJ_DIR)/ModelParameterMod.o $(OBJ_DIR)/SoilParameterMod.o
$(OBJ_DIR)/SoilHydrologyMod.o: $(OBJ_DIR)/ModelParameterMod.o $(OBJ_DIR)/SoilParameterMod.o $(OBJ_DIR)/SoilConstantMod.o $(OBJ_DIR)/TridiagonalMod.o $(OBJ_DIR)/SoilTypeMod.o
$(OBJ_DIR)/SoilTemperatureMod.o: $(OBJ_DIR)/ModelParameterMod.o $(OBJ_DIR)/SoilParameterMod.o $(OBJ_DIR)/SoilConstantMod.o $(OBJ_DIR)/TridiagonalMod.o $(OBJ_DIR)/SoilTypeMod.o
$(OBJ_DIR)/FSoilTH.o: $(OBJ_DIR)/ModelParameterMod.o $(OBJ_DIR)/SoilParameterMod.o $(OBJ_DIR)/SoilConstantMod.o $(OBJ_DIR)/TridiagonalMod.o $(OBJ_DIR)/SoilTypeMod.o $(OBJ_DIR)/SoilHydrologyMod.o $(OBJ_DIR)/SoilTemperatureMod.o

$(OBJ_DIR) $(MOD_DIR) $(BIN_DIR) $(ACTIVE_BIN_DIR):
	mkdir -p $@

verify-link: $(TARGET)
ifeq ($(shell uname -s),Darwin)
	@echo "Dynamic libraries for $(TARGET):"
	@otool -L "$(TARGET)"
ifeq ($(MACHINE),finnsmac)
	@otool -L "$(TARGET)" | grep -F "$(NETCDF_PREFIX)/lib/libnetcdf." >/dev/null || { \
		echo "Error: executable is not linked to Finn's current Homebrew NetCDF"; \
		exit 1; \
	}
	@if otool -L "$(TARGET)" | grep -Fq '@rpath/libnetcdf.19.dylib'; then \
		echo "Error: stale libnetcdf.19 dependency detected. Run: make finnsmac"; \
		exit 1; \
	fi
endif
else
	@echo "Link verification is currently implemented for macOS; skipping otool."
endif

activate: verify-link | $(ACTIVE_BIN_DIR)
	@ln -sfn "../$(MACHINE)/bin/fsoilth" "$(ACTIVE_TARGET)"
	@echo "Active executable: $(ACTIVE_TARGET) -> ../$(MACHINE)/bin/fsoilth"

run: activate
	$(TARGET)

rebuild:
	@$(MAKE) --no-print-directory MACHINE=$(MACHINE) clean
	@$(MAKE) --no-print-directory MACHINE=$(MACHINE) all

# Convenience profiles. These recursive calls guarantee a clean machine build.
finnsmac:
	@$(MAKE) --no-print-directory MACHINE=finnsmac rebuild

run-finnsmac:
	@$(MAKE) --no-print-directory MACHINE=finnsmac run

clean:
	rm -rf "$(PROFILE_BUILD_DIR)" "$(ACTIVE_TARGET)"

clean-all:
	rm -rf "$(BUILD_ROOT)"
