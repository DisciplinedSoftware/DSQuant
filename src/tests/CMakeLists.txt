include(FetchContent)

if(NOT TARGET Boost::ut)
	FetchContent_Declare(
		boost_ut
		GIT_REPOSITORY https://github.com/boost-ext/ut.git
		GIT_TAG v2.1.0
    	GIT_SHALLOW TRUE
	)
	FetchContent_MakeAvailable(boost_ut)
endif()

# Tests for core library
add_executable(test_statistics test_statistics.cpp main.cpp)
target_link_libraries(test_statistics PRIVATE dsquant Boost::ut)
target_compile_definitions(test_statistics PRIVATE BOOST_UT_DISABLE_MODULE)

# Register test with CTest
add_test(NAME test_statistics COMMAND test_statistics)
