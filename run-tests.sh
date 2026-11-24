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
  expname="${f%.*}.$lang.txt"
  if [ -f $expname ]; then
    expect=$(cat $expname)
  else
    expect=$(cat "${f%.*}.txt")
  fi
  actual=$(./main.pl $f -$lang | $cmdrun)
  if [ "$expect" != "$actual" ]; then
    echo -n "[FAIL]"
  else
    echo -n "[ ok ]"
  fi
  echo " - $f"
done
