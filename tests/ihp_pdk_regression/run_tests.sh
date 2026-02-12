#!/bin/bash
# run_tests.sh — host-side orchestrator (PDK fork version)
# Builds ngspice in Docker, then runs IHP PDK regression tests
# Run from the IHP-Open-PDK-fork/tests/ihp_pdk_regression/ directory
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PDK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
NGSPICE_ROOT="${NGSPICE_SRC:-/home/montanares/personal_exp/ai-ihp-demo/ngspice/ngspice-ngspice}"

if [ ! -d "$NGSPICE_ROOT/src" ]; then
    echo "ERROR: ngspice source not found at $NGSPICE_ROOT"
    echo "Set NGSPICE_SRC to the ngspice source directory"
    exit 1
fi

if [ ! -d "$PDK_ROOT/ihp-sg13g2" ]; then
    echo "ERROR: IHP PDK not found at $PDK_ROOT"
    exit 1
fi

echo "ngspice source: $NGSPICE_ROOT"
echo "IHP PDK path:   $PDK_ROOT"
echo ""

echo "Building ngspice Docker image..."
docker build -t ngspice-ihp "$NGSPICE_ROOT"

echo ""
echo "Running IHP PDK regression tests..."
docker run --rm \
    -v "$PDK_ROOT":/pdk:ro \
    -v "$SCRIPT_DIR":/tests \
    ngspice-ihp \
    bash /tests/validate.sh
