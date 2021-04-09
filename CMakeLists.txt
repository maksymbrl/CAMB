#================================================================================
# Authors: Maksym Brilenkov
#================================================================================
# Description: Top CMakeLists.txt for CAMB project
#================================================================================
# Ensure we do out-of-source build ((unless on MSVC_IDE, where it is ok))
# TODO: Make out-of-source build error
#================================================================================
# Standard CMake configuration
#================================================================================
set(CMAKE_MINIMUM "3.17")
set(CAMB_VERSION "3.70")
cmake_minimum_required(VERSION ${CMAKE_MINIMUM} FATAL_ERROR)
project(CAMB
	DESCRIPTION "Code for Anisotropies in the Microwave Background"
	VERSION ${CAMB_VERSION}
	LANGUAGES C CXX Fortran
	HOMEPAGE_URL "https://camb.info/"
	)
#================================================================================
# Include standard/native.
#================================================================================
# Define the default values for installation directories (all platforms even if named GNU)
# From documentation:
# https://cmake.org/cmake/help/latest/module/GNUInstallDirs.html
# the following <dir>s are set (appended to CMAKE_INSTALL_<dir>):
# BINDIR, SBINDIR, LIBDIR, INCLUDEDIR etc.
include(GNUInstallDirs)
# Automatically call enable_testing() and configure ctest targets when using Make/Ninja.
# In addition, it also sets global option BUILD_TESTING to control whether tests will be build or not
include(CTest)
# Scripts that creates options that depends on other options.
include(CMakeDependentOption)
# Tell CMake that the `install` target needs to install required system libraries (eg: Windows SDK)
#include(InstallRequiredSystemLibraries)
# Helper to create relocatable packages
include(CMakePackageConfigHelpers)
include(FindPkgConfig)
include(FindPackageHandleStandardArgs)
# Checks for existence of a header (we ask for a specific header)
# Note: There is adifference between the two:
# https://cmake.org/cmake/help/latest/module/CheckIncludeFile.html
# https://cmake.org/cmake/help/latest/module/CheckIncludeFiles.html
include(CheckIncludeFile)
include(CheckIncludeFiles)
# Checks for existence of certain library
# https://cmake.org/cmake/help/v3.17/module/CheckLibraryExists.html
include(CheckLibraryExists)
# Checks whether the code given in source will compile and link
#include(CheckCXXSourceCompiles)
#include(CheckCSourceCompiles)
# For printing properties and variables for a given target
# https://cmake.org/cmake/help/v3.17/module/CMakePrintHelpers.html
include(CMakePrintHelpers)
# Enables content population at configure time
include(FetchContent)
# Including external project routines to enable superbuild pattern
include(ExternalProject)
#================================================================================
# Including home-made cmake tools
#================================================================================
set(CMAKE_MODULE_PATH
	"${CMAKE_MODULE_PATH}"
	"${CMAKE_SOURCE_DIR}/cmake"
	"${CMAKE_SOURCE_DIR}/cmake/modules"
	)
# Include main custom file which controls all other subprojects
include(main)
#================================================================================
