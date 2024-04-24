# Compiler settings
FC = gfortran
FCFLAGS = -O3 -Wall

# Target name
TARGET = main

# Source files
SRCS = $(wildcard *.F90)

# Object files
OBJ = ../obj/ModelParameterMod.o \
      ../obj/SoilParameterMod.o \
	  ../obj/SoilConstantMod.o \
	  ../obj/Main.o

$(TARGET): $(OBJ)
	$(FC) $(FCFLAGS) -o $@ $^

../obj/%.o: %.F90
	$(FC) $(FCFLAGS) -c -o $@ $<

# Clean
.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJ) ../obj/*.o *.mod