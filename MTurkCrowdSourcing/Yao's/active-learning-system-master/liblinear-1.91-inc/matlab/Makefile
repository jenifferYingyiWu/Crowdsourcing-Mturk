# This Makefile is used under Linux

#MATLABDIR ?= /Applications/MATLAB_R2010b.app
MATLABDIR ?= /home/barzan/matlab2012a
CXX ?= g++
#CXX = g++-3.3
CC ?= gcc
CFLAGS = -g -Wall -Wconversion -O3 -fPIC -I$(MATLABDIR)/extern/include -I..

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)"
# comment the following line if you use MATLAB on a 32-bit computer
MEX_OPTION += -largeArrayDims
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

OCTAVEDIR ?= /usr/include/octave
OCTAVE_MEX = env CC=$(CXX) mkoctfile
OCTAVE_MEX_OPTION = --mex
OCTAVE_MEX_EXT = mex
OCTAVE_CFLAGS = -Wall -O3 -fPIC -I$(OCTAVEDIR) -I..

all:	matlab

matlab:	binary

octave:
	@make MEX="$(OCTAVE_MEX)" MEX_OPTION="$(OCTAVE_MEX_OPTION)" \
	MEX_EXT="$(OCTAVE_MEX_EXT)" CFLAGS="$(OCTAVE_CFLAGS)" \
	binary

binary: inc_lltrain.$(MEX_EXT) lltrain.$(MEX_EXT) llpredict.$(MEX_EXT) libsvmread.$(MEX_EXT) libsvmwrite.$(MEX_EXT)

lltrain.$(MEX_EXT): lltrain.c ../linear.h ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a
	$(MEX) $(MEX_OPTION) lltrain.c ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a

inc_lltrain.$(MEX_EXT): inc_lltrain.c ../linear.h ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a
	$(MEX) $(MEX_OPTION) inc_lltrain.c ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a

llpredict.$(MEX_EXT): llpredict.c ../linear.h ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a
	$(MEX) $(MEX_OPTION) llpredict.c ../tron.o ../linear.o linear_model_matlab.o ../blas/blas.a

libsvmread.$(MEX_EXT):	libsvmread.c
	$(MEX) $(MEX_OPTION) libsvmread.c

libsvmwrite.$(MEX_EXT):	libsvmwrite.c
	$(MEX) $(MEX_OPTION) libsvmwrite.c

linear_model_matlab.o: linear_model_matlab.c ../linear.h
	$(CXX) $(CFLAGS) -c linear_model_matlab.c

../linear.o: ../linear.cpp ../linear.h
	make -C .. linear.o

../tron.o: ../tron.cpp ../tron.h 
	make -C .. tron.o

../blas/blas.a: ../blas/*.c ../blas/*.h
	make -C ../blas OPTFLAGS='$(CFLAGS)' CC='$(CC)';

clean:
	make -C ../blas clean
	rm -f *~ *.o *.mex* *.obj ../linear.o ../tron.o
