cmake_minimum_required(VERSION 3.10)
project(DSQuant VERSION 1.0.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/out)

# Add subdirectory for the library
add_subdirectory(lib/dsquant)
cmake_minimum_required(VERSION 3.28)

# Project definition
project(DSQuant
    VERSION 0.1.0
    DESCRIPTION "Library for quantitative finance"
    LANGUAGES CXX
)

# C++23 standard
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Output directories - separate from source
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# For multi-config generators (MSVC, Xcode)
foreach(CONFIG ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${CONFIG} CONFIG_UPPER)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG_UPPER} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG_UPPER} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_UPPER} ${CMAKE_BINARY_DIR}/lib)
endforeach()

# Compiler-specific flags
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    add_compile_options(-Wall -Wextra -pedantic)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    add_compile_options(-Wall -Wextra -pedantic)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    add_compile_options(/W4 /permissive-)
endif()

# Options
option(BUILD_TESTS "Build tests" ON)
option(BUILD_BENCHMARKS "Build benchmarks" ON)
option(BUILD_WITH_MODULES "Build with C++23 modules" OFF)

# Apply module-specific compiler flags when enabled
if(BUILD_WITH_MODULES)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        # Enable C++23 modules support for GCC
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 14.0)
            add_compile_options(-fmodules-ts)
        else()
            message(WARNING "GCC 14+ required for module support, but found ${CMAKE_CXX_COMPILER_VERSION}")
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # Enable C++23 modules support for Clang
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0)
            add_compile_options(-fmodules)
        else()
            message(WARNING "Clang 16+ required for module support, but found ${CMAKE_CXX_COMPILER_VERSION}")
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        # MSVC has built-in module support in VS2019 16.10+
        add_compile_options(/std:c++latest)
    endif()
endif()

# Include CMake modules directory
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Dependencies
include(FetchContent)

# boost.ut - header-only testing framework
FetchContent_Declare(
    ut
    GIT_REPOSITORY https://github.com/boost-ext/ut.git
    GIT_TAG v2.1.0
)

# nanobench - header-only benchmarking framework
FetchContent_Declare(
    nanobench
    GIT_REPOSITORY https://github.com/martinus/nanobench.git
    GIT_TAG v4.3.11
)

# Make dependencies available
if(BUILD_TESTS)
    FetchContent_MakeAvailable(ut)
endif()

if(BUILD_BENCHMARKS)
    FetchContent_MakeAvailable(nanobench)
endif()

# Enable testing
if(BUILD_TESTS)
    enable_testing()
endif()

# Add subdirectories
add_subdirectory(src)

# Display configuration summary
message(STATUS "")
message(STATUS "===== DSQuant Configuration =====")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "C++ standard: C++${CMAKE_CXX_STANDARD}")
message(STATUS "Build tests: ${BUILD_TESTS}")
message(STATUS "Build benchmarks: ${BUILD_BENCHMARKS}")
message(STATUS "Build with modules: ${BUILD_WITH_MODULES}")
message(STATUS "Output directory: ${CMAKE_BINARY_DIR}")
message(STATUS "================================")
message(STATUS "")
