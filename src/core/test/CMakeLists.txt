# Tests for core library
add_executable(test_statistics test_statistics.cpp)
target_link_libraries(test_statistics PRIVATE dsquant_core Boost::ut)

# Register test with CTest
add_test(NAME test_statistics COMMAND test_statistics)
