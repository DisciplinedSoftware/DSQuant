include(FetchContent)

if(NOT TARGET dsquant_nanobench)
	FetchContent_Declare(
		nanobench
		GIT_REPOSITORY https://github.com/martinus/nanobench.git
		GIT_TAG v4.3.11
		SOURCE_SUBDIR __do_not_add_subdirectory__
    	GIT_SHALLOW TRUE
	)
	FetchContent_MakeAvailable(nanobench)

	add_library(dsquant_nanobench INTERFACE)
	target_include_directories(dsquant_nanobench INTERFACE
		${nanobench_SOURCE_DIR}/src/include
	)
endif()

# Benchmarks for core library
add_executable(benchmark_statistics benchmark_statistics.cpp)
target_link_libraries(benchmark_statistics PRIVATE dsquant dsquant_nanobench)
target_compile_definitions(benchmark_statistics PRIVATE ANKERL_NANOBENCH_IMPLEMENT)
target_include_directories(benchmark_statistics PRIVATE
	"${CMAKE_SOURCE_DIR}/lib/include"
)

# Benchmarks are not automatically run, but can be executed manually
