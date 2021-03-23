#================================================================================
# Authors: Maksym Brilenkov
#================================================================================
# Description: This file contains general instructions on how to build CAMB and
# its (sub)projects (aka main method in C/C++ languages).
#================================================================================
# Setting various CMake Policies
#================================================================================
# Allow @rpath token in target install name on Macs.
# See "cmake --help-policy CMP0042" for more information.
if(POLICY CMP0042)
  CMAKE_POLICY(SET CMP0042 NEW)
endif()
#================================================================================
# Global Project Options
#================================================================================
# CMake native options
#--------------------------------------------------------------------------------
# Setting project configuration -- variable is empty by default
# - "Debug" builds library/executable w/o optimization and w/ debug symbols;
# - "Release" builds library/executable w/ optimization and w/o debug symbols;
# - "RelWithDebInfo" builds library/executable w/ less aggressive optimizations and w/ debug symbols;
# - "MinSizeRel" builds library/executable w/ optimizations that do not increase object code size.
if(NOT CMAKE_BUILD_TYPE)
	message(STATUS "No build type selected (CMAKE_BUILD_TYPE is empty); thus, using default value: Release.")
	set(CMAKE_BUILD_TYPE Release
		CACHE STRING
		"Specifies the Build type. Available options are: Release, Debug, RelWithDebInfo, MinSizeRel. Default: Release." FORCE)
endif()
# Directories where to install the project
# Where to install shared libraries
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_PREFIX}/lib" #${CMAKE_INSTALL_LIBDIR}"
	CACHE STRING
	"Directory where to install shared libraries."
	)
# Where to install static libraries
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_PREFIX}/lib"#${CMAKE_INSTALL_LIBDIR}"
	CACHE STRING
	"Directory where to install static libraries."
	)
# Where to output executable(s)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR}"
	CACHE STRING
	"Directory where to install all the executables."
	)
# setting the directory where to output all .mod and .o files
set(CMAKE_Fortran_MODULE_DIRECTORY "${CMAKE_INSTALL_PREFIX}/mod"
	CACHE STRING
	"Directory where to install all .mod/.o files."
	)
# Setting the default value where to download the external project sources (curl, cfitsio).
set(CMAKE_DOWNLOAD_DIRECTORY "${CMAKE_SOURCE_DIR}/build/downloads"
	CACHE STRING
	"Directory where to download HEALPix dependencies' source files."
	)
# Including -fPIC flag globally (it can also be set locally for each target)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
# This is usually a native CMake variable, but it is useful to specify it here.
option(BUILD_SHARED_LIBS "Specify whether to build HEALPix as shared or static library. Default: OFF" OFF)

#option(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
#--------------------------------------------------------------------------------
# Custom options
#--------------------------------------------------------------------------------
# This is a quick and dirty fix for "C preprocessor fails sanity check"
# which may appear during CFitsIO configuration via configure.
set(CAMB_CPP_COMPILER "${CMAKE_CXX_COMPILER} -E")
# Build CAMB (and Forutils) with MPI support
option(CAMB_USE_MPI "Building HEALPix with MPI support. Default: ON." ON)
#================================================================================
# Looking for necessary packages
#================================================================================
# Looking for Git
find_package(Git)
if(GIT_FOUND AND EXISTS "${PROJECT_SOURCE_DIR}/.git")
	# Update submodules as needed
	option(GIT_SUBMODULE "Check submodules during build" ON)
endif()
# Trying to find OpenMP
find_package(OpenMP COMPONENTS Fortran REQUIRED)
# Trying to find MPI
if(CAMB_USE_MPI)
	find_package(MPI COMPONENTS Fortran REQUIRED)
endif()
# BLAS/LAPACK
# This works for OpenBLAS
# Note: Sometimes this doesn't work, i.e. it cannot detect MKL/OpenBLAS
# for some weird reason. In this case it is a good idea to logout and login
# to refresh terminal.
set($ENV{BLA_VENDOR} 
		OpenBLAS
		Intel10_32
		Intel10_64lp
		Intel10_64lp_seq
		Intel10_64ilp
		Intel10_64ilp_seq
		Intel10_64_dyn
		)
find_package(BLAS) #REQUIRED)
find_package(LAPACK)
# CFitsIO
find_package(CFITSIO 3.47 REQUIRED)
# Looking for Unix/Linux Math Library
find_library(MATH_LIB m)

#================================================================================
include(forutils)
include(camb)
