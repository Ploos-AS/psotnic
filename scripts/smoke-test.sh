#!/bin/sh
set -eu

image=${IMAGE:-psotnic:test}

docker run --rm --entrypoint sh "$image" -c 'test "$(id -u)" = 1000 && test "$(id -g)" = 1000'
docker run --rm --entrypoint /usr/local/bin/psotnic "$image" 2>&1 | grep -qi 'psotnic\|usage\|config' || true
cid=$(docker run -d "$image")
trap 'docker rm -f "$cid" >/dev/null 2>&1 || true' EXIT
sleep 2
docker inspect --format '{{.State.Running}}' "$cid" | grep -qx true
docker exec "$cid" /usr/local/bin/healthcheck
