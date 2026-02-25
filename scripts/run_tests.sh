SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Building DSQuant..."
./scripts/build.sh
echo "Running tests for DSQuant..."
ctest --test-dir build --output-on-failure "$@"