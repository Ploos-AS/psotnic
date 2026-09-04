#!/bin/sh
set -eu

version=$(cat VERSION)
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'

test -f Dockerfile
test -f compose.yaml
test -f quadlet/psotnic.container
test -f NOTICE
test -f LICENSE
test -f docs/releases/v0.1.0.md

grep -q 'b598a8dc25686e2785fb0f9970103cb6a39cdaa6' Dockerfile
grep -q 'USER 1000:1000' Dockerfile
grep -q 'ghcr.io/ploos-as/psotnic:0.1.0' compose.yaml
grep -q 'ghcr.io/ploos-as/psotnic:0.1.0' quadlet/psotnic.container
grep -q 'linux/amd64,linux/arm64' .github/workflows/container.yml
grep -q 'provenance: mode=max' .github/workflows/container.yml
grep -q 'sbom: true' .github/workflows/container.yml

docker compose config --quiet
