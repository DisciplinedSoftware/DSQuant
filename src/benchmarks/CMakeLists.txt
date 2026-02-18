# Benchmarks for core library
add_executable(benchmark_statistics benchmark_statistics.cpp)
target_link_libraries(benchmark_statistics PRIVATE dsquant dsquant_nanobench)
target_compile_definitions(benchmark_statistics PRIVATE ANKERL_NANOBENCH_IMPLEMENT)

# Benchmarks are not automatically run, but can be executed manually
