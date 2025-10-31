#!/bin/bash

export SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
SOM=$(cd $SCRIPT_LOC/../bench/som && pwd)
MICRO=$(cd $SCRIPT_LOC/../bench/micro && pwd)
MACRO=$(cd $SCRIPT_LOC/../bench/macro && pwd)
export BIN=$(cd $SCRIPT_LOC/../bin && pwd)
export TYPE="bench"

DEPS=''

# Add all the dependencies to provide the executable as arguments
deps_for_macro(){
    for file in $(cat $SCRIPT_LOC/bench/init.conf | grep -v -E '^=|;'); do
        DEPS+="${SOM}/${file} "
    done
}

reset_deps(){
    DEPS=''
}

source $SCRIPT_LOC/test_core.sh

if [ -d "/tmp/$USER/cicero-test/" ]; then
    rm -r /tmp/$USER/cicero-test
fi

# Move .co and .expect files to /tmp/**
for bench in $TEST_SUITES; do
    BENCH="$(basename "$bench" ".expect")"
    if [[ "$BENCH" != *".conf" ]]; then
        T=/tmp/$USER/cicero-test/$TYPE/$BENCH
        mkdir -p $T

        if [ -e "$MICRO/$BENCH.co" ]; then
            cp $MICRO/$BENCH.co $T
        else 
            if [ -e "$MICRO/$BENCH.co" ]; then
                cp $MACRO/$BENCH*.co $T
            else
                echo "ERROR: Invalid test suite"
                exit 1
            fi
        fi
        cp $SCRIPT_LOC/$TYPE/$BENCH.expect $T
    fi
done

run

exit 0