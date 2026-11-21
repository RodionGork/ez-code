#!/usr/bin/env bash

cmdout="-run"
cmdrun=""
cmdpl="perl"
cmdjs="node"
cmdphp="php"
cmdpy="python3"

lang="pl"
if [ "$1" != "" ]; then
  lang=$1
  cmdout="-$1 _res.txt"
  cmdrun="cmd$1"
  cmdrun="${!cmdrun} _res.txt"
fi

for f in tests/*.ez; do
  if grep -q "notest:$lang" $f; then
    continue
  fi
  expect=$(cat "${f%.*}.txt")
  actual=$(./main.pl $f $cmdout; $cmdrun)
  if [ "$expect" != "$actual" ]; then
    echo -n "[FAIL]"
  else
    echo -n "[ ok ]"
  fi
  echo " - $f"
done
