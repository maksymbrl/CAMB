#================================================================================
# Author: Maksym Brilenkov
#================================================================================
# This will check the git submodules for CAMB project (i.e. forutils)
if(GIT_SUBMODULE)
	message(STATUS "Submodule update")
	execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
									WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
									RESULT_VARIABLE GIT_SUBMOD_RESULT)
	if(NOT GIT_SUBMOD_RESULT EQUAL "0")
		message(FATAL_ERROR "git submodule update --init failed with ${GIT_SUBMOD_RESULT}, please checkout submodules")
	endif()
endif()

# Check whether forutils were downloaded correctly
if(NOT EXISTS "${PROJECT_SOURCE_DIR}/forutils")
	message(FATAL_ERROR "The submodules were not downloaded! GIT_SUBMODULE was turned off or failed. Please update submodules and try again.")
else()
	# Adding sources and trying to compile forutils as standalone library
	set(FORUTILS_TARGET "forutils")
	# 
	set(FORUTILS_SOURCE_DIR "${PROJECT_SOURCE_DIR}/forutils")
	set(FORUTILS_SOURCES
			"${FORUTILS_SOURCE_DIR}/MiscUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/MpiUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/StringUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/ArrayUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/FileUtils.f90"
			"${FORUTILS_SOURCE_DIR}/IniObjects.f90" 
			"${FORUTILS_SOURCE_DIR}/RandUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/ObjectLists.f90" 
			"${FORUTILS_SOURCE_DIR}/MatrixUtils.f90" 
			"${FORUTILS_SOURCE_DIR}/RangeUtils.f90"
			"${FORUTILS_SOURCE_DIR}/Interpolation.f90"
		)
	# Creating library target -- `libforutils.a`
	add_library(${FORUTILS_TARGET}
		"${FORUTILS_SOURCES}"
		)
	# Resolving Preprocessor statements for a given Compiler Toolchain
	# (i.e. adding "-fpp" or "-cpp")
	set_source_files_properties( 
		"${FORUTILS_SOURCES}"
	  PROPERTIES Fortran_PREPROCESS ON
		)
	#target_include_directories("${FORUTILS_TARGET}"
	#	"${FORUTILS_SOURCE_DIR}"
	#	)
	if(CAMB_USE_MPI)
		# Note: -D will be added automatically by CMake
		target_compile_definitions(${FORUTILS_TARGET}
			PUBLIC
			MPI
			)
	endif()
	# linking MPI
	if(CAMB_USE_MPI)
		target_link_libraries("${FORUTILS_TARGET}"
			PUBLIC 
			MPI::MPI_Fortran
			)
	endif()
	target_link_libraries(${FORUTILS_TARGET}
		PUBLIC
		OpenMP::OpenMP_Fortran
		"${MATH_LIB}"
		)
	# TODO: make this work for MPI and also Release, Debug and the same for GNU compielrs
	# if our compilers are from Intel
	# Note: "-fPIC" flag is added by position independent code automatically
	if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
		target_compile_options(${FORUTILS_TARGET}
			PUBLIC
			"-fpp"
			"-W0"
			"-WB"
			#"-fpic"
			"-gen-dep=.d"
			"-fast"
			)
	elseif(CMAKE_Fortran_COMPILER_ID MATCHES GNU)
		target_compile_options(${FORUTILS_TARGET}
			PUBLIC
			"-cpp" # <= doesn't work otherwise (although added PREPROC above :/)
			"-ffree-line-length-none"
			"-fmax-errors=4"
			"-MMD"
			"-ffast-math"
			#"-gen-dep=.d"
			"-march=native"
			)
		#-O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native
		#-cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o Misc    Utils.o -c
	endif()
	# Note: ${CMAKE_INSTALL_LIBDIR} sometimes is lib64 and sometimes is lib, 
	# so it is better to use explicit value lib
	#message("${CMAKE_INSTALL_LIBDIR}")
	# Installing CAMB Forutils project
	# For future reference:
	# https://cmake.org/cmake/help/latest/command/install.html
	# Note: these are basically default values which comes with GNUDirs
	# but on some platforms targets maybe installed in lib64 instead, so
	# probably a good idea to specify these things explicitly.
	install(TARGETS ${FORUTILS_TARGET}
		ARCHIVE
			DESTINATION "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}"
			COMPONENT lib
		LIBRARY
			DESTINATION "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}"
			COMPONENT lib
		PRIVATE_HEADER
			DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
			COMPONENT include
		PUBLIC_HEADER
			DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
			COMPONENT include
		)
endif()



