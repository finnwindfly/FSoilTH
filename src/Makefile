# Compiler settings
FC = gfortran
FCFLAGS = -O3 -Wall

# Target name
TARGET = main

# Source files
SRCS = $(wildcard *.F90)
SRCS_WITHOUT_MAIN = $(filter-out Main.F90, $(SRCS))

# Object files
OBJ = $(patsubst %.F90,%.o,$(SRCS_WITHOUT_MAIN)) Main.o

$(TARGET): $(OBJ)
	$(FC) $(FCFLAGS) -o $@ $^

%.o: %.F90
	$(FC) $(FCFLAGS) -c -o $@ $<

# Clean
.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJ) *.mod