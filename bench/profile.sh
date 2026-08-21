############  TODO Before you run the script ##########

# 1. Modify Options.v3 and set the profiler option you want as true. Save the file.
# 2. Run `make`
# 3. Modify the 4 bash variables
# 4. Run the script `cd bench && bash profile.sh`

############### Variables to modify ###################

OUTPUT_DIR="results/dynamicOpcodePair/rtdsc/noCache"
# Number of runs for each benchmark file
RUNS=20
# CICERO_OPTS="-tier=1 -do-not-evaluate=true"
# CICERO_OPTS="-tier=1 -cache=true -suppress-output=true"
CICERO_OPTS="-tier=1 -suppress-output=true"
TARGET="x86-64-linux"

#######################################################

SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BENCH_DIR=$(cd $SCRIPT_LOC/../bench && pwd)
BIN_DIR=$(cd $BENCH_DIR/../bin && pwd)
BINARY=$BIN_DIR/cicero.$TARGET

main(){
    rm -rf $OUTPUT_DIR
    mkdir -p $OUTPUT_DIR

    header_lines=1
    while IFS=, read -r benchmark files _
    do
        if ((header_lines))
        then
            ((header_lines--))
        else
            # name of benchmark: $benchmark, files to run that benchmark: $files
            if (( RUNS < 2 )); then
                $BINARY $CICERO_OPTS $files > $BENCH_DIR/$OUTPUT_DIR/$benchmark.csv
                echo "Processed: $benchmark"
            else
                for ((run=0; run<RUNS ;run++)); do
                    $BINARY $CICERO_OPTS $files > $BENCH_DIR/$OUTPUT_DIR/$benchmark$run.csv
                    echo "Processed: $benchmark $run"
                done
            fi
        fi
    done < "run_bench.config.csv"
}

main