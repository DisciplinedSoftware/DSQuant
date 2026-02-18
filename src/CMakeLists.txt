# Add subdirectories for libraries
add_subdirectory(lib)

if(BUILD_TESTS)
	add_subdirectory(tests)
endif()

if(BUILD_BENCHMARKS)
	add_subdirectory(benchmarks)
endif()

add_subdirectory(examples)
