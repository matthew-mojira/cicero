#!/bin/bash

SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
BIN=$SCRIPT_LOC/../bin

CYAN='[0;36m'
RED='[0;31m'
GREEN='[0;32m'
YELLOW='[0;33m'
NORM='[0;00m'

DEFAULT_MODES=1
if [ "$TEST_MODE" != "" ]; then
   DEFAULT_MODES=0
fi

# Progress arguments. By default the inline (i) mode is used, while the CI sets
# it to character (c) mode
PROGRESS_ARGS=${PROGRESS_ARGS:="tti"}
PROGRESS="progress $PROGRESS_ARGS"

### Utility for printing a testing line
function print_testing() {
    ARG=$1
    printf "Testing ${CYAN}%-16s${NORM} " $SUITE
    printf "%-13s "  $TEST_TARGET
    if [ "$TEST_TIER" != "" ]; then
        tier="tier$TEST_TIER"
    else
        tier=""
    fi
    printf "%-5s " $tier
    printf "| "
}

if [ "$TEST_TARGETS" = "" ]; then
    if [ "$TEST_TARGET" = "" ]; then
        TEST_TARGETS="v3i x86-linux x86-64-linux jvm wave"
    else
        TEST_TARGETS="$TEST_TARGET"
    fi
fi

if [ "$TEST_TIERS" = "" ]; then
    if [ "$TEST_TIER" = "" ]; then
        TEST_TIERS="0 1"
    else
        TEST_TIERS="$TEST_TIER"
    fi
fi

# find program suites
if [ "$TEST_SUITES" = "" ]; then
    if [ "$TEST_SUITE" = "" ]; then
        TEST_SUITES="$SCRIPT_LOC/suites/*"
    else
        TEST_SUITES="$SCRIPT_LOC/suites/$TEST_SUITE"
    fi
fi

rm -r /tmp/$USER/cicero-test

for suite in $TEST_SUITES; do
    SUITE="$(basename "$suite")"
    T=/tmp/$USER/cicero-test/suites/$SUITE
    mkdir -p $T
    mkdir -p $T/expect

    # turn suites into .co and .expect files
    ruby $SCRIPT_LOC/creator.rb suites/$SUITE

    # move to tmp
    mv $SCRIPT_LOC/suites/*.co $T
    mv $SCRIPT_LOC/suites/*.expect $T
done

function run_tests() {
    for test_prog in $T/*.co; do
        TEST_PROG="$(basename "$test_prog" .co)"
	echo "##+$TEST_PROG"

        # run test
        $BINARY -tier=$TEST_TIER $test_prog > $U/$TEST_PROG.out 2> $U/$TEST_PROG.err
        RET=$?

        if cmp -s "$U/$TEST_PROG.out" "$T/$TEST_PROG.expect"; then
            echo "##-ok"
        else
	    echo "##-fail"
	    # FIXME discriminate between different error types
	    #if [ -s "$U/$TEST_PROG.err" ]; then
            #    echo "##-fail: failed to parse or virgil exception"
            #elif [ $RET -eq 0 ]; then
	    #    echo "##-fail: mismatched output"
	    #else
	    #    echo "##-fail: raised cicero exception"
	    #fi
        fi
    done
}

# Program tests
for target in $TEST_TARGETS; do
    TEST_TARGET=$target
    BINARY=$BIN/cicero.$target
   
    for tier in $TEST_TIERS; do
        TEST_TIER=$tier
    
        for suite in $TEST_SUITES; do
            SUITE="$(basename "$suite")"
            T=/tmp/$USER/cicero-test/suites/$SUITE
            U=/tmp/$USER/cicero-test/$target/tier$TEST_TIER/$SUITE
        
            mkdir -p $U

            print_testing
            run_tests | $PROGRESS
        done
    done
done

exit 0
