#!/usr/bin/env bash

for f in tests/*.ez; do
  expect=$(cat "${f%.*}.txt")
  actual=$(./main.pl $f -run)
  if [ "$expect" != "$actual" ]; then
    echo -n "[FAIL]"
  else
    echo -n "[ ok ]"
  fi
  echo " - $f"
done