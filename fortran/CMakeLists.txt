if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
	message(FATAL_ERROR
		"IN-SOURCE BUILDS ARE NOT ALLOWED! Please, create 'build' directory and run configuration from it."
	)
endif()

cmake_minimum_required(VERSION 3.17 FATAL_ERROR)
project(CAMB
	LANGUAGES Fortran
	)

find_package(OpenMP COMPONENTS Fortran)
find_package(MPI COMPONENTS Fortran)

set(CAMB_SOURCES
		bessels.f90
		camb.f90
		camb_python.f90
		classes.f90
		cmbmain.f90
		config.f90
		constants.f90
		cosmorec.f90
		DarkAge21cm.f90
		DarkEnergyFluid.f90
		DarkEnergyInterface.f90
		DarkEnergyPPF.f90
		DarkEnergyQuintessence.f90
		equations.f90
		halofit.f90
		hyrec.f90
		inidriver.f90
		InitialPower.f90
		lensing.f90
		massive_neutrinos.f90
		MathUtils.f90
		model.f90
		PowellMinimize.f90
		recfast.f90
		reionization.f90
		results.f90
		SecondOrderPK.f90
		SeparableBispectrum.f90
		sigma8.f90
		SourceWindows.f90
		subroutines.f90
		writefits.f90	
	)
add_library(camb
	"${CAMB_SOURCES}"
	)

set(CAMB_ROOT
	"/mn/stornext/u3/maksymb/cmake_projects/CAMB"
	)

# Including fortran .mod and .o files
target_include_directories(camb
  PUBLIC
	#"${CAMB_ROOT}/fortran/Release"
  "${CAMB_ROOT}/forutils/Release"
  )
# Linking libraries
target_link_libraries(camb
  PUBLIC
  OpenMP::OpenMP_Fortran
	MPI::MPI_Fortran
	#"${CAMB_ROOT}/fortran/Release/libcamb.a"
  "${CAMB_ROOT}/forutils/Release/libforutils.a"
  )
