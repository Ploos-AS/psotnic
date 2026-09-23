#!/bin/sh
set -eu

tmp=$(mktemp -d)
cleanup() { rm -rf "$tmp"; }
trap cleanup EXIT INT TERM

config="$tmp/psotnic.conf"

# Missing configuration must fail.
if sh scripts/preflight.sh "$config" >/dev/null 2>&1; then
  echo "preflight unexpectedly accepted missing configuration" >&2
  exit 1
fi

# Empty configuration must fail.
: > "$config"
if sh scripts/preflight.sh "$config" >/dev/null 2>&1; then
  echo "preflight unexpectedly accepted empty configuration" >&2
  exit 1
fi

# Non-empty readable configuration passes structural preflight. This deliberately
# does not claim that Psotnic accepts the configuration syntax or semantics.
printf '%s\n' 'preflight-placeholder' > "$config"
sh scripts/preflight.sh "$config" >/dev/null

# A directory is not a configuration file.
mkdir "$tmp/not-a-file"
if sh scripts/preflight.sh "$tmp/not-a-file" >/dev/null 2>&1; then
  echo "preflight unexpectedly accepted a directory" >&2
  exit 1
fi

echo "configuration preflight regression: PASS"
