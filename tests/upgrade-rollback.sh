#!/bin/sh
set -eu

old_image=${OLD_IMAGE:-ghcr.io/ploos-as/psotnic:0.1.1}
new_image=${NEW_IMAGE:-psotnic:test}
volume="psotnic-upgrade-test-$$"
name="psotnic-upgrade-test-$$"

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  docker volume rm -f "$volume" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

docker volume create "$volume" >/dev/null

# Model existing qualified persistent data owned by the runtime account.
docker run --rm -v "$volume:/data" alpine:3.22.5 sh -eu -c '
  printf "%s\n" "pre-upgrade-state" > /data/upgrade.marker
  chown -R 1000:1000 /data
'

run_and_verify() {
  image=$1
  expected=$2

  docker run -d --name "$name" -v "$volume:/data" "$image" >/dev/null
  sleep 2
  test "$(docker inspect --format '{{.State.Running}}' "$name")" = true
  docker exec "$name" /usr/local/bin/healthcheck
  docker exec "$name" sh -eu -c "
    test \"\$(cat /data/upgrade.marker)\" = \"$expected\"
    test \"\$(stat -c %u:%g /data/upgrade.marker)\" = \"1000:1000\"
  "
}

# Establish the old-version baseline.
run_and_verify "$old_image" "pre-upgrade-state"
docker rm -f "$name" >/dev/null

# Upgrade while retaining the exact same persistent volume.
run_and_verify "$new_image" "pre-upgrade-state"
docker exec "$name" sh -eu -c '
  printf "%s\n" "state-survived-upgrade" > /data/upgrade.marker
'
docker rm -f "$name" >/dev/null

# Roll back the image without replacing the persistent volume.
run_and_verify "$old_image" "state-survived-upgrade"
docker rm -f "$name" >/dev/null

echo "upgrade/rollback regression: PASS"
