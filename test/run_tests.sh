#!/bin/bash

function exit_usage() {
    echo "Usage: run_tests.sh <tier>"
    exit 1
}

if [ "$#" -lt 1 ]; then
    exit_usage
fi

CICERO=bin/cicero.x86-64-linux
TIER=$1

pass_count=0
total_count=0

cd ..

for file in test/*.co; do
  ((total_count++))
  
  base=$(basename "$file" .co)
  $CICERO -tier=$TIER "$file" > "test/output/${base}_tier$TIER.out" 2> "test/output/${base}_tier$TIER.err"
  
  if diff "test/output/${base}_tier$TIER.out" "test/expect/$base.expect" &>/dev/null; then
    ((pass_count++))
  else
    echo "$file: FAIL (tier$TIER)"
  fi
done

echo "$pass_count/$total_count tests passed"

cd test
