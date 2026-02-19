#!/bin/bash
# Generate code coverage reports for DSQuant library

set -e

BUILD_DIR="${1:-build-coverage}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"

# Ensure we're in the project root or use specified build directory
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $(basename "$0") [build_directory]"
    echo "Generate code coverage reports for the DSQuant library"
    echo ""
    echo "Arguments:"
    echo "  build_directory    Path to CMake build directory (default: build-coverage)"
    echo ""
    echo "Example:"
    echo "  $(basename "$0") build-coverage"
    exit 0
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found: $BUILD_DIR"
    exit 1
fi

echo "Generating coverage reports in: $BUILD_DIR"
echo ""

cd "$BUILD_DIR"

# Check for required tools
if ! command -v lcov &> /dev/null; then
    echo "Error: lcov is not installed"
    echo "Install it with: sudo apt-get install lcov"
    exit 1
fi

if ! command -v genhtml &> /dev/null; then
    echo "Error: genhtml is not installed"
    echo "Install it with: sudo apt-get install lcov"
    exit 1
fi

# Capture coverage data (excluding system headers, dependencies, and tests)
echo "Capturing coverage data..."
lcov --capture --directory . --output-file coverage.info --quiet \
    --exclude '/usr/*' \
    --exclude '*/_deps/*' \
    --exclude '*/tests/*'

# Generate HTML report
echo "Generating HTML report..."
genhtml coverage.info --output-directory html --quiet

echo ""
echo "✓ Coverage report generated successfully!"
echo ""
echo "View the report at:"
echo "  file://$BUILD_DIR/html/index.html"
echo ""
echo "Or open it with your browser:"
echo "  xdg-open html/index.html  (Linux)"
echo "  open html/index.html      (macOS)"
echo "  start html\\index.html     (Windows)"
