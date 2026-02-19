#!/bin/bash
# Build script for DSQuant project

# This script must be executed, not sourced.
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "[ERROR] Do not source build.sh. Run it as: ./build.sh [options]" >&2
    return 1
fi

set -e  # Exit on error

# Default values
BUILD_TYPE="${BUILD_TYPE:-Release}"
BUILD_DIR="${BUILD_DIR:-build}"
PARALLEL_JOBS="${PARALLEL_JOBS:-$(nproc 2>/dev/null || echo 1)}"
BUILD_TESTING="${BUILD_TESTING:-${BUILD_TESTS:-ON}}"
BUILD_BENCHMARKS="${BUILD_BENCHMARKS:-ON}"
BUILD_WITH_MODULES="${BUILD_WITH_MODULES:-OFF}"
BUILD_SHARED_LIBS="${BUILD_SHARED_LIBS:-ON}"
ENABLE_COVERAGE="${ENABLE_COVERAGE:-OFF}"

# Colors for output (ANSI escape codes for better compatibility)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    printf "%b\n" "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    printf "%b\n" "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    printf "%b\n" "${RED}[ERROR]${NC} $1" >&2
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
            BUILD_TESTING="OFF"
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
        --static)
            BUILD_SHARED_LIBS="OFF"
            shift
            ;;
        --shared)
            BUILD_SHARED_LIBS="ON"
            shift
            ;;
        --coverage)
            ENABLE_COVERAGE="ON"
            BUILD_TYPE="Debug"
            BUILD_DIR="build-coverage"
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
            echo "  --static           Build static libraries"
            echo "  --shared           Build shared libraries (default)"
            echo "  --coverage         Build with code coverage instrumentation (Debug + build-coverage/)"
            echo "  --help             Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  BUILD_TYPE         Build type (Debug/Release)"
            echo "  BUILD_DIR          Build directory (default: build)"
            echo "  PARALLEL_JOBS      Number of parallel jobs (default: $(nproc))"
            echo "  BUILD_TESTING      Build tests (ON/OFF, default: ON)"
            echo "  BUILD_SHARED_LIBS  Build shared libs (ON/OFF, default: ON)"
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

case "$BUILD_TYPE" in
    Debug)
        CONFIGURE_PRESET="debug"
        ;;
    Release)
        CONFIGURE_PRESET="release"
        ;;
    *)
        print_error "Unsupported BUILD_TYPE '$BUILD_TYPE' (expected Debug or Release)"
        exit 1
        ;;
esac

# Clean if requested
if [ -n "$CLEAN" ]; then
    print_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"
fi

if [ -f "$BUILD_DIR/CMakeCache.txt" ]; then
    PREVIOUS_BUILD_SHARED_LIBS=$(grep '^BUILD_SHARED_LIBS:BOOL=' "$BUILD_DIR/CMakeCache.txt" | cut -d= -f2 || true)
    if [ -n "$PREVIOUS_BUILD_SHARED_LIBS" ] && [ "$PREVIOUS_BUILD_SHARED_LIBS" != "$BUILD_SHARED_LIBS" ]; then
        print_info "Library type changed (${PREVIOUS_BUILD_SHARED_LIBS} -> ${BUILD_SHARED_LIBS}); cleaning build directory..."
        rm -rf "$BUILD_DIR"
    fi
fi

# Configure
print_info "Configuring project..."
print_info "  Build Type: $BUILD_TYPE"
print_info "  Build Directory: $BUILD_DIR"
print_info "  Configure Preset: $CONFIGURE_PRESET"
print_info "  Tests: $BUILD_TESTING"
print_info "  Benchmarks: $BUILD_BENCHMARKS"
print_info "  Modules: $BUILD_WITH_MODULES"
print_info "  Shared Libs: $BUILD_SHARED_LIBS"
print_info "  Coverage: $ENABLE_COVERAGE"

if [ "$ENABLE_COVERAGE" = "ON" ]; then
    # Use coverage preset if coverage is enabled
    cmake --preset coverage -B "$BUILD_DIR" \
        -DBUILD_TESTING="$BUILD_TESTING" \
        -DBUILD_BENCHMARKS="$BUILD_BENCHMARKS" \
        -DBUILD_WITH_MODULES="$BUILD_WITH_MODULES" \
        -DBUILD_SHARED_LIBS="$BUILD_SHARED_LIBS"
else
    cmake --preset "$CONFIGURE_PRESET" -B "$BUILD_DIR" \
        -DBUILD_TESTING="$BUILD_TESTING" \
        -DBUILD_BENCHMARKS="$BUILD_BENCHMARKS" \
        -DBUILD_WITH_MODULES="$BUILD_WITH_MODULES" \
        -DBUILD_SHARED_LIBS="$BUILD_SHARED_LIBS"
fi

# Build
print_info "Building project with $PARALLEL_JOBS parallel jobs..."
cmake --build "$BUILD_DIR" -j "$PARALLEL_JOBS"

# Run tests if built
if [ "$BUILD_TESTING" = "ON" ]; then
    print_info "Running tests..."
    (cd "$BUILD_DIR" && ctest --output-on-failure)
    print_info "Tests completed successfully!"
fi

print_info "Build completed successfully!"
print_info "Executables are in: $BUILD_DIR/bin/"
print_info "Libraries are in: $BUILD_DIR/lib/"
