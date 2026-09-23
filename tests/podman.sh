#!/bin/sh
set -eu

image=${IMAGE:-psotnic:test}
name="psotnic-podman-test-$$"
tmp=$(mktemp -d)

cleanup() {
  podman rm -f "$name" >/dev/null 2>&1 || true
  rm -rf "$tmp"
}
trap cleanup EXIT INT TERM

# Rootless Podman must remain rootless for this qualification.
test "$(id -u)" -ne 0
podman info --format '{{.Host.Security.Rootless}}' | grep -qx true

mkdir -p "$tmp/data"
chmod 0777 "$tmp/data"

podman run -d --name "$name"   -v "$tmp/data:/data"   "$image" >/dev/null

sleep 2

test "$(podman inspect --format '{{.State.Running}}' "$name")" = true
podman exec "$name" sh -eu -c '
  test "$(id -u)" = 1000
  test "$(id -g)" = 1000
  test "$PWD" = /data
  test "$PSOTNIC_CONFIG" = /data/psotnic.conf
  printf "%s\n" "rootless-podman" > /data/podman.marker
  /usr/local/bin/healthcheck
'

test "$(cat "$tmp/data/podman.marker")" = "rootless-podman"

echo "rootless Podman qualification: PASS"
