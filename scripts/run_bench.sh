#!/bin/bash

V3C=${V3C:=$(which v3c)}
if [ ! -x "$V3C" ]; then
    echo "Virgil compiler (v3c) not found in \$PATH, and \$V3C not set"
    exit 1
fi

HYPERFINE=${HYPERFINE:=$(which hyperfine)}
if [ ! -x "$HYPERFINE" ]; then
    echo "Hyperfine command line benchmarking tool not found!"
    exit 1
fi

PYTHON3=${PYTHON3:=$(which python3)}
if [ ! -x "$PYTHON3" ]; then
    echo "Python3 not found."
    exit 1
fi

if [ "$TARGETS" = "" ]; then
    declare -a TARGETS=("x86-64-linux")
else
    IFS=' ' read -r -a TARGETS <<< "$TARGETS"
fi

if [ "$TIERS" = "" ]; then
    declare -a TIERS=("0" "1") 
else
    IFS=' ' read -r -a TIERS <<< "$TIERS"
fi

SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BENCH_DIR=$(cd $SCRIPT_LOC/../bench/ && pwd)
SOM_DIR=$(cd $BENCH_DIR/som && pwd)
MICRO_DIR=$(cd $BENCH_DIR/micro && pwd)
MACRO_DIR=$(cd $BENCH_DIR/macro && pwd)
BIN_DIR=$(cd $SCRIPT_LOC/../bin && pwd)

# Create empty .co file for also calculating built in base time
if [ -d "/tmp/$USER/cicero-benchmarks/" ]; then
    rm -rf /tmp/$USER/cicero-benchmarks/
fi

T=/tmp/$USER/cicero-benchmarks
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
    for target in ${TARGETS[@]}; do
        if [ "$target" = "wasm-wave" ]; then
            BINARY=$BIN_DIR/cicero.wasm
        else
            BINARY=$BIN_DIR/cicero.$target
        fi
    
        for tier in "${TIERS[@]}"; do
            # base time builtin with empty file
            CSV_FILE=$(csv_file_name "empty" $tier $o_level $target)
            $HYPERFINE --warmup 5 --runs 50 "$BINARY -suppress-output=true -tier=$tier $T/empty.co" --export-csv $CSV_FILE

            # run the benchmarks
            IFS=','
            # Read the CSV file line by line to run each benchmark
            tail -n +2 "$BENCH_DIR/run_bench.config.csv" | while read -r benchmark files runs; do
                cd $BENCH_DIR
                CSV_FILE=$(csv_file_name $benchmark $tier $o_level $target)
                $HYPERFINE --warmup 5 --runs $runs "$BINARY -suppress-output=true -tier=$tier $files" --export-csv $CSV_FILE
            done
        done
    done
}

for o_level in {0..2}
do
    export V3C_O="-O$o_level"
    # Build birectory
    cd $BIN_DIR/..
    # Build cicero for the new optimization level
    make -B
    echo "Virgil Opitmization Level: $V3C_O"
    run_benchmarks
done
$PYTHON3 $SCRIPT_LOC/create_markdown.py $T $BENCH_DIR/results
