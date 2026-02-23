# Code Coverage Configuration
# This module sets up code coverage analysis with ctest

if(ENABLE_COVERAGE)
    # Find required coverage tools
    find_program(GCOV_EXECUTABLE gcov)
    find_program(LCOV_EXECUTABLE lcov)
    find_program(GENHTML_EXECUTABLE genhtml)
    
    if(NOT GCOV_EXECUTABLE)
        message(WARNING "gcov not found - coverage reports will not be generated")
    endif()
    
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        # Use both --coverage and explicit -fprofile-arcs -ftest-coverage flags
        set(COVERAGE_COMPILER_FLAGS "--coverage -fprofile-arcs -ftest-coverage")
        string(REPLACE " " ";" COVERAGE_FLAGS_LIST "${COVERAGE_COMPILER_FLAGS}")
        add_compile_options(${COVERAGE_FLAGS_LIST})
        add_link_options(${COVERAGE_FLAGS_LIST})
        message(STATUS "Code coverage enabled with flags: ${COVERAGE_COMPILER_FLAGS}")
    else()
        message(WARNING "Code coverage is not supported by ${CMAKE_CXX_COMPILER_ID}")
        return()
    endif()
    
    # Setup CTest for coverage analysis
    if(GCOV_EXECUTABLE)
        # Configure ctest to run coverage
        configure_file(
            ${CMAKE_CURRENT_LIST_DIR}/CTestConfig.cmake.in
            ${CMAKE_BINARY_DIR}/CTestConfig.cmake
            @ONLY
        )
        
        # Configure CTestCustom.cmake
        configure_file(
            ${CMAKE_CURRENT_LIST_DIR}/CTestCustom.cmake.in
            ${CMAKE_BINARY_DIR}/CTestCustom.cmake
            @ONLY
        )
        
        # Configure the post-test coverage collection script
        configure_file(
            ${CMAKE_CURRENT_LIST_DIR}/coverage_post_test.sh.in
            ${CMAKE_BINARY_DIR}/coverage_post_test.sh
            @ONLY
        )
    endif()
    
    # Add a custom target to generate coverage report (only at top level)
    if(PROJECT_IS_TOP_LEVEL AND LCOV_EXECUTABLE AND GENHTML_EXECUTABLE)
        if(NOT TARGET coverage)
            add_custom_target(coverage
                COMMAND ${CMAKE_COMMAND} --build . --target all
                COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
                COMMAND ${LCOV_EXECUTABLE} --capture --directory . --output-file coverage.info
                COMMAND ${LCOV_EXECUTABLE} --remove coverage.info '*/_deps/*' '*/tests/*' '/usr/*' --output-file coverage.info
                COMMAND ${GENHTML_EXECUTABLE} coverage.info --output-directory html
                WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
                COMMENT "Building all targets, running tests and generating coverage report"
            )
        endif()
    endif()
    
    # Standard coverage addon for CTest/Dart integration
    # Coverage is now generated through the CTestCustom.cmake post-test phase
endif()
