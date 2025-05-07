#!/bin/bash

CICERO=bin/cicero.x86-64-linux

pass_count=0
total_count=0

cd ..

for file in test/*.co; do
  ((total_count++))
  ((total_count++))
  
  base=$(basename "$file" .co)
  $CICERO -tier=0 "$file" > "test/output/${base}_tier0.out"
  $CICERO -tier=1 "$file" > "test/output/${base}_tier1.out"
  
  if diff "test/output/${base}_tier0.out" "test/expect/$base.expect" &>/dev/null; then
    ((pass_count++))
  else
    echo "$file: FAIL (tier0)"
  fi
  if diff "test/output/${base}_tier1.out" "test/expect/$base.expect" &>/dev/null; then
    ((pass_count++))
  else
    echo "$file: FAIL (tier1)"
  fi
done

echo "$pass_count/$total_count tests passed"

cd test
