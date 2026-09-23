#!/bin/sh
set -eu

config=${1:-${PSOTNIC_CONFIG:-/data/psotnic.conf}}
failed=0

fail() {
  printf 'preflight: FAIL: %s\n' "$*" >&2
  failed=1
}

test -n "$config" || fail "configuration path is empty"

if [ ! -e "$config" ]; then
  fail "configuration does not exist: $config"
elif [ ! -f "$config" ]; then
  fail "configuration is not a regular file: $config"
else
  [ -r "$config" ] || fail "configuration is not readable: $config"
  [ -s "$config" ] || fail "configuration is empty: $config"
fi

data_dir=$(dirname "$config")
if [ ! -d "$data_dir" ]; then
  fail "configuration directory does not exist: $data_dir"
elif [ ! -x "$data_dir" ]; then
  fail "configuration directory is not searchable: $data_dir"
fi

if [ "$failed" -ne 0 ]; then
  exit 1
fi

printf 'preflight: PASS: %s\n' "$config"
