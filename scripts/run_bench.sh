#!/bin/bash
# For the semaphore logic: I am using/modifying code from here:
# https://unix.stackexchange.com/questions/103920/parallelize-a-bash-for-loop

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

if [ "$MAX_TASKS" = "" ]; then
    MAX_TASKS=5
fi

abort_run_bench() {
    # Kill all child processes of the current script ($$)
    # This is safer/cleaner than tracking a massive list of pids
    pkill -P $$ >/dev/null 2>&1
    echo "Script aborted"
    exit 1
}
# if we have an error, we want to call `abort_run_bench` function instead
trap 'abort_run_bench' ERR SIGINT SIGTERM

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

# initialize a semaphore with a given number of tokens
open_sem(){
    mkfifo $T/pipe-$$
    exec 3<>$T/pipe-$$
    rm $T/pipe-$$
    local i=$1
    for((;i>0;i--)); do
        printf %s 000 >&3
    done
}
open_sem "$MAX_TASKS"

run_with_lock(){
    local x
    read -u 3 -n 3 x && ((0==x)) || exit $x
    (
        # Execute internal Bash function:
        "$@"
        # Return exit code to semaphore
        printf '%.3d' $? >&3
    ) &
}

csv_file_name(){
    _benchmark=$1
    _tier=$2
    _opt=$3
    _target=$4
    echo "$T/$_benchmark-tier$_tier-opt$_opt-$_target.csv"
}

run_hyperfine(){
    # $1: runs, $2: BINARY, $3: tier, $4: files, $5: csv_file
    cd $BENCH_DIR
    $HYPERFINE --style none --warmup 5 --runs "$1" "$2 -suppress-output=true -tier=$3 $4" --export-csv "$5" 2>&1
}
# Export the function so background subshells can see it
export -f run_hyperfine

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
            $HYPERFINE --style none --warmup 5 --runs 50 "$BINARY -suppress-output=true -tier=$tier $T/empty.co" --export-csv $CSV_FILE 2>&1

            # run the benchmarks
            while IFS=',' read -r benchmark files runs; do
                CSV_FILE=$(csv_file_name $benchmark $tier $o_level $target)
                # run async
                run_with_lock run_hyperfine $runs "$BINARY" "$tier" "$files" "$CSV_FILE" "$BENCH_DIR"
            done < <(tail -n +2 "$BENCH_DIR/run_bench.config.csv")
        done
    done
}

for o_level in {0..2}
do
    export V3C_OPTS="-O$o_level"
    # Build birectory
    cd $BIN_DIR/..
    # Build cicero for the new optimization level
    make -B
    echo "Virgil Opitmization Level: $V3C_OPTS"
    run_benchmarks
    wait
    echo "Completed running all benchmarks for $V3C_OPTS"
done
$PYTHON3 $SCRIPT_LOC/create_markdown.py $T $BENCH_DIR/results
