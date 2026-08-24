############  TODO Before you run the script ##########

# 3. Modify the 4 bash variables
# 4. Run the script `cd bench && bash perf.sh`

############### Variables to modify ###################

OUTPUT_DIR="results/perf"
RUNS=10
CICERO_OPTS="-cache=true -suppress-output=true"
TARGET="x86-64-linux"

#######################################################

SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BENCH_DIR=$SCRIPT_LOC
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
            # echo "perf stat -r $RUNS -d $BINARY $CICERO_OPTS $files 2> $BENCH_DIR/$OUTPUT_DIR/$benchmark.txt"
            # echo "perf stat -r $RUNS -e L1-icache-load-misses,l2_rqsts.all_demand_references,l2_rqsts.all_demand_miss,dTLB-loads,dTLB-load-misses,iTLB-loads,iTLB-load-misses,minor-faults,major-faults,cycle_activity.stalls_total,topdown-fetch-bubbles $BINARY $CICERO_OPTS $files 2>> $BENCH_DIR/$OUTPUT_DIR/$benchmark.txt"

            echo "perf record $BINARY $CICERO_OPTS $files"
            echo "perf report --stdio > $BENCH_DIR/$OUTPUT_DIR/$benchmark.txt"

            # perf script > out.perf
            # ~/FlameGraph/stackcollapse-perf.pl out.perf > out.folded
            # ~/FlameGraph/flamegraph.pl out.folded > $BENCH_DIR/$OUTPUT_DIR/$benchmark.svg
            echo "Processed: $benchmark"
        fi
    done < "run_bench.config.csv"
}

main