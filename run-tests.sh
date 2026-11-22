#!/usr/bin/env bash

cmdpl="perl"
cmdjs="node"
cmdphp="php"
cmdpy="python3"

lang="pl"
if [ "$1" != "" ]; then
  lang=$1
fi
cmdrun="cmd$lang"
cmdrun=${!cmdrun}

for f in tests/*.ez; do
  if grep -q "notest:$lang" $f; then
    continue
  fi
  expect=$(cat "${f%.*}.txt")
  actual=$(./main.pl $f -$lang | $cmdrun)
  if [ "$expect" != "$actual" ]; then
    echo -n "[FAIL]"
  else
    echo -n "[ ok ]"
  fi
  echo " - $f"
done
