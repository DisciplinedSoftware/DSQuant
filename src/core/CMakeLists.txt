# Core library CMakeLists.txt

# Non-module implementation (traditional headers)
add_library(dsquant_core INTERFACE)
target_include_directories(dsquant_core INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_compile_features(dsquant_core INTERFACE cxx_std_23)

# Module implementation (if enabled)
if(BUILD_WITH_MODULES)
    # Module-based library would go here
    # Note: C++23 modules support is still experimental in most compilers
    # This is a placeholder for future implementation
    message(STATUS "Module support requested but not yet fully implemented")
endif()

# Tests
if(BUILD_TESTS)
    add_subdirectory(test)
endif()

# Benchmarks
if(BUILD_BENCHMARKS)
    add_subdirectory(benchmark)
endif()
