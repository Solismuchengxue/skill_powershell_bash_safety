#!/bin/sh
set -eu

[ "$#" -ge 4 ] || exit 92
[ "$1" = '-S' ] || exit 92
[ "$2" = '-p' ] || exit 92
[ "$3" = '' ] || exit 92
[ "$4" = '--' ] || exit 92
shift 4

[ "$#" -ge 5 ] || exit 95
status_path=$5
[ -f "$status_path" ] || exit 96
[ -w "$status_path" ] || exit 97

IFS= read -r synthetic_input || exit 93
[ -n "$synthetic_input" ] || exit 94
synthetic_input=''
exec "$@"
