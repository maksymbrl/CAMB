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
	add_library("${FORUTILS_TARGET}"
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
		"${MATH_LIB}"
		)
	message("${FORUTILS_SOURCE_DIR}")
endif()
