#================================================================================
# Authors: Maksym Brilenkov
#================================================================================
set(CAMB_TARGET camb)
set(CAMB_SOURCE_DIR "${PROJECT_SOURCE_DIR}/fortran")
set(CAMB_SOURCES
		"${CAMB_SOURCE_DIR}/camb.f90"
		"${CAMB_SOURCE_DIR}/bessels.f90"
		"${CAMB_SOURCE_DIR}/camb_python.f90"
		"${CAMB_SOURCE_DIR}/classes.f90"
		"${CAMB_SOURCE_DIR}/cmbmain.f90"
		"${CAMB_SOURCE_DIR}/config.f90"
		"${CAMB_SOURCE_DIR}/constants.f90"
		"${CAMB_SOURCE_DIR}/cosmorec.f90"
		"${CAMB_SOURCE_DIR}/DarkAge21cm.f90"
		"${CAMB_SOURCE_DIR}/DarkEnergyFluid.f90"
		"${CAMB_SOURCE_DIR}/DarkEnergyInterface.f90"
		"${CAMB_SOURCE_DIR}/DarkEnergyPPF.f90"
		"${CAMB_SOURCE_DIR}/DarkEnergyQuintessence.f90"
		"${CAMB_SOURCE_DIR}/equations.f90"
		"${CAMB_SOURCE_DIR}/halofit.f90"
		"${CAMB_SOURCE_DIR}/hyrec.f90"
		"${CAMB_SOURCE_DIR}/inidriver.f90"
		"${CAMB_SOURCE_DIR}/InitialPower.f90"
		"${CAMB_SOURCE_DIR}/lensing.f90"
		"${CAMB_SOURCE_DIR}/massive_neutrinos.f90"
		"${CAMB_SOURCE_DIR}/MathUtils.f90"
		"${CAMB_SOURCE_DIR}/model.f90"
		"${CAMB_SOURCE_DIR}/PowellMinimize.f90"
		"${CAMB_SOURCE_DIR}/recfast.f90"
		"${CAMB_SOURCE_DIR}/reionization.f90"
		"${CAMB_SOURCE_DIR}/results.f90"
		"${CAMB_SOURCE_DIR}/SecondOrderPK.f90"
		"${CAMB_SOURCE_DIR}/SeparableBispectrum.f90"
		"${CAMB_SOURCE_DIR}/sigma8.f90"
		"${CAMB_SOURCE_DIR}/SourceWindows.f90"
		"${CAMB_SOURCE_DIR}/subroutines.f90"
		"${CAMB_SOURCE_DIR}/writefits.f90"	
	)
# adding libcamb.a
add_library(${CAMB_TARGET}
	"${CAMB_SOURCES}"
	)
# making forutils compile before camb
add_dependencies(${CAMB_TARGET}
	${FORUTILS_TARGET}
	)


# Including fortran .mod and .o files
target_include_directories(${CAMB_TARGET}
  PUBLIC
	# HEALPix
	"${HEALPIX_INCLUDE_DIRS}"
	# CFitsIO
	"${CFITSIO_INCLUDE_DIRS}"
	# Other compiled Fortran modules such as Forutils
	"${CMAKE_Fortran_MODULE_DIRECTORY}"
	#"${CAMB_ROOT}/forutils/Release"
  )
# Linking libraries
target_link_libraries(${CAMB_TARGET}
  PUBLIC
	MPI::MPI_Fortran
  OpenMP::OpenMP_Fortran
	${BLAS_LINKER_FLAGS}
	${BLAS_LIBRARIES}
	${LAPACK_LINKER_FLAGS}
	${LAPACK_LIBRARIES}
	# HEALPix
	${HEALPIX_LIBRARIES}
	# including cfitsio
	${CFITSIO_LIBRARIES}
	#"${CAMB_ROOT}/forutils/Release/libforutils.a"
	"${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${CMAKE_STATIC_LIBRARY_PREFIX}${FORUTILS_TARGET}${CMAKE_STATIC_LIBRARY_SUFFIX}"
  )
# Specifying compiler flags
if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
	target_compile_options(${CAMB_TARGET}
		PUBLIC
		"-fpp"
		"-W0"
		"-WB"
		"-fp-model" "precise"
		#"-fpic"
		#"-gen-dep=.d"
		"-fast"
		)
endif()
#if(CAMB_USE_MPI)
#	# Note: -D will be added automatically by CMake
#	target_compile_definitions(${CAMB_TARGET}
#		PUBLIC
#		MPI
#		)
#endif()
