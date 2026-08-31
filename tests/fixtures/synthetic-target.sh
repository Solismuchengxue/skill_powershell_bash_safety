#!/bin/sh
set -eu

if IFS= read -r unexpected_input; then
    printf '%s\n' 'target inherited stdin unexpectedly' >&2
    exit 91
fi

printf '%s' 'synthetic target output'
printf '%s' 'synthetic target error' >&2
exit 7
