#!/bin/sh
set -eu

src="psotnic-backup-test-src-$$"
dst="psotnic-backup-test-dst-$$"
archive="$(pwd)/psotnic-backup-test-$$.tar.gz"

cleanup() {
  docker volume rm -f "$src" "$dst" >/dev/null 2>&1 || true
  rm -f "$archive"
}
trap cleanup EXIT INT TERM

docker volume create "$src" >/dev/null

docker run --rm -v "$src:/data" alpine:3.22.5 sh -eu -c '
  mkdir -p /data/state
  printf "%s\n" "test-config" > /data/psotnic.conf
  printf "%s\n" "persistent-state" > /data/state/example
'

sh scripts/backup-data.sh "$src" "$archive"
test -s "$archive"

sh scripts/restore-data.sh "$archive" "$dst"

docker run --rm -v "$dst:/data:ro" alpine:3.22.5 sh -eu -c '
  test "$(cat /data/psotnic.conf)" = "test-config"
  test "$(cat /data/state/example)" = "persistent-state"
'

# A second restore into the now non-empty destination must fail.
if sh scripts/restore-data.sh "$archive" "$dst"; then
  echo "restore unexpectedly accepted a non-empty destination" >&2
  exit 1
fi

echo "backup/restore regression: PASS"
