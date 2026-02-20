#!/bin/bash
set -e

echo "Cleaning build directories..."

if [[ -d "build" ]]; then
    echo "Removing build directory..."
    rm -rf build
fi

if [[ -d "build-coverage" ]]; then
    echo "Removing build-coverage directory..."
    rm -rf build-coverage
fi

echo "Clean completed successfully!"
