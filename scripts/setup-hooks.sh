#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

chmod +x "$PROJECT_ROOT/.githooks/"*
git -C "$PROJECT_ROOT" config core.hooksPath .githooks
echo "Git hooks configured."
