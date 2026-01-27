#!/bin/bash
#
# View the most recent benchmark result file

RESULTS_DIR="$(pwd)/results"

if [ ! -d "$RESULTS_DIR" ]; then
    echo "Error: results directory not found at $RESULTS_DIR"
    exit 1
fi

LATEST_FILE=$(ls -t "$RESULTS_DIR"/*.md 2>/dev/null | head -1)

if [ -z "$LATEST_FILE" ]; then
    echo "Error: No .md files found in $RESULTS_DIR"
    exit 1
fi

# Check if 'view' command exists (less is a common alternative)
if command -v glow >/dev/null 2>&1; then
    glow "$LATEST_FILE"
elif command -v view >/dev/null 2>&1; then
    view "$LATEST_FILE"
else
    cat "$LATEST_FILE"
fi
