#!/bin/bash

V3C=${V3C:=$(which v3c)}
if [ ! -x "$V3C" ]; then
    echo "Virgil compiler (v3c) not found in \$PATH, and \$V3C not set"
    exit 1
fi

if [ "$TARGETS" = "" ]; then
    # TARGETS="x86-linux x86-64-linux jvm wasm-wave"
    TARGETS="x86-linux"
fi

if [ "$TIERS" = "" ]; then
    TIERS="0 1"
fi

SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SOM_DIR=$(cd $SCRIPT_LOC/som && pwd)
MICRO_DIR=$(cd $SCRIPT_LOC/micro && pwd)
MACRO_DIR=$(cd $SCRIPT_LOC/macro && pwd)
BIN_DIR=$(cd $SCRIPT_LOC/../bin && pwd)

# Create empty .co file for also calculating built in base time
if [ -d "/tmp/$USER/cicero-bench/" ]; then
    rm -rf /tmp/$USER/cicero-bench/
fi

T=/tmp/$USER/cicero-bench
mkdir -p $T
touch $T/empty.co

csv_file_name(){
    _benchmark=$1
    _tier=$2
    _opt=$3
    _target=$4
    echo "$T/$_benchmark-tier$_tier-opt$_opt-$_target.csv"
}

# Runs all benchmarks(across all targets and tiers) for a given virgil compiler optimization level
run_benchmarks(){
    read -r -a _TIERS <<< "$TIERS"
    for target in $TARGETS; do
        if [ "$target" = "wasm-wave" ]; then
            BINARY=$BIN_DIR/cicero.wasm
        else
            BINARY=$BIN_DIR/cicero.$target
        fi
    
        for tier in "${_TIERS[@]}"; do
            # base time builtin with empty file
            CSV_FILE=$(csv_file_name "empty" $tier $o_level $target)
            hyperfine --warmup 5 --runs 50 "$BINARY -suppress-output=true -tier=$tier $T/empty.co" --export-csv $CSV_FILE

            # run the benchmarks
            IFS=','
            # Read the CSV file line by line to run each benchmark
            tail -n +2 "$SCRIPT_LOC/run_bench.config.csv" | while read -r benchmark files runs; do
                cd $SCRIPT_LOC
                CSV_FILE=$(csv_file_name $benchmark $tier $o_level $target)
                hyperfine --warmup 5 --runs $runs "$BINARY -suppress-output=true -tier=$tier $files" --export-csv $CSV_FILE
            done
        done
    done
}

for o_level in {0..2}
do
    V3C_O="-O$o_level"
    # Build birectory
    cd $BIN_DIR/..
    # Build cicero for the new optimization level
    make -B
    echo "Virgil Opitmization Level: $V3C_O"
    run_benchmarks
done