#!/bin/sh
set -eu

image=${IMAGE:-psotnic:test}
volume="psotnic-persistence-test-$$"
first="psotnic-persistence-first-$$"
second="psotnic-persistence-second-$$"

cleanup() {
  docker rm -f "$first" "$second" >/dev/null 2>&1 || true
  docker volume rm -f "$volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

docker volume create "$volume" >/dev/null

# Seed persistent state independently of the image.
docker run --rm -v "$volume:/data" alpine:3.22.5 sh -eu -c '
  printf "%s\n" "persistence-marker" > /data/persistence.marker
'

# First container generation.
docker run -d --name "$first" -v "$volume:/data" "$image" >/dev/null
sleep 2
docker exec "$first" sh -eu -c '
  test "$(cat /data/persistence.marker)" = "persistence-marker"
  printf "%s\n" "created-by-first-generation" > /data/recreate.marker
'
docker rm -f "$first" >/dev/null

# Recreate from the same image while retaining the volume.
docker run -d --name "$second" -v "$volume:/data" "$image" >/dev/null
sleep 2
docker exec "$second" sh -eu -c '
  test "$(cat /data/persistence.marker)" = "persistence-marker"
  test "$(cat /data/recreate.marker)" = "created-by-first-generation"
'

echo "persistence/recreate regression: PASS"
