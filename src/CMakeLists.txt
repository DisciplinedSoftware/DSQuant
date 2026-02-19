# Add subdirectories for libraries
add_subdirectory(lib)

if(PROJECT_IS_TOP_LEVEL AND BUILD_TESTING)
	add_subdirectory(tests)
endif()

if(PROJECT_IS_TOP_LEVEL AND BUILD_BENCHMARKS)
	add_subdirectory(benchmarks)
endif()

if(PROJECT_IS_TOP_LEVEL)
	add_subdirectory(examples)
endif()
