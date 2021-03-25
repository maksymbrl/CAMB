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
# This should be added to FindHEALPIX.cmake somehow.
#set(HEALPIX_LIBRARIES
#		"/mn/stornext/u3/maksymb/commander/maksymb/build/install/healpix/lib/libhealpix.a"
#		"/mn/stornext/u3/maksymb/commander/maksymb/build/install/healpix/lib/libsharp.a"
#	)
#set(HEALPIX_INCLUDE_DIRS
#	"/mn/stornext/u3/maksymb/commander/maksymb/build/install/healpix/include"
#	"/mn/stornext/u3/maksymb/commander/maksymb/build/install/healpix/include/libsharp"
#	)
#/mn/stornext/u3/maksymb/commander/maksymb/build/install/healpix/lib
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
	#
	${MATH_LIB}
	${CMAKE_DL_LIBS}
  )
# Specifying compiler flags
# TODO: make this work with GNU
if(CMAKE_Fortran_COMPILER_ID MATCHES Intel)
	target_compile_options(${CAMB_TARGET}
		PUBLIC
		"-fpp"
		"-W0"
		"-WB"
		"-fp-model" "precise"
		#"-fpic"
		"-gen-dep=.d"
		"-fast"
		)
endif()
# For some reason it doesn't work with 
#target_compile_definitions(${CAMB_TARGET}
#	PUBLIC
#	WRITE_FITS
#	)
#if(CAMB_USE_MPI)
#	# Note: -D will be added automatically by CMake
#	target_compile_definitions(${CAMB_TARGET}
#		PUBLIC
#		MPI	
#		)
#endif()
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

#[==[
[maksymb@owl18 fortran]$ make VERBOSE=1
make -C Release --no-print-directory -f../Makefile FORUTILS_SRC_DIR=.. libforutils.a
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=constants.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../constants.f90 -o constants.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=config.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../config.f90 -o config.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=classes.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../classes.f90 -o classes.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=MathUtils.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../MathUtils.f90 -o MathUtils.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=subroutines.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../subroutines.f90 -o subroutines.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=DarkAge21cm.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkAge21cm.f90 -o DarkAge21cm.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=DarkEnergyInterface.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyInterface.f90 -o DarkEnergyInterface.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=SourceWindows.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../SourceWindows.f90 -o SourceWindows.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=massive_neutrinos.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../massive_neutrinos.f90 -o massive_neutrinos.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=model.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../model.f90 -o model.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=results.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../results.f90 -o results.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=bessels.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../bessels.f90 -o bessels.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=recfast.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../recfast.f90 -o recfast.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=DarkEnergyFluid.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyFluid.f90 -o DarkEnergyFluid.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=DarkEnergyPPF.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyPPF.f90 -o DarkEnergyPPF.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=PowellMinimize.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../PowellMinimize.f90 -o PowellMinimize.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=DarkEnergyQuintessence.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../DarkEnergyQuintessence.f90 -o DarkEnergyQuintessence.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=equations.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../equations.f90 -o equations.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=reionization.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../reionization.f90 -o reionization.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=InitialPower.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../InitialPower.f90 -o InitialPower.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=halofit.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../halofit.f90 -o halofit.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=SecondOrderPK.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../SecondOrderPK.f90 -o SecondOrderPK.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=lensing.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../lensing.f90 -o lensing.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=SeparableBispectrum.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../SeparableBispectrum.f90 -o SeparableBispectrum.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=cmbmain.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../cmbmain.f90 -o cmbmain.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=camb.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../camb.f90 -o camb.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=camb_python.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../camb_python.f90 -o camb_python.o
xiar -r libcamb.a constants.o config.o classes.o MathUtils.o subroutines.o DarkAge21cm.o DarkEnergyInterface.o SourceWindows.o massive_neutrinos.o model.o results.o bessels.o recfast.o DarkEnergyFluid.o DarkEnergyPPF.o PowellMinimize.o DarkEnergyQuintessence.o equations.o reionization.o InitialPower.o halofit.o SecondOrderPK.o lensing.o SeparableBispectrum.o cmbmain.o camb.o camb_python.o
xiar: executing 'ar'
ar: creating libcamb.a
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=inidriver.d -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -c ../inidriver.f90 -o inidriver.o
ifort -fp-model precise -W0 -WB -fpp -qopenmp -gen-dep=.d -module Release -IRelease/ -I"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" \
	Release/inidriver.o Release/libcamb.a -cxxlib -qopt-report=0 -qopt-report-phase=vec -L"/mn/stornext/u3/maksymb/commander/camb/fortran/../forutils/Release/" -lforutils -o camb
#]==]
