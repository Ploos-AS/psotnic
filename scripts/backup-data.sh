#!/bin/sh
set -eu

volume=${1:-psotnic-data}
output=${2:-psotnic-data-backup.tar.gz}

case "$output" in
  /*) ;;
  *) output="$(pwd)/$output" ;;
esac

outdir=$(dirname "$output")
outfile=$(basename "$output")
mkdir -p "$outdir"

docker run --rm \
  -v "$volume:/data:ro" \
  -v "$outdir:/backup" \
  alpine:3.22.5 \
  tar -C /data -czf "/backup/$outfile" .

printf 'Backup written to %s\n' "$output"
