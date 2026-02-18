# Development Guide

## Project Structure

```
DSQuant/
├── src/                      # Source code
│   ├── lib/                  # Library
│   │   └── include/
│   │       └── dsquant/
│   ├── tests/                # Unit tests
│   ├── benchmarks/           # Performance benchmarks
│   └── examples/             # Example applications
├── docs/                     # Documentation
├── build/                    # Build output (generated)
│   ├── bin/                  # Executables
│   └── lib/                  # Libraries
├── CMakeLists.txt            # Root CMake config
└── build.sh                  # Build script
```

## Test-Driven Development (TDD)

DSQuant follows strict TDD principles:

### 1. Write Tests First

Create a test file in the appropriate `tests/` directory:

**src/tests/test_new_feature.cpp:**
```cpp
#include <boost/ut.hpp>
#include <dsquant/new_feature.hpp>

int main() {
    using namespace boost::ut;
    
    "new feature calculation"_test = [] {
        // Arrange
        const auto input = 42.0;
        
        // Act
        const auto result = dsquant::new_feature(input);
        
        // Assert
        expect(that % result == 84.0);
    };
    
    return 0;
}
```

### 2. Run Tests (They Should Fail)

```bash
cmake --build build
cd build && ctest --output-on-failure
```

### 3. Implement Functionality

Create the implementation in `include/`:

**src/lib/include/dsquant/new_feature.hpp:**
```cpp
#pragma once

namespace dsquant {

constexpr double new_feature(double input) noexcept {
    return input * 2.0;
}

} // namespace dsquant
```

### 4. Run Tests (They Should Pass)

```bash
cmake --build build
cd build && ctest --output-on-failure
```

### 5. Refactor

Improve the code while keeping tests green.

## Adding a New Library Component

### Step 1: Create Directory Structure

```bash
mkdir -p src/newcomponent/{include/dsquant/newcomponent,tests,benchmarks}
```

### Step 2: Create CMakeLists.txt

**src/newcomponent/CMakeLists.txt:**
```cmake
# New component library
add_library(dsquant_newcomponent INTERFACE)
target_include_directories(dsquant_newcomponent INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_compile_features(dsquant_newcomponent INTERFACE cxx_std_23)

# Tests
if(BUILD_TESTS)
    add_subdirectory(tests)
endif()

# Benchmarks
if(BUILD_BENCHMARKS)
    add_subdirectory(benchmarks)
endif()
```

### Step 3: Add to Root CMake

Update **src/CMakeLists.txt:**
```cmake
add_subdirectory(lib)
add_subdirectory(newcomponent)  # Add this line
add_subdirectory(examples)
```

### Step 4: Implement Headers

**src/newcomponent/include/dsquant/newcomponent/feature.hpp:**
```cpp
#pragma once

namespace dsquant::newcomponent {

// Your interface here

} // namespace dsquant::newcomponent
```

### Step 5: Write Tests

**src/newcomponent/tests/CMakeLists.txt:**
```cmake
add_executable(test_newcomponent test_feature.cpp)
target_link_libraries(test_newcomponent PRIVATE 
    dsquant_newcomponent 
    Boost::ut
)
add_test(NAME test_newcomponent COMMAND test_newcomponent)
```

**src/newcomponent/tests/test_feature.cpp:**
```cpp
#include <boost/ut.hpp>
#include <dsquant/newcomponent/feature.hpp>

int main() {
    using namespace boost::ut;
    // Your tests here
    return 0;
}
```

### Step 6: Add Benchmarks (Optional)

**src/newcomponent/benchmarks/CMakeLists.txt:**
```cmake
add_executable(benchmark_newcomponent benchmark_feature.cpp)
target_link_libraries(benchmark_newcomponent PRIVATE 
    dsquant_newcomponent 
    nanobench
)
```

## Writing Tests with boost.ut

### Basic Test Structure

```cpp
#include <boost/ut.hpp>

int main() {
    using namespace boost::ut;
    
    "test name"_test = [] {
        expect(true);
    };
    
    return 0;
}
```

### Assertions

```cpp
// Equality
expect(that % value == 42);

// Comparison
expect(that % value > 0);
expect(that % value < 100);

// Floating point comparison
expect(that % std::abs(value - expected) < 0.0001);

// Boolean
expect(condition);
expect(!condition);

// Custom messages
expect(value == 42) << "Value should be 42";
```

### Parameterized Tests

