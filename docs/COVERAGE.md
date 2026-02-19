# Code Coverage Setup

This guide explains how to use code coverage with the DSQuant CMake project.

## Prerequisites

Install code coverage tools:

```bash
sudo apt-get install gcov lcov
```

## Enabling Coverage

Coverage is disabled by default to avoid performance impact during normal development. To enable it:

### Option 1: Using CMake Preset (Recommended)

The project includes a `coverage` preset that automatically enables coverage:

```bash
cmake --preset coverage
cmake --build --preset coverage
ctest --preset coverage
```

### Option 2: Manual Configuration

```bash
# Configure with coverage enabled
cmake -DENABLE_COVERAGE=ON -DCMAKE_BUILD_TYPE=Debug -B build-coverage

# Build
cmake --build build-coverage

# Run tests
ctest --test-dir build-coverage
```

## Generating Coverage Reports

The project includes a convenient script to generate HTML coverage reports:

```bash
./generate_coverage.sh build-coverage
```

This generates an HTML report at `build-coverage/html/index.html`.

## Using with VS Code

### Viewing Coverage in VS Code

1. **Install the Coverage Gutters extension** (optional):
   - Open VS Code Extensions
   - Search for "Coverage Gutters"
   - Install the extension

2. **View coverage reports**:
   - After running tests with coverage, open the HTML report:
   - Right-click on the build directory in explorer
   - Open the `html/index.html` file in your browser
   - Or run: `xdg-open build-coverage/html/index.html`

### Automated Workflow

1. Build with coverage preset:

   ```bash
   cmake --preset coverage
   cmake --build --preset coverage
   ```

2. Run tests:

   ```bash
   ctest --preset coverage
   ```

3. Generate report:

   ```bash
   ./generate_coverage.sh build-coverage
   ```

4. View in browser:

   ```bash
   xdg-open build-coverage/html/index.html
   ```

## Understanding Coverage Reports

The HTML coverage report shows:

- **Lines**: Percentage of source code lines executed during tests
- **Functions**: Percentage of functions/methods called
- **Branches**: Percentage of conditional branches taken

Goal: Aim for >80% coverage of library code.

## How Coverage Works

1. **Compilation**: When `ENABLE_COVERAGE=ON`, the compiler adds special instrumentation flags (`--coverage`)
2. **Execution**: Running compiled tests generates coverage data files (`.gcda`)
3. **Analysis**: `lcov` and `genhtml` convert raw coverage data to readable reports

## Troubleshooting

### "No coverage info files for CMake project"

This is fixed! Previously, ctest couldn't find coverage data because:

- Coverage wasn't configured in CMake
- `.gcno` and `.gcda` files weren't being generated

The new configuration handles this automatically.

### Coverage report appears empty

1. Ensure tests are actually running:

   ```bash
   ctest --preset coverage -V
   ```

2. Check `.gcda` files exist:

   ```bash
   find build-coverage -name "*.gcda"
   ```

3. Regenerate the report:

   ```bash
   rm build-coverage/coverage*.info
   ./generate_coverage.sh build-coverage
   ```

### Missing lcov or genhtml

Install the complete lcov package:

```bash
sudo apt-get install lcov
```

## Performance Note

Coverage instrumentation adds overhead:

- **Compilation**: 10-20% slower
- **Execution**: 10-30% slower

Use separate `build-coverage` directory to avoid affecting normal development builds.

## Related Files

- `CMakeLists.txt` - Defines `ENABLE_COVERAGE` option
- `CMakePresets.json` - Defines `coverage` preset
- `cmake/CodeCoverage.cmake` - Coverage configuration module
- `cmake/CTestConfig.cmake.in` - CTest coverage integration
- `generate_coverage.sh` - Helper script for report generation
