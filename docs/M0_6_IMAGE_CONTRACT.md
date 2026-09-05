# M0.6 — Image contract qualification

M0.6 turns the built OCI image configuration into an explicit CI-enforced contract.

## Qualified contract

The test image must expose all of the following properties:

- runtime user: `1000:1000`
- working directory: `/data`
- entrypoint: `/sbin/tini -- /usr/local/bin/entrypoint`
- healthcheck command: `/usr/local/bin/healthcheck`
- persistent volume declaration: `/data`
- environment: `PSOTNIC_CONFIG=/data/psotnic.conf`
- OCI title: `Psotnic`
- OCI source: `https://github.com/Ploos-AS/psotnic`
- OCI license expression: `MIT AND GPL-2.0-or-later`
- upstream Psotnic version: `0.2.14`
- upstream revision: `b598a8dc25686e2785fb0f9970103cb6a39cdaa6`

## Automated gate

`tests/image-contract.sh` inspects the image built by CI with `docker image inspect` and fails if any contract property changes unexpectedly.

The `test` job runs this gate immediately after the local amd64 test image is built and before smoke/runtime qualification:

```sh
IMAGE=psotnic:test sh tests/image-contract.sh
```

This complements, rather than replaces, the existing gates:

- static repository validation
- deployment hardening validation
- smoke testing
- runtime qualification
- published multiarch/SBOM/provenance verification

## Scope boundary

M0.6 qualifies the OCI image configuration produced from the repository. It does not make the build bit-for-bit reproducible; Alpine repository/package revisions remain external inputs as documented in M0.3.

## Status

Repository implementation and CI enforcement are complete once the final `main` workflow for this milestone succeeds.
