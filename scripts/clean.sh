#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Cleaning build directories..."

if [[ -d ".build" ]]; then
    echo "Removing build directory..."
    rm -rf .build
fi

if [[ -d ".build-coverage" ]]; then
    echo "Removing build-coverage directory..."
    rm -rf .build-coverage
fi

echo "Clean completed successfully!"
