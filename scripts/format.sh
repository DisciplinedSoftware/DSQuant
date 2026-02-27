#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Formatting C++ files in DSQuant..."
find "$PROJECT_ROOT" \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.cc" \) \
    ! -path "*/build/*" \
    ! -path "*/build-coverage/*" \
    ! -path "*/_deps/*" \
    ! -path "*/.git/*" \
    -exec clang-format -i "$@" {} +
echo "Code formatting completed successfully!"
