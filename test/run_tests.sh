#!/bin/bash

export SCRIPT_LOC=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
export BIN=$(cd $SCRIPT_LOC/../bin && pwd)
export TYPE="suites"

source $SCRIPT_LOC/test_core.sh

if [ -d "/tmp/$USER/cicero-test/" ]; then
    rm -r /tmp/$USER/cicero-test
fi

for suite in $TEST_SUITES; do
    SUITE="$(basename "$suite")"
    T=/tmp/$USER/cicero-test/$TYPE/$SUITE
    mkdir -p $T

    # turn suites into .co and .expect files
    ruby $SCRIPT_LOC/creator.rb $SCRIPT_LOC/$TYPE/$SUITE

    # move to tmp
    mv $SCRIPT_LOC/$TYPE/*.co $T
    mv $SCRIPT_LOC/$TYPE/*.expect $T
done

run
exit 0