```cpp
"parameterized test"_test = [] {
    for (auto [input, expected] : {
        std::pair{1.0, 2.0},
        std::pair{2.0, 4.0},
        std::pair{3.0, 6.0}
    }) {
        const auto result = double_value(input);
        expect(that % result == expected);
    }
};
```

### Test Fixtures

```cpp
struct TestFixture {
    TestFixture() {
        // Setup
    }
    ~TestFixture() {
        // Teardown
    }
    int data = 42;
};

"test with fixture"_test = [] {
    TestFixture fixture;
    expect(that % fixture.data == 42);
};
```

## Writing Benchmarks with nanobench

### Basic Benchmark

```cpp
#include <nanobench.h>
#include <dsquant/feature.hpp>

int main() {
    ankerl::nanobench::Bench().run("feature name", [&] {
        ankerl::nanobench::doNotOptimizeAway(
            dsquant::feature(input)
        );
    });
    
    return 0;
}
```

### Benchmark with Setup

```cpp
#include <nanobench.h>
#include <vector>
#include <random>

int main() {
    // Setup data
    std::vector<double> data(1000);
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<> dis(0.0, 1.0);
    for (auto& v : data) v = dis(gen);
    
    // Benchmark
    ankerl::nanobench::Bench()
        .minEpochIterations(100)
        .run("algorithm", [&] {
            ankerl::nanobench::doNotOptimizeAway(
                process(data)
            );
        });
    
    return 0;
}
```

### Multiple Benchmarks

```cpp
ankerl::nanobench::Bench bench;

bench.run("small input", [&] {
    ankerl::nanobench::doNotOptimizeAway(func(small_data));
});

bench.run("medium input", [&] {
    ankerl::nanobench::doNotOptimizeAway(func(medium_data));
});

bench.run("large input", [&] {
    ankerl::nanobench::doNotOptimizeAway(func(large_data));
});
```

## Coding Standards

### C++23 Features

Use modern C++ features:
```cpp
// Concepts
template<std::floating_point T>
T function(T value);

// Constexpr
constexpr double compute(double x) noexcept {
    return x * x;
}

// Auto and structured bindings
auto [min, max] = std::minmax({1, 2, 3, 4, 5});
```

### Naming Conventions

- **Namespaces**: `dsquant::component`
- **Functions**: `snake_case`
- **Classes**: `PascalCase`
- **Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE` or `kCamelCase`
- **Template Parameters**: `PascalCase`

### Documentation

Use Doxygen-style comments:
```cpp
/// @brief Calculate the mean of a range
/// @tparam T Value type (must be floating point)
/// @param begin Start iterator
/// @param end End iterator
/// @return The arithmetic mean
template<std::floating_point T>
constexpr T mean(const T* begin, const T* end) noexcept;
```

## Continuous Integration

### Local CI Simulation

```bash
# Clean build
rm -rf build

# Configure
cmake -B build -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build --parallel

# Test
cd build && ctest --output-on-failure --parallel
```

## Common Tasks

### Adding a Dependency

Update root **CMakeLists.txt**:
```cmake
FetchContent_Declare(
    newdep
    GIT_REPOSITORY https://github.com/user/newdep.git
    GIT_TAG v1.0.0
)
FetchContent_MakeAvailable(newdep)
```

### Creating an Example

**src/examples/new_example.cpp:**
```cpp
#include <dsquant/feature.hpp>
#include <iostream>

int main() {
    std::cout << "Result: " << dsquant::feature(42) << "\n";
    return 0;
}
```

Update **src/examples/CMakeLists.txt:**
```cmake
add_executable(new_example new_example.cpp)
target_link_libraries(new_example PRIVATE dsquant_core)
```

## Troubleshooting

### Test Fails to Compile

1. Check include paths in CMakeLists.txt
2. Verify header guards
3. Ensure proper linking

### Benchmark Shows Unexpected Results

1. Check compiler optimizations (`-O3` in Release)
2. Use `doNotOptimizeAway()` properly
3. Run multiple times for consistency
4. Check for system load

### Build is Slow

1. Use parallel builds: `-j$(nproc)`
2. Enable ccache: `export CMAKE_CXX_COMPILER_LAUNCHER=ccache`
3. Use precompiled headers for large dependencies

## Resources

- [boost.ut Documentation](https://github.com/boost-ext/ut)
- [nanobench Documentation](https://nanobench.ankerl.com/)
- [CMake Documentation](https://cmake.org/documentation/)
- [C++23 Features](https://en.cppreference.com/w/cpp/23)
