# M0.3 Supply-chain hardening and reproducibility

## Scope

M0.3 reduces avoidable mutable inputs in the container build and CI path. The goal is deterministic source selection and auditable automation, while remaining honest about inputs that are not yet bit-for-bit reproducible.

## Controlled inputs

The container build now fixes the Alpine base to patch release `3.22.5` instead of the floating `3.22` minor tag.

Upstream Psotnic remains pinned to commit:

`b598a8dc25686e2785fb0f9970103cb6a39cdaa6`

The build verifies that the checked-out upstream repository resolves to that exact commit before compilation.

All third-party GitHub Actions used by the container workflow are pinned to immutable 40-character commit SHAs. Human-readable major-version comments are retained beside the pins for maintainability.

## CI enforcement

`tests/static.sh` enforces:

- the exact Alpine patch release;
- the pinned upstream Psotnic commit;
- immutable SHA pinning for every reusable Action in the container workflow;
- multi-architecture publication targets;
- SBOM and provenance generation;
- existing runtime/deployment contracts.

This prevents a future change from silently returning the workflow to floating Action tags.

## Reproducibility boundary

M0.3 does not claim bit-for-bit reproducible images. Alpine package repositories and package revisions used by `apk add` remain external mutable inputs, and the Alpine tag itself is a human-readable release selector rather than a registry digest pin.

For that reason the current guarantee is **controlled and auditable build inputs**, not byte-identical rebuilds forever.

A later milestone may tighten this further by pinning the Alpine manifest-list digest and, where operationally useful, package revisions or a package-repository snapshot.

## Action pins

At qualification time the workflow uses these immutable commits:

- `actions/checkout`: `fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09` (`v5`)
- `docker/setup-buildx-action`: `8d2750c68a42422c14e847fe6c8ac0403b4cbd6f` (`v3`)
- `docker/setup-qemu-action`: `c7c53464625b32c7a7e944ae62b3e17d2b600130` (`v3`)
- `docker/login-action`: `c94ce9fb468520275223c153574b00df6fe4bcc9` (`v3`)
- `docker/metadata-action`: `c299e40c65443455700f0fdfc63efafe5b349051` (`v5`)
- `docker/build-push-action`: `10e90e3645eae34f1e60eeb005ba3a3d33f178e8` (`v6`)

## Acceptance

M0.3 is complete when the final `main` workflow passes static validation, image build, smoke test, runtime qualification, and publication using these pins.
