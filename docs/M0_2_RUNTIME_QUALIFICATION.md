# M0.2 Runtime Qualification

## Scope

M0.2 qualifies the Psotnic container runtime contract after the initial v0.1.0 release. It intentionally separates properties that can be enforced in CI from properties that require inspection of a published multi-architecture image or a real Podman/systemd environment.

## Baseline

- Packaging version: `0.1.0`
- Upstream Psotnic: `0.2.14`
- Upstream commit: `b598a8dc25686e2785fb0f9970103cb6a39cdaa6`
- Runtime base: Alpine Linux 3.22
- Runtime user: `1000:1000`
- Persistent working directory: `/data`
- Default configuration: `/data/psotnic.conf`

The existing GitHub Actions container workflow builds the test image and runs static and smoke gates before publication. The release workflow publishes `linux/amd64` and `linux/arm64` images with SBOM and provenance attestations.

## Automated qualification gate

Run locally with:

```sh
docker build -t psotnic:test .
IMAGE=psotnic:test sh tests/runtime.sh
```

The gate verifies:

- effective UID/GID is `1000:1000`;
- `/data` is the working directory;
- `PSOTNIC_CONFIG` defaults to `/data/psotnic.conf`;
- Psotnic, entrypoint, and healthcheck executables are installed;
- the non-root process can write through a persistent `/data` bind mount;
- missing configuration enters the documented healthy idle state;
- the idle container survives a stop/start lifecycle and becomes healthy again;
- a present invalid configuration does not silently qualify as healthy idle.

## Published-image qualification

For a stable release, additionally inspect the published image:

```sh
docker buildx imagetools inspect ghcr.io/ploos-as/psotnic:0.1.0
docker buildx imagetools inspect ghcr.io/ploos-as/psotnic:0.1
docker buildx imagetools inspect ghcr.io/ploos-as/psotnic:latest
```

Acceptance criteria:

- `0.1.0`, `0.1`, and `latest` resolve successfully;
- the stable image index contains `linux/amd64` and `linux/arm64` runtime manifests;
- the three stable aliases represent the intended v0.1.0 release;
- published artifacts include the workflow-requested SBOM and provenance attestations.

These checks concern registry state and are not inferred solely from repository source.

## Podman / Quadlet qualification

A real rootless Podman + systemd user environment is required for this portion. Install `quadlet/psotnic.container`, create its data directory, reload the user systemd manager, and start the unit.

Acceptance criteria:

- unit starts rootless;
- missing configuration remains healthy/idle rather than crash-looping;
- `/data` persists across restart;
- stop/start/restart work through systemd;
- runtime remains UID/GID 1000:1000 inside the container;
- no additional Linux capabilities or privilege escalation are introduced by the deployment definition.

## Status

Repository/CI qualification: **implemented**.

Published registry and real-host Quadlet checks remain environment-dependent qualification steps. They must be recorded from actual execution rather than claimed from static source inspection.

M0.2 is complete as a repeatable qualification framework when the automated runtime gate is green in CI. A release may be marked fully runtime-qualified after the published-image and rootless Quadlet acceptance criteria have also been observed on their target environments.
