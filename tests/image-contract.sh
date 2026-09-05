#!/bin/sh
set -eu

IMAGE=${IMAGE:-psotnic:test}

expect_eq() {
  name=$1
  expected=$2
  actual=$3
  if [ "$actual" != "$expected" ]; then
    printf '%s: expected %s, got %s\n' "$name" "$expected" "$actual" >&2
    exit 1
  fi
}

expect_eq user '1000:1000' "$(docker image inspect --format '{{.Config.User}}' "$IMAGE")"
expect_eq workdir '/data' "$(docker image inspect --format '{{.Config.WorkingDir}}' "$IMAGE")"
expect_eq entrypoint '/sbin/tini|--|/usr/local/bin/entrypoint' "$(docker image inspect --format '{{join .Config.Entrypoint "|"}}' "$IMAGE")"
expect_eq healthcheck 'CMD|/usr/local/bin/healthcheck' "$(docker image inspect --format '{{join .Config.Healthcheck.Test "|"}}' "$IMAGE")"
expect_eq volume-data 'present' "$(docker image inspect --format '{{if index .Config.Volumes "/data"}}present{{else}}missing{{end}}' "$IMAGE")"

if ! docker image inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$IMAGE" | grep -qx 'PSOTNIC_CONFIG=/data/psotnic.conf'; then
  echo 'PSOTNIC_CONFIG image contract missing' >&2
  exit 1
fi

expect_eq title 'Psotnic' "$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.title"}}' "$IMAGE")"
expect_eq source 'https://github.com/Ploos-AS/psotnic' "$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.source"}}' "$IMAGE")"
expect_eq license 'MIT AND GPL-2.0-or-later' "$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.licenses"}}' "$IMAGE")"
expect_eq upstream-version '0.2.14' "$(docker image inspect --format '{{index .Config.Labels "io.ploos.upstream.version"}}' "$IMAGE")"
expect_eq upstream-revision 'b598a8dc25686e2785fb0f9970103cb6a39cdaa6' "$(docker image inspect --format '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$IMAGE")"

printf '%s\n' 'image contract: PASS'