# Output from make command:
#[==[
# options for GNU GCC 10.3.0
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o MiscUtils.o -c ../MiscUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o MpiUtils.o -c ../MpiUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o StringUtils.o -c ../StringUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o ArrayUtils.o -c ../ArrayUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o FileUtils.o -c ../FileUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o IniObjects.o -c ../IniObjects.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o RandUtils.o -c ../RandUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o ObjectLists.o -c ../ObjectLists.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o MatrixUtils.o -c ../MatrixUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o RangeUtils.o -c ../RangeUtils.f90
gfortran -cpp -ffree-line-length-none -fmax-errors=4 -MMD -fopenmp -fPIC -O3 -ffast-math -o Interpolation.o -c ../Interpolation.f90
ar -r libforutils.a MiscUtils.o MpiUtils.o StringUtils.o ArrayUtils.o FileUtils.o IniObjects.o RandUtils.o ObjectLists.o MatrixUtils.o RangeUtils.o Interpolation.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../constants.f90 -o constants.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../config.f90 -o config.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../classes.f90 -o classes.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../MathUtils.f90 -o MathUtils.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../subroutines.f90 -o subroutines.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkAge21cm.f90 -o DarkAge21cm.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyInterface.f90 -o DarkEnergyInterface.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../SourceWindows.f90 -o SourceWindows.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../massive_neutrinos.f90 -o massive_neutrinos.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../model.f90 -o model.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../results.f90 -o results.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../bessels.f90 -o bessels.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../recfast.f90 -o recfast.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyFluid.f90 -o DarkEnergyFluid.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyPPF.f90 -o DarkEnergyPPF.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../PowellMinimize.f90 -o PowellMinimize.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyQuintessence.f90 -o DarkEnergyQuintessence.o
gfortran -O3 -MMD -cpp -ffree-line-length-none -fmax-errors=4 -fopenmp -march=native -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../equations.f90 -o equations.o

# These options are only for Intel as far as I understand
make -C Release --no-print-directory -f../Makefile FORUTILS_SRC_DIR=.. libforutils.a
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o MiscUtils.o -c ../MiscUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o MpiUtils.o -c ../MpiUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o StringUtils.o -c ../StringUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o ArrayUtils.o -c ../ArrayUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o FileUtils.o -c ../FileUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o IniObjects.o -c ../IniObjects.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o RandUtils.o -c ../RandUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o ObjectLists.o -c ../ObjectLists.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o MatrixUtils.o -c ../MatrixUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o RangeUtils.o -c ../RangeUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -o Interpolation.o -c ../Interpolation.f90
xiar -r libforutils.a MiscUtils.o MpiUtils.o StringUtils.o ArrayUtils.o FileUtils.o IniObjects.o RandUtils.o ObjectLists.o MatrixUtils.o RangeUtils.o Interpolation.o
xiar: executing 'ar'
ar: creating libforutils.a
make -C Debug --no-print-directory -f../Makefile FORUTILS_SRC_DIR=.. libforutils.a
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o MiscUtils.o -c ../MiscUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o MpiUtils.o -c ../MpiUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o StringUtils.o -c ../StringUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o ArrayUtils.o -c ../ArrayUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o FileUtils.o -c ../FileUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o IniObjects.o -c ../IniObjects.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o RandUtils.o -c ../RandUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o ObjectLists.o -c ../ObjectLists.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o MatrixUtils.o -c ../MatrixUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o RangeUtils.o -c ../RangeUtils.f90
ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -o Interpolation.o -c ../Interpolation.f90
xiar -r libforutils.a MiscUtils.o MpiUtils.o StringUtils.o ArrayUtils.o FileUtils.o IniObjects.o RandUtils.o ObjectLists.o MatrixUtils.o RangeUtils.o Interpolation.o
xiar: executing 'ar'
ar: creating libforutils.a
make -C ReleaseMPI --no-print-directory -f../Makefile FORUTILS_SRC_DIR=.. libforutils.a
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o MiscUtils.o -c ../MiscUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o MpiUtils.o -c ../MpiUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o StringUtils.o -c ../StringUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o ArrayUtils.o -c ../ArrayUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o FileUtils.o -c ../FileUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o IniObjects.o -c ../IniObjects.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o RandUtils.o -c ../RandUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o ObjectLists.o -c ../ObjectLists.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o MatrixUtils.o -c ../MatrixUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o RangeUtils.o -c ../RangeUtils.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -fast -DMPI -o Interpolation.o -c ../Interpolation.f90
Warning: the -fast option forces static linkage method for the Intel(R) MPI Library.
xiar -r libforutils.a MiscUtils.o MpiUtils.o StringUtils.o ArrayUtils.o FileUtils.o IniObjects.o RandUtils.o ObjectLists.o MatrixUtils.o RangeUtils.o Interpolation.o
xiar: executing 'ar'
ar: creating libforutils.a
make -C DebugMPI --no-print-directory -f../Makefile FORUTILS_SRC_DIR=.. libforutils.a
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o MiscUtils.o -c ../MiscUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o MpiUtils.o -c ../MpiUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o StringUtils.o -c ../StringUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o ArrayUtils.o -c ../ArrayUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o FileUtils.o -c ../FileUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o IniObjects.o -c ../IniObjects.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o RandUtils.o -c ../RandUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o ObjectLists.o -c ../ObjectLists.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o MatrixUtils.o -c ../MatrixUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o RangeUtils.o -c ../RangeUtils.f90
mpiifort -fc=ifort -fpp -W0 -WB -qopenmp -fpic -gen-dep=.d -g -traceback -DMPI -o Interpolation.o -c ../Interpolation.f90
xiar -r libforutils.a MiscUtils.o MpiUtils.o StringUtils.o ArrayUtils.o FileUtils.o IniObjects.o RandUtils.o ObjectLists.o MatrixUtils.o RangeUtils.o Interpolation.o
xiar: executing 'ar'
ar: creating libforutils.a
]==]

