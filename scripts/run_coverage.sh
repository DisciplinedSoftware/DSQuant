#!/bin/bash
# Run coverage build and generate reports for DSQuant library

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Building DSQuant with code coverage instrumentation..."
"$SCRIPT_DIR/build.sh" --coverage

echo ""
echo "Generating coverage report..."
"$SCRIPT_DIR/generate_coverage.sh" build-coverage

echo ""
echo "✓ Coverage workflow completed successfully!"
echo ""
echo "Opening coverage report..."
echo ""

# Detect OS and open report
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "$PROJECT_ROOT/build-coverage/html/index.html" &>/dev/null || echo "Report available at: file://$PROJECT_ROOT/build-coverage/html/index.html"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    open "$PROJECT_ROOT/build-coverage/html/index.html" &>/dev/null || echo "Report available at: file://$PROJECT_ROOT/build-coverage/html/index.html"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    start "$PROJECT_ROOT\\build-coverage\\html\\index.html" &>/dev/null || echo "Report available at: file://$PROJECT_ROOT/build-coverage/html/index.html"
else
    echo "Report available at: file://$PROJECT_ROOT/build-coverage/html/index.html"
fi
