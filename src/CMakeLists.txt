# Add subdirectories for libraries
add_subdirectory(lib)

if(BUILD_TESTS)
	add_subdirectory(test)
endif()

if(BUILD_BENCHMARKS)
	add_subdirectory(benchmark)
endif()

add_subdirectory(examples)
