#================================================================================
# Authors: Maksym Brilenkov
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
	# libforutils.a
	add_library(${FORUTILS_TARGET}
		"${FORUTILS_SOURCES}"
		)
	#target_include_directories("${FORUTILS_TARGET}"
	#	"${FORUTILS_SOURCE_DIR}"
	#	)
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
	target_compile_options(${FORUTILS_TARGET}
		PUBLIC
		"-fpp"
		"-W0"
		"-WB"
		"-fpic"
		"-gen-dep=.d"
		"-fast"
		)
	# Note: ${CMAKE_INSTALL_LIBDIR} sometimes is lib64 and sometimes is lib, 
	# so it is better to use explicit value lib
	message("${CMAKE_INSTALL_LIBDIR}")
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
	message("${FORUTILS_SOURCE_DIR}")
endif()



# Output from make command:
#[==[
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

