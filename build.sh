#!/bin/bash
# Build script for DSQuant project

set -e  # Exit on error

# Default values
BUILD_TYPE="${BUILD_TYPE:-Release}"
BUILD_DIR="${BUILD_DIR:-build}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc)}"
BUILD_TESTS="${BUILD_TESTS:-ON}"
BUILD_BENCHMARKS="${BUILD_BENCHMARKS:-ON}"
BUILD_WITH_MODULES="${BUILD_WITH_MODULES:-OFF}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --debug)
            BUILD_TYPE="Debug"
            shift
            ;;
        --release)
            BUILD_TYPE="Release"
            shift
            ;;
        --clean)
            CLEAN=1
            shift
            ;;
        --no-tests)
            BUILD_TESTS="OFF"
            shift
            ;;
        --no-benchmarks)
            BUILD_BENCHMARKS="OFF"
            shift
            ;;
        --with-modules)
            BUILD_WITH_MODULES="ON"
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --debug            Build in Debug mode (default: Release)"
            echo "  --release          Build in Release mode"
            echo "  --clean            Clean build directory before building"
            echo "  --no-tests         Skip building tests"
            echo "  --no-benchmarks    Skip building benchmarks"
            echo "  --with-modules     Enable C++23 modules (experimental)"
            echo "  --help             Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  BUILD_TYPE         Build type (Debug/Release)"
            echo "  BUILD_DIR          Build directory (default: build)"
            echo "  PARALLEL_JOBS      Number of parallel jobs (default: $(nproc))"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_info "DSQuant Build Script"
print_info "===================="

# Clean if requested
if [ -n "$CLEAN" ]; then
    print_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

# Configure
print_info "Configuring project..."
print_info "  Build Type: $BUILD_TYPE"
print_info "  Build Directory: $BUILD_DIR"
print_info "  Tests: $BUILD_TESTS"
print_info "  Benchmarks: $BUILD_BENCHMARKS"
print_info "  Modules: $BUILD_WITH_MODULES"

cmake -B "$BUILD_DIR" \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DBUILD_TESTS="$BUILD_TESTS" \
    -DBUILD_BENCHMARKS="$BUILD_BENCHMARKS" \
    -DBUILD_WITH_MODULES="$BUILD_WITH_MODULES"

# Build
print_info "Building project with $PARALLEL_JOBS parallel jobs..."
cmake --build "$BUILD_DIR" -j "$PARALLEL_JOBS"

# Run tests if built
if [ "$BUILD_TESTS" = "ON" ]; then
    print_info "Running tests..."
    cd "$BUILD_DIR" && ctest --output-on-failure
    cd ..
    print_info "Tests completed successfully!"
fi

print_info "Build completed successfully!"
print_info "Executables are in: $BUILD_DIR/bin/"
print_info "Libraries are in: $BUILD_DIR/lib/"
