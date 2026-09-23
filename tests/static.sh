#!/bin/sh
set -eu

version=$(cat VERSION)
printf '%s\n' "$version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$'
test "$version" = '0.2.0'

test -f Dockerfile
test -f compose.yaml
test -f quadlet/psotnic.container
test -f NOTICE
test -f LICENSE
test -f docs/releases/v0.1.0.md
test -f docs/releases/v0.1.1.md
test -f docs/releases/v0.2.0.md
test -f docs/M0_2_RUNTIME_QUALIFICATION.md
test -f docs/M0_3_SUPPLY_CHAIN.md
test -f docs/M0_4_DEPLOYMENT_HARDENING.md
test -f docs/M0_5_PUBLISHED_ARTIFACT_VERIFICATION.md
test -f docs/M0_6_IMAGE_CONTRACT.md
test -f docs/M0_7_RELEASE_REGISTRY_INTEGRITY.md
test -f tests/deployment-hardening.sh
test -f tests/published-artifact.sh
test -f tests/image-contract.sh
test -f tests/release-integrity.sh
test -f examples/multi-bot/compose.yaml
test -f examples/multi-bot/README.md
test -f scripts/backup-data.sh
test -f scripts/restore-data.sh
test -f tests/backup-restore.sh
test -f docs/BACKUP_RESTORE.md
test -f docs/UPGRADE_ROLLBACK.md
test -f docs/OPERATIONS.md
test -f docs/PREFLIGHT.md
test -f scripts/preflight.sh
test -f tests/preflight.sh
test -f tests/persistence-recreate.sh
test -f tests/upgrade-rollback.sh
test -f tests/podman.sh

grep -q '^ARG ALPINE_VERSION=3\.22\.5$' Dockerfile
grep -q 'b598a8dc25686e2785fb0f9970103cb6a39cdaa6' Dockerfile
grep -q '^ARG CONTAINER_VERSION=0\.2\.0$' Dockerfile
grep -q 'USER 1000:1000' Dockerfile
grep -q 'ghcr.io/ploos-as/psotnic:0.2.0' compose.yaml
grep -q 'ghcr.io/ploos-as/psotnic:0.2.0' quadlet/psotnic.container
grep -q 'linux/amd64,linux/arm64' .github/workflows/container.yml
grep -q 'provenance: mode=max' .github/workflows/container.yml
grep -q 'sbom: true' .github/workflows/container.yml
grep -q 'Published artifact verification' .github/workflows/container.yml
grep -q 'steps.publish.outputs.digest' .github/workflows/container.yml
grep -q 'Image contract qualification' .github/workflows/container.yml
grep -q 'tests/image-contract.sh' .github/workflows/container.yml
grep -q 'Release registry integrity' .github/workflows/container.yml
grep -q 'tests/release-integrity.sh' .github/workflows/container.yml

# All reusable third-party Actions must be pinned to immutable 40-hex commits.
if grep -E '^[[:space:]]*-[[:space:]]+uses:' .github/workflows/container.yml \
  | grep -Ev 'uses: [^@[:space:]]+@[0-9a-f]{40}([[:space:]]+#.*)?$' >/dev/null; then
  echo 'unpinned GitHub Action detected' >&2
  exit 1
fi

sh tests/deployment-hardening.sh
sh tests/preflight.sh
sh tests/backup-restore.sh
docker compose config --quiet
docker compose -f examples/multi-bot/compose.yaml config --quiet

# Multi-bot example must keep each role isolated and hardened.
for service in main slave leaf; do
  docker compose -f examples/multi-bot/compose.yaml config --format json \
    | jq -e --arg service "$service" '.services[$service].user == "1000:1000"' >/dev/null
  docker compose -f examples/multi-bot/compose.yaml config --format json \
    | jq -e --arg service "$service" '.services[$service].cap_drop == ["ALL"]' >/dev/null
  docker compose -f examples/multi-bot/compose.yaml config --format json \
    | jq -e --arg service "$service" '.services[$service].security_opt | index("no-new-privileges:true") != null' >/dev/null
done
