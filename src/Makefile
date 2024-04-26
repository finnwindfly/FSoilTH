# Compiler settings
FC = gfortran
FCFLAGS = -O3 -Wall
# FFLAGS = -L/opt/homebrew/Cellar/netcdf-fortran/4.6.1/lib -lnetcdff -lnetcdf -I/opt/homebrew/Cellar/netcdf-fortran/4.6.1/include

# Target name
TARGET = main

# Source files
SRCS = $(wildcard *.F90)

# Object files
OBJ =   ../obj/ModelParameterMod.o \
        ../obj/SoilParameterMod.o \
        ../obj/SoilConstantMod.o \
        ../obj/TridiagonalMod.o \
        ../obj/SoilTypeMod.o \
        ../obj/SoilHydrologyMod.o \
        ../obj/Main.o

$(TARGET): $(OBJ)
	$(FC) $(FCFLAGS) -o $@ $^

../obj/%.o: %.F90
	$(FC) $(FCFLAGS) $(FFLAGS) -c -o $@ $<

# Clean
.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJ) ../obj/*.o *.mod