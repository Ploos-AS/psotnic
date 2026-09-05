#!/bin/sh
set -eu

IMAGE_REPO=${IMAGE_REPO:-ghcr.io/ploos-as/psotnic}
VERSION=${VERSION:-$(cat VERSION)}
MINOR=${MINOR:-${VERSION%.*}}
EXPECTED_DIGEST=${EXPECTED_DIGEST:-}

if [ -z "$EXPECTED_DIGEST" ]; then
  echo 'EXPECTED_DIGEST is required' >&2
  exit 1
fi

command -v docker >/dev/null 2>&1

resolve_digest() {
  docker buildx imagetools inspect "$1" --format '{{json .Manifest.Digest}}' \
    | tr -d '"'
}

for tag in "$VERSION" "$MINOR" latest; do
  ref="$IMAGE_REPO:$tag"
  digest=$(resolve_digest "$ref")
  if [ "$digest" != "$EXPECTED_DIGEST" ]; then
    echo "$ref resolved to $digest, expected $EXPECTED_DIGEST" >&2
    exit 1
  fi
done

echo 'release registry integrity: PASS'
