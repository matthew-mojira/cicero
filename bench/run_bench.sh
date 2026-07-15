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

PROGRESS_BIN=${PROGRESS_BIN:=$(which progress)}
if [ ! -x "$PROGRESS_BIN" ]; then
    echo "Virgil's progress utility not found in \$PATH, and \$PROGRESS_BIN not set"
    exit 1
fi
PROGRESS_ARGS=${PROGRESS_ARGS:="ti"}
PROGRESS="$PROGRESS_BIN $PROGRESS_ARGS"

if [ "$BENCH_TARGETS" = "" ]; then
    BENCH_TARGETS="x86-64-linux"
fi

if [ "$BENCH_TIERS" = "" ]; then
    BENCH_TIERS="0 1"
fi

if [ "$WARMUP_RUNS" = "" ]; then
    WARMUP_RUNS=1
fi

if [ "$BENCH_OPT_LEVELS" = "" ]; then
    BENCH_OPT_LEVELS="2"
fi

if [ "$MAX_TASKS" = "" ]; then
    MAX_TASKS=10
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
BENCH_DIR=$SCRIPT_LOC
SOM_DIR=$(cd $BENCH_DIR/som && pwd)
MICRO_DIR=$(cd $BENCH_DIR/micro && pwd)
MACRO_DIR=$(cd $BENCH_DIR/macro && pwd)
REPO_ROOT=$(cd $BENCH_DIR/.. && pwd)

if [ "$BENCH_CONFIG" = "" ]; then
    BENCH_CONFIG="$BENCH_DIR/run_bench.config.csv"
else
    # Convert to absolute path if relative
    if [[ "$BENCH_CONFIG" != /* ]]; then
        BENCH_CONFIG="$(cd $(dirname "$BENCH_CONFIG") && pwd)/$(basename "$BENCH_CONFIG")"
    fi
fi

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
    # $1: runs, $2: BINARY, $3: tier, $4: files, $5: csv_file, $6: target, $7: opt level
    cd $BENCH_DIR

    if ! $HYPERFINE --style none --warmup $WARMUP_RUNS --runs "$1" \
        "$2 -suppress-output=true -tier=$3 $4" \
        --export-csv "$5" >> "$T/run.log" 2>&1
    then
        echo "[WARN] hyperfine benchmark failed for: $4 (tier=$3) for $6 -O$7, skipping" >> "$T/run.log"
        echo "##-fail: $4 (tier=$3) for $6 -O$7"
        return 0
    else
        echo "##-ok"
        return 0
    fi
}

# Export the function so background subshells can see it
export -f run_hyperfine

binary_path(){
    # $1: opt level, $2: target
    local bin_dir=$T/bin-opt$1
    if [ "$2" = "wasm-wave" ]; then
        echo "$bin_dir/cicero.wasm"
    else
        echo "$bin_dir/cicero.$2"
    fi
}

# Builds cicero for every requested target at a given Virgil optimization
# level, into its own bin directory so opt levels don't clobber each other
# and can be built/benchmarked in parallel.
build_opt_level(){
    # $1: opt level
    local o_level=$1
    local opt_bin_dir=$T/bin-opt$o_level
    mkdir -p "$opt_bin_dir"

    for target in $BENCH_TARGETS; do
        if ! OUTPUT_DIR="$opt_bin_dir" V3C_OPTS="-O$o_level" "$REPO_ROOT/build.sh" cicero "$target" \
            > "$opt_bin_dir/build-$target.log" 2>&1
        then
            echo "[WARN] build failed for $target at -O$o_level, see $opt_bin_dir/build-$target.log" >> "$T/build.log"
            echo "##-fail: $target -O$o_level"
        else
            echo "##-ok"
        fi
    done
}
export -f build_opt_level

cd "$REPO_ROOT"

NUM_TARGETS=$(echo $BENCH_TARGETS | wc -w)
NUM_OPTS=$(echo $BENCH_OPT_LEVELS | wc -w)
TOTAL_BUILDS=$(( NUM_TARGETS * NUM_OPTS ))

echo "Building optimization levels in parallel: $BENCH_OPT_LEVELS"
printf "build "
{
    echo "##>$TOTAL_BUILDS"
    for o_level in $BENCH_OPT_LEVELS; do
        build_opt_level "$o_level" &
    done
    wait
} | $PROGRESS
echo "Completed building all optimization levels (see $T/build.log for details)"

echo "Dispatching benchmarks (order: benchmark -> target -> opt -> tier)"

NUM_ROWS=$(tail -n +2 "$BENCH_CONFIG" | wc -l)
NUM_TIERS=$(echo $BENCH_TIERS | wc -w)
TOTAL_JOBS=$(( (NUM_ROWS + 1) * NUM_TARGETS * NUM_OPTS * NUM_TIERS ))

# Same pattern test_core.sh uses (print_testing; run_tests | $PROGRESS): print
# a plain label first, then pipe the dispatch group's "##-ok"/"##-fail" lines
# into `progress` so it renders a live running count.
printf "bench "
{
    echo "##>$TOTAL_JOBS"

    # Baseline empty-file timing, dispatched up front so it doesn't block benchmark rows.
    for target in $BENCH_TARGETS; do
        for o_level in $BENCH_OPT_LEVELS; do
            for tier in $BENCH_TIERS; do
                BINARY=$(binary_path "$o_level" "$target")
                CSV_FILE=$(csv_file_name "empty" $tier $o_level $target)
                run_with_lock run_hyperfine 50 "$BINARY" "$tier" "$T/empty.co" "$CSV_FILE" "$target" "$o_level"
            done
        done
    done

    while IFS=',' read -r benchmark files runs; do
        for target in $BENCH_TARGETS; do
            for o_level in $BENCH_OPT_LEVELS; do
                for tier in $BENCH_TIERS; do
                    BINARY=$(binary_path "$o_level" "$target")
                    CSV_FILE=$(csv_file_name $benchmark $tier $o_level $target)
                    run_with_lock run_hyperfine "$runs" "$BINARY" "$tier" "$files" "$CSV_FILE" "$target" "$o_level"
                done
            done
        done
    done < <(tail -n +2 "$BENCH_CONFIG")

    wait
} | $PROGRESS
echo "Completed running all benchmarks (see $T/run.log for details)"

$PYTHON3 $BENCH_DIR/../scripts/create_markdown.py $T $BENCH_DIR/results $BENCH_CONFIG
