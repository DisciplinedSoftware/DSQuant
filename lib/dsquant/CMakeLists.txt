# DSQuant library
add_library(dsquant SHARED
    fibonacci.cpp
)

target_include_directories(dsquant PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

# Test executable
add_executable(fibonacci_test
    test/fibonacci_test.cpp
)

target_link_libraries(fibonacci_test PRIVATE dsquant)

# Benchmark executable
add_executable(fibonacci_benchmark
    benchmark/fibonacci_benchmark.cpp
)

target_link_libraries(fibonacci_benchmark PRIVATE dsquant)
