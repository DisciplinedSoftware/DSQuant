# DSQuant Quick Reference

## Quick Start

```bash
# Clone and build
git clone <repository-url>
cd DSQuant
./build.sh

# Run example
./build/bin/basic_example

# Run tests
./build/bin/test_statistics

# Run benchmarks
./build/bin/benchmark_statistics
```

## Common Commands

### Building

```bash
# Default build (Release with tests)
./build.sh

# Debug build
./build.sh --debug

# Clean build
./build.sh --clean

# Without tests
./build.sh --no-tests
```

### Testing

```bash
# Run all tests
cd build && ctest --output-on-failure

# Run specific test
./build/bin/test_statistics
```

### Benchmarking

```bash
# Run specific benchmark
./build/bin/benchmark_statistics
```

## Project Layout

```
DSQuant/
├── src/core/              # Core library
│   ├── include/           # Public headers
│   ├── tests/             # Unit tests
│   └── benchmarks/        # Benchmarks
├── build/                 # Build output
│   ├── bin/               # Executables
│   └── lib/               # Libraries
└── docs/                  # Documentation
```

## Adding New Features (TDD)

1. **Write test** in `src/*/tests/test_feature.cpp`
2. **Run test** (should fail): `cmake --build build && ctest`
3. **Implement** in `src/*/include/dsquant/*/feature.hpp`
4. **Run test** (should pass): `cmake --build build && ctest`
5. **Benchmark** in `src/*/benchmarks/benchmark_feature.cpp`

## File Templates

### Test File
```cpp
#include <boost/ut.hpp>
#include <dsquant/core/feature.hpp>

int main() {
    using namespace boost::ut;
    
    "test name"_test = [] {
        expect(that % result == expected);
    };
    
    return 0;
}
```

### Header File
```cpp
#pragma once

namespace dsquant::component {

template<std::floating_point T>
constexpr T function(T value) noexcept {
    return value;
}

} // namespace dsquant::component
```

### Benchmark File
```cpp
#include <nanobench.h>
#include <dsquant/core/feature.hpp>

int main() {
    ankerl::nanobench::Bench().run("feature", [&] {
        ankerl::nanobench::doNotOptimizeAway(feature(input));
    });
    return 0;
}
```

## Build Options

| Option | Default | Description |
|--------|---------|-------------|
| `BUILD_TESTS` | ON | Build tests |
| `BUILD_BENCHMARKS` | ON | Build benchmarks |
| `BUILD_WITH_MODULES` | OFF | C++23 modules (experimental) |

## Requirements

- **CMake**: 3.28+
- **Compiler**: 
  - GCC 13+ (14+ for modules)
  - Clang 16+
  - MSVC 2022+
- **C++ Standard**: C++23

## Dependencies (Auto-fetched)

- **boost.ut** v2.1.0 - Testing framework
- **nanobench** v4.3.11 - Benchmarking library

## Output Locations

- Executables: `build/bin/`
- Libraries: `build/lib/`
- Test results: Shown in terminal

## Documentation

- **README.md** - Project overview
- **docs/BUILDING.md** - Build instructions
- **docs/DEVELOPMENT.md** - Development guide
- **docs/MODULES.md** - C++23 modules info

## Tips

- Use `./build.sh --clean` for fresh builds
- Run tests after every change
- Add benchmarks for performance-critical code
- Keep headers in `include/dsquant/`
- Follow TDD: Test → Implement → Refactor

## Getting Help

```bash
./build.sh --help          # Build script help
cmake -B build -LH         # List CMake options
ctest --help               # Testing options
```

## Example Workflow

```bash
# 1. Create new feature test
vim src/core/tests/test_newfeature.cpp

# 2. Add to CMakeLists.txt
vim src/core/tests/CMakeLists.txt

# 3. Build and test (should fail)
./build.sh

# 4. Implement feature
vim src/core/include/dsquant/core/newfeature.hpp

# 5. Build and test (should pass)
./build.sh

# 6. Add benchmark
vim src/core/benchmarks/benchmark_newfeature.cpp

# 7. Run benchmark
./build/bin/benchmark_newfeature
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CMake too old | `pip install cmake --upgrade` |
| Compiler not found | Install GCC 13+ or Clang 16+ |
| Build fails | `./build.sh --clean` |
| Tests fail | Check `ctest --output-on-failure` |
| Slow builds | Use `./build.sh` (uses all cores) |

## Performance Tips

- Use Release builds for benchmarks
- Enable LTO: `-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON`
- Use `-march=native` for local optimization
- Profile with `perf` or `valgrind`

## Cross-Platform

### Linux (Primary)
```bash
./build.sh
```

### Windows (MSVC)
```cmd
cmake -B build -G "Visual Studio 17 2022"
cmake --build build --config Release
```

### macOS
```bash
./build.sh
```

## Key Files

- `CMakeLists.txt` - Root build config
- `build.sh` - Build script
- `.gitignore` - Git exclusions
- `README.md` - Project docs
