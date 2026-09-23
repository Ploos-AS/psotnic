#!/bin/sh
set -eu

archive=${1:?usage: restore-data.sh BACKUP.tar.gz [VOLUME]}
volume=${2:-psotnic-data}

case "$archive" in
  /*) ;;
  *) archive="$(pwd)/$archive" ;;
esac

test -f "$archive"
archive_dir=$(dirname "$archive")
archive_file=$(basename "$archive")

docker volume create "$volume" >/dev/null

# Refuse to merge a restore into an existing non-empty data volume.
if docker run --rm -v "$volume:/data:ro" alpine:3.22.5 \
  sh -c 'test -z "$(find /data -mindepth 1 -maxdepth 1 -print -quit)"'; then
  :
else
  echo "refusing to restore into non-empty volume: $volume" >&2
  exit 1
fi

docker run --rm \
  -v "$volume:/data" \
  -v "$archive_dir:/backup:ro" \
  alpine:3.22.5 \
  tar -C /data -xzf "/backup/$archive_file"

printf 'Backup restored into volume %s\n' "$volume"
