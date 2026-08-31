#!/bin/sh
set -eu

remaining=1366
while [ "$remaining" -gt 0 ]; do
    printf '%s' '界'
    remaining=$((remaining - 1))
done
exit 0
