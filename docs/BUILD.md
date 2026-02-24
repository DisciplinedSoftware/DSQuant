# DSQuant - Building and Testing

## Build Instructions

1. Create a build directory:
```bash
mkdir build
cd build
```

2. Configure with CMake:
```bash
cmake ..
```

3. Build the project:
```bash
cmake --build .
```

## Output

The build produces three files in the `build/output/` directory:
- `libdsquant.so` - The DSQuant dynamic library
- `fibonacci_test` - Test executable for the Fibonacci function
- `fibonacci_benchmark` - Benchmark executable for the Fibonacci function

## Running Tests

```bash
./build/output/fibonacci_test
```

## Running Benchmarks

```bash
./build/output/fibonacci_benchmark
```

## Library Usage

To use the DSQuant library in your project:

```cpp
#include "fibonacci.hpp"

int main() {
    uint64_t result = dsquant::fibonacci(10);
    // result = 55
    return 0;
}
```
