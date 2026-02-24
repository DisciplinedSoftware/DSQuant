include(FetchContent)

if(NOT TARGET Boost::ut)
    if(POLICY CMP0175)
        cmake_policy(SET CMP0175 OLD)
    endif()

    FetchContent_Declare(
        boost_ut
        GIT_REPOSITORY https://github.com/boost-ext/ut.git
        GIT_TAG v2.1.0
        GIT_SHALLOW TRUE
    )
    FetchContent_MakeAvailable(boost_ut)
endif()

# Tests for core library
add_executable(tests_dsquant test_statistics.cpp main.cpp)
target_link_libraries(tests_dsquant PRIVATE dsquant Boost::ut)
target_compile_definitions(tests_dsquant PRIVATE BOOST_UT_DISABLE_MODULE)
target_include_directories(tests_dsquant PRIVATE
    "${CMAKE_SOURCE_DIR}/lib/include"
)

# Register test with CTest
add_test(NAME tests_dsquant COMMAND tests_dsquant)
