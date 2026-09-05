# M0.5 — Published artifact verification

## Goal

Qualify the artifact that was actually pushed to GHCR, rather than treating a successful build/push step as sufficient evidence.

## Verification contract

`tests/published-artifact.sh` receives an immutable digest reference through `IMAGE` and verifies the published OCI index with `docker buildx imagetools inspect`.

The gate requires:

- a published `linux/amd64` runtime manifest;
- a published `linux/arm64` runtime manifest;
- at least two BuildKit attestation manifests in the OCI index;
- non-empty SLSA provenance for `linux/amd64` and `linux/arm64`;
- non-empty SPDX SBOM data for `linux/amd64` and `linux/arm64`.

The workflow passes the exact digest emitted by `docker/build-push-action`:

```text
ghcr.io/ploos-as/psotnic@${{ steps.publish.outputs.digest }}
```

This avoids qualifying a mutable tag that could theoretically move between publication and inspection.

## Workflow coverage

The verification runs immediately after publication in both publishing paths:

- `main` / version tag publication;
- `release/v*` release-candidate publication.

A failure in artifact inspection fails the publishing job.

## Scope boundary

M0.5 verifies presence and accessibility of the expected platform manifests and BuildKit-generated SBOM/provenance attestations. It does not independently validate the semantic correctness of every SBOM package entry or every provenance material. Those remain candidates for a later policy milestone.

## Acceptance

M0.5 is complete when the final `main` workflow succeeds with the new post-publish verification enabled.
