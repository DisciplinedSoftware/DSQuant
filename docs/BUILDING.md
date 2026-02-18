# Building DSQuant

## Quick Start

### Using the Build Script (Recommended)
```bash
# Release build with tests
./build.sh

# Debug build
./build.sh --debug

# Clean build
./build.sh --clean

# Without tests
./build.sh --no-tests

# With experimental module support
./build.sh --with-modules
```

### Manual CMake Build

#### Basic Build
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j$(nproc)
```

#### Run Tests
```bash
cd build && ctest --output-on-failure
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_TESTS` | ON | Build unit tests |
| `BUILD_BENCHMARKS` | ON | Build performance benchmarks |
| `BUILD_WITH_MODULES` | OFF | Enable C++23 modules (experimental) |
| `CMAKE_BUILD_TYPE` | - | Build type (Debug, Release, RelWithDebInfo, MinSizeRel) |

### Examples

#### Debug Build with Tests Only
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Debug -DBUILD_BENCHMARKS=OFF
cmake --build build
```

#### Release Build without Tests
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF
cmake --build build
```

## Compiler-Specific Instructions

### GCC
```bash
# Specify GCC version
cmake -B build -DCMAKE_CXX_COMPILER=g++-14
cmake --build build
```

**Recommended:** GCC 14+ for better C++23 support

### Clang
```bash
# Specify Clang version
cmake -B build -DCMAKE_CXX_COMPILER=clang++-16
cmake --build build
```

**Note:** Clang 16+ recommended for C++23 features

### MSVC (Windows)

#### Visual Studio 2022
```bash
cmake -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

#### Command Line
```bash
# From Developer Command Prompt for VS 2022
cmake -B build -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Cross-Platform Considerations

### Linux (Primary Target)
- Full support for all features
- Use GCC 13+ or Clang 16+
- CMake 3.28+

### Windows
- Visual Studio 2022 (17.0+) or later
- CMake 3.28+
- Use Developer Command Prompt or PowerShell

**Note:** Module support is more stable on MSVC

### macOS
- Xcode 15+ with Clang 16+
- CMake 3.28+
- Install via Homebrew: `brew install cmake`

## Output Directories

After building, the project structure looks like:
```
build/
├── bin/                    # All executables
│   ├── basic_example       # Example applications
│   ├── test_statistics     # Test executables
│   └── benchmark_*         # Benchmark executables
└── lib/                    # All libraries
    └── libnanobench.a      # Static libraries
```

## Troubleshooting

### CMake Version Too Old
```bash
# Install newer CMake
pip install cmake --upgrade
# or
snap install cmake --classic
```

### Compiler Doesn't Support C++23
- Update to GCC 13+, Clang 16+, or MSVC 2022+
- On Ubuntu: `sudo apt install g++-14`
- Check support: `g++ --version`

### Module Build Fails
Module support is experimental. If `BUILD_WITH_MODULES=ON` fails:
1. Ensure compiler version is recent (GCC 14+, Clang 16+, MSVC 17.0+)
2. Fall back to traditional headers: `BUILD_WITH_MODULES=OFF`
3. Check compiler documentation for module support

### Dependency Fetch Fails
Dependencies are fetched from GitHub:
- Check internet connection
- Check firewall settings
- Manually clone dependencies to `build/_deps/` if needed

## Performance Tuning

### Release Build with Optimizations
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

### Link-Time Optimization (LTO)
```bash
cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
cmake --build build
```

### Native CPU Optimizations
Add to `CMakeLists.txt`:
```cmake
add_compile_options(-march=native)
```

## Development Build

For active development, use Debug build with tests:
```bash
./build.sh --debug
```

This enables:
- Debug symbols
- Assertion checks
- Better error messages
- Debugger support

## Continuous Integration

Example CI configuration:
```bash
# Configure
cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=ON

# Build
cmake --build build --parallel

# Test
cd build && ctest --output-on-failure --parallel
```
