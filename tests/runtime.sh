#!/bin/sh
set -eu

image=${IMAGE:-psotnic:test}

tmp=$(mktemp -d)
cleanup() {
  docker rm -f psotnic-runtime-test >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT INT TERM

# Runtime identity and filesystem contract.
docker run --rm --entrypoint sh "$image" -c '
  test "$(id -u)" = 1000
  test "$(id -g)" = 1000
  test "$PWD" = /data
  test "$PSOTNIC_CONFIG" = /data/psotnic.conf
  test -x /usr/local/bin/psotnic
  test -x /usr/local/bin/entrypoint
  test -x /usr/local/bin/healthcheck
'

# A writable persistent /data mount must work for the non-root runtime user.
mkdir -p "$tmp/data"
chmod 0777 "$tmp/data"
docker run --rm \
  -v "$tmp/data:/data" \
  --entrypoint sh \
  "$image" \
  -c 'printf qualified > /data/runtime-write-test && test -s /data/runtime-write-test'
test "$(cat "$tmp/data/runtime-write-test")" = qualified

# Missing configuration is an intentional healthy idle state.
docker run -d --name psotnic-runtime-test "$image" >/dev/null
sleep 2
test "$(docker inspect --format '{{.State.Running}}' psotnic-runtime-test)" = true
docker exec psotnic-runtime-test /usr/local/bin/healthcheck

docker stop psotnic-runtime-test >/dev/null
test "$(docker inspect --format '{{.State.Running}}' psotnic-runtime-test)" = false
docker start psotnic-runtime-test >/dev/null
sleep 2
test "$(docker inspect --format '{{.State.Running}}' psotnic-runtime-test)" = true
docker exec psotnic-runtime-test /usr/local/bin/healthcheck

docker rm -f psotnic-runtime-test >/dev/null

# A present but invalid configuration must not be reported as healthy idle.
printf 'this is not a valid psotnic configuration\n' > "$tmp/data/psotnic.conf"
set +e
docker run --rm \
  -v "$tmp/data:/data" \
  "$image" >/dev/null 2>&1
rc=$?
set -e
test "$rc" -ne 0

printf '%s\n' 'runtime qualification: PASS'
