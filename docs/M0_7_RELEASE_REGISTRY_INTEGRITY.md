# M0.7 — Release / registry integrity

## Goal

Qualify the stable release aliases published to GHCR, not only the immutable image digest produced by BuildKit.

A stable release is accepted only when all intended aliases resolve to the exact digest emitted by the publish step.

## Gate

`tests/release-integrity.sh` requires:

- `EXPECTED_DIGEST` from the image publication step
- the full release tag (`X.Y.Z`) to resolve to that digest
- the minor release tag (`X.Y`) to resolve to that digest
- `latest` to resolve to that digest

The default registry repository is `ghcr.io/ploos-as/psotnic`.

## CI integration

The gate runs after published-artifact verification for:

1. Git tag releases (`vX.Y.Z`)
2. `release/vX.Y.Z` candidate branches

The tag release derives `VERSION` from `GITHUB_REF_NAME`. The release-candidate path uses the version and minor outputs already validated against `VERSION`.

## Release immutability

M0.7 does not move or rebuild existing historical release tags. In particular, the existing `v0.1.0` remains immutable. The next stable packaging release should therefore use a new version, expected to be `v0.1.1`.

## Acceptance

M0.7 is accepted when the final `main` workflow succeeds with the new static gate in place. The registry alias checks themselves are exercised on the next release-candidate or tag publication.
