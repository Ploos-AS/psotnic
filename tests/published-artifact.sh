#!/bin/sh
set -eu

IMAGE=${IMAGE:-}
if [ -z "$IMAGE" ]; then
  echo 'IMAGE must reference a published image, preferably by digest' >&2
  exit 1
fi

command -v docker >/dev/null 2>&1
command -v python3 >/dev/null 2>&1

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

docker buildx imagetools inspect --raw "$IMAGE" > "$tmp/index.json"

python3 - "$tmp/index.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    index = json.load(f)

manifests = index.get("manifests", [])
platforms = {
    (m.get("platform") or {}).get("os", "") + "/" + (m.get("platform") or {}).get("architecture", "")
    for m in manifests
}

required = {"linux/amd64", "linux/arm64"}
missing = sorted(required - platforms)
if missing:
    raise SystemExit("missing runtime platform(s): " + ", ".join(missing))

attestations = [
    m for m in manifests
    if (m.get("annotations") or {}).get("vnd.docker.reference.type") == "attestation-manifest"
]
if len(attestations) < 2:
    raise SystemExit(f"expected at least 2 attestation manifests, found {len(attestations)}")

print("manifest index: PASS")
PY

for platform in linux/amd64 linux/arm64; do
  provenance=$(docker buildx imagetools inspect "$IMAGE" \
    --format "{{ json (index .Provenance \"$platform\").SLSA }}")
  case "$provenance" in
    ''|'null'|'{}')
      echo "missing provenance for $platform" >&2
      exit 1
      ;;
  esac

  sbom=$(docker buildx imagetools inspect "$IMAGE" \
    --format "{{ json (index .SBOM \"$platform\").SPDX }}")
  case "$sbom" in
    ''|'null'|'{}')
      echo "missing SBOM for $platform" >&2
      exit 1
      ;;
  esac

done

echo 'published artifact verification: PASS'
