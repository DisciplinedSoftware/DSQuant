# Benchmarks for core library
add_executable(benchmark_statistics benchmark_statistics.cpp)
target_link_libraries(benchmark_statistics PRIVATE dsquant nanobench)

# Benchmarks are not automatically run, but can be executed manually
