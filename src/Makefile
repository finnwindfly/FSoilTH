# Compiler settings
FC = gfortran
FCFLAGS = -O3 -Wall

# Target name
TARGET = main

# Source files
SRCS = $(wildcard *.F90)

# Object files
OBJ = ModelParameterMod.o \
      SoilParameterMod.o \
	  Main.o

$(TARGET): $(OBJ)
	$(FC) $(FCFLAGS) -o $@ $^

%.o: %.F90
	$(FC) $(FCFLAGS) -c -o $@ $<

# Clean
.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJ) *.mod