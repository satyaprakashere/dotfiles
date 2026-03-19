#!/bin/bash

# Configuration
PROGRAM_NAME="my_odin_app"
ENTRY_FILE="main.odin"
FLAMEGRAPH_DIR="$HOME/github/FlameGraph" # Path to your cloned FlameGraph repo

# 1. Build the Odin program with debug symbols
# -debug: Includes DWARF info
# -o:speed: (Optional) Use optimizations so the profile reflects real-world use
echo "--- Building Odin Program ---"
odin build . -file -debug -o:speed -out:$PROGRAM_NAME

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

# 2. Profile the application
# -g: Enables call-graph recording
echo "--- Profiling... (Ctrl+C when done if it's a long-running app) ---"
perf record -F 99 -g -- ./$PROGRAM_NAME

# 3. Process the data
echo "--- Generating Flame Graph ---"
perf script | \
    $FLAMEGRAPH_DIR/stackcollapse-perf.pl | \
    $FLAMEGRAPH_DIR/flamegraph.pl > flamegraph.svg

echo "--- Done! Created flamegraph.svg ---"
