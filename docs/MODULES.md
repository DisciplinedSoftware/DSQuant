# C++23 Modules in DSQuant

## Overview

DSQuant is designed to support both traditional header-based and modern C++23 module-based implementations. Currently, the traditional approach is used for maximum compatibility.

## Current Status

**Traditional Headers (Current Implementation)**
- ✅ Full support across all compilers (GCC 13+, Clang 16+, MSVC 2022+)
- ✅ Works on Linux, Windows, macOS
- ✅ Standard CMake integration
- ✅ Fast incremental builds

**C++23 Modules (Future/Experimental)**
- ⚠️ Experimental support via `BUILD_WITH_MODULES=ON`
- ⚠️ Requires GCC 14+, Clang 16+, or MSVC 17.10+
- ⚠️ CMake 3.28+ with experimental module support
- ⚠️ Build times may be longer initially

## Why Modules?

### Benefits
1. **Faster Compilation**: No redundant header parsing
2. **Better Encapsulation**: Clear interface vs implementation separation
3. **No Header Guards**: Modules are imported once
4. **Improved Tooling**: Better IDE support (in the future)
5. **Isolation**: Changes don't trigger massive rebuilds

### Challenges
1. **Compiler Support**: Still experimental in many compilers
2. **Build Systems**: CMake support is evolving
3. **Migration**: Gradual transition needed
4. **Ecosystem**: Many libraries still use headers

## Comparison Example

### Traditional Header Approach (Current)

**include/dsquant/core/statistics.hpp:**
```cpp
#pragma once

#include <cmath>
#include <concepts>

namespace dsquant::core {

template<std::floating_point T>
constexpr T mean(const T* begin, const T* end) noexcept {
    // Implementation
}

} // namespace dsquant::core
```

**Usage:**
```cpp
#include <dsquant/core/statistics.hpp>

double result = dsquant::core::mean(data, data + size);
```

### Module Approach (Future)

**src/core/statistics.cppm:**
```cpp
export module dsquant.core.statistics;

import std;

export namespace dsquant::core {

template<std::floating_point T>
constexpr T mean(const T* begin, const T* end) noexcept {
    // Implementation
}

} // namespace dsquant::core
```

**Usage:**
```cpp
import dsquant.core.statistics;

double result = dsquant::core::mean(data, data + size);
```

## Migration Strategy

### Phase 1: Header-Only (Current)
- Maintain traditional headers
- Ensure cross-compiler compatibility
- Focus on functionality and testing

### Phase 2: Dual Implementation
- Add module implementations alongside headers
- Use `BUILD_WITH_MODULES` option to choose
- Compare compilation times and compatibility

### Phase 3: Module-First (Future)
- Module implementation as primary
- Headers available for legacy support
- Document migration guide for users

## Building with Modules

### Prerequisites

**GCC:**
```bash
# GCC 14+ with module support
g++ --version  # Should be 14.0 or higher
```

**Clang:**
```bash
# Clang 16+ with module support
clang++ --version  # Should be 16.0 or higher
```

**MSVC:**
- Visual Studio 2022 17.10 or later
- `/std:c++latest` flag

### Build Commands

```bash
# Configure with modules
cmake -B build -DBUILD_WITH_MODULES=ON -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build -j$(nproc)
```

## CMake Module Support

### Current Implementation

CMakeLists.txt detects module support:
```cmake
if(BUILD_WITH_MODULES)
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 14.0)
            add_compile_options(-fmodules-ts)
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 16.0)
            add_compile_options(-fmodules)
        endif()
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        add_compile_options(/std:c++latest)
    endif()
endif()
```

### Future Implementation

When modules are fully implemented:
```cmake
add_library(dsquant_core)
target_sources(dsquant_core
    PUBLIC
        FILE_SET CXX_MODULES FILES
            src/core/statistics.cppm
            src/core/options.cppm
)
```

## Performance Comparison

### Expected Results (when implemented)

| Metric | Headers | Modules | Improvement |
|--------|---------|---------|-------------|
| Clean Build | 10.0s | 15.0s | -50% (initial BMI) |
| Incremental Build | 5.0s | 1.0s | +80% |
| Binary Size | 2.5MB | 2.3MB | +8% |

*Note: Actual results depend on project size and compiler*

## Testing Strategy

Both implementations must:
1. Pass identical test suites
2. Produce identical results
3. Maintain API compatibility
4. Support all target platforms

## Resources

- [C++23 Modules - cppreference](https://en.cppreference.com/w/cpp/language/modules)
- [GCC C++ Modules](https://gcc.gnu.org/wiki/cxx-modules)
- [Clang Modules](https://clang.llvm.org/docs/StandardCPlusPlusModules.html)
- [MSVC Modules](https://docs.microsoft.com/en-us/cpp/cpp/modules-cpp)
- [CMake Modules Support](https://www.kitware.com/import-cmake-c20-modules/)

## Contributing

When adding new functionality:
1. Implement with traditional headers first
2. Ensure all tests pass
3. Add module implementation later (optional)
4. Document both approaches

## FAQ

**Q: When will modules be the default?**
A: When compiler support is stable across GCC, Clang, and MSVC (estimated: 2025+)

**Q: Can I use modules now?**
A: Yes, experimentally with `BUILD_WITH_MODULES=ON`. Headers remain recommended.

**Q: Will headers be removed?**
A: Not in the foreseeable future. Headers will remain for compatibility.

**Q: Do modules affect runtime performance?**
A: No, only compilation time. Binary performance is identical.

**Q: What about third-party libraries?**
A: We'll continue supporting header-based dependencies (boost.ut, nanobench) until they adopt modules.
