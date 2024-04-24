#compiler setting
FC = gfortran
FCFLAGE = -o3 -Wall

#target name
TARGET = helloworld

#source file
SRCS = helloworld.f90

#objective file
OBJ = helloworld.o

$(TARGET): $(OBJ)
	$(FC) $(FCFLAGE) -o $@ $^

%.o: %.f90
	$(FC) $(FCFLAGE) -c -o $@ $<

# Clean
clean:
	rm -rf $(TARGET) $(OBJ) *.mod