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
