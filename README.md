# DSQuant
Library for quantitative finance

## Overview
DSQuant is a modern C++23 library for quantitative finance, built with test-driven development (TDD) principles and performance in mind.

## Features
- **Modern C++23**: Leveraging the latest C++ features including concepts
- **Module Support**: Prepared for C++23 modules (currently using traditional headers)
- **Cross-compiler**: Supports GCC, Clang, and MSVC
- **Cross-platform**: Linux (primary target) and Windows support
- **Testing**: Integrated testing with boost.ut
- **Benchmarking**: Performance benchmarking with nanobench
- **Clean Architecture**: Separate output directories for libraries and binaries

## Project Structure
```
DSQuant/
├── src/
│   ├── core/              # Core library
│   │   ├── include/       # Public headers
│   │   ├── tests/         # Unit tests
│   │   └── benchmarks/    # Performance benchmarks
│   └── examples/          # Example applications
├── build/                 # Build directory (generated)
│   ├── bin/              # Compiled executables
│   └── lib/              # Compiled libraries
└── CMakeLists.txt        # Root CMake configuration
```

## Prerequisites
- CMake 3.28 or higher
- C++23 capable compiler:
  - GCC 14+ (recommended for module support)
  - Clang 16+
  - MSVC 2022 (VS 17.0+)

## Building

### Linux (Default)
```bash
# Configure
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build -j$(nproc)

# Run tests
cd build && ctest --output-on-failure
```

### With Module Support (Experimental)
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_WITH_MODULES=ON
cmake --build build -j$(nproc)
```

### Build Options
- `BUILD_TESTS=ON/OFF` - Build unit tests (default: ON)
- `BUILD_BENCHMARKS=ON/OFF` - Build benchmarks (default: ON)
- `BUILD_WITH_MODULES=ON/OFF` - Use C++23 modules (default: OFF, experimental)

### Different Compilers
```bash
# GCC
cmake -B build -DCMAKE_CXX_COMPILER=g++-14

# Clang
cmake -B build -DCMAKE_CXX_COMPILER=clang++-16

# MSVC (Windows)
cmake -B build -G "Visual Studio 17 2022"
```

## Running Examples
After building, executables are in the `build/bin` directory:
```bash
# Run basic example
./build/bin/basic_example

# Run benchmarks
./build/bin/benchmark_statistics
```

## Running Tests
```bash
# Using CTest
cd build && ctest --output-on-failure

# Or run test executables directly
./build/bin/test_statistics
```

## Dependencies
Dependencies are automatically fetched during configuration:
- [boost.ut](https://github.com/boost-ext/ut) v2.1.0 - Modern C++ testing framework
- [nanobench](https://github.com/martinus/nanobench) v4.3.11 - Microbenchmarking library

## Development
This project follows TDD principles:
1. Write tests first in the appropriate `tests/` directory
2. Implement functionality in `include/` directory
3. Add benchmarks in `benchmarks/` directory if needed
4. Verify with `ctest` and performance with benchmark executables

## Contributing
Each library component should have:
- Public headers in `include/dsquant/<component>/`
- Unit tests in `tests/`
- Benchmarks in `benchmarks/`
- CMakeLists.txt for build configuration

## License
See LICENSE file for details.
