#!/bin/bash

cabal install --installdir=. --overwrite-policy=always

pass_count=0
total_count=0

for file in test/*.co; do
  ((total_count++))
  
  base=$(basename "$file" .co)
  ./cicero "$file" > "test/output/$base.out"
  
  if diff "test/output/$base.out" "test/expect/$base.expect" &>/dev/null; then
#    echo "$file: PASS"
    ((pass_count++))
  else
    echo "$file: FAIL"
  fi
done

echo "$pass_count/$total_count tests passed"
