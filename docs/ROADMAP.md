# Psotnic container roadmap

This roadmap tracks the Ploos AS OCI packaging of upstream Psotnic. Upstream Psotnic functionality remains upstream; this repository focuses on reproducible, secure, low-maintenance container deployment.

## v0.1.x — maintenance

- Keep Alpine as the primary runtime and builder base while it remains compatible with upstream Psotnic.
- Track supported Alpine patch releases deliberately rather than following a moving tag.
- Review Dependabot updates for GitHub Actions and container dependencies.
- Keep amd64 and arm64 release qualification green.
- Preserve non-root execution, dropped capabilities, no-new-privileges, healthcheck, SBOM, and provenance.
- Keep pinned upstream source revision and document every upstream bump.

## v0.2.0 — deployment and operations

- Add documented multi-bot examples for main, slave, and leaf roles.
- Add backup and restore procedure for /data.
- Add upgrade and rollback documentation.
- Add configuration validation/preflight where it can be done without changing upstream behavior.
- Improve observability documentation and operational troubleshooting.
- Add explicit resource-limit examples for small VPS and homelab deployments.
- Qualify rootless Podman deployment alongside Docker/Compose.
- Extend CI with upgrade/persistence regression tests.

## Later

- Evaluate additional architectures only where upstream and CI can be qualified reliably.
- Evaluate automated upstream release/commit monitoring without automatically consuming unqualified source.
- Coordinate reusable IRC-container conventions with other Ploos AS IRC projects where this reduces maintenance without hiding application-specific behavior.

## Non-goals

- Forking or reimplementing Psotnic.
- Shipping credentials or production configuration in the image.
- Exposing partyline/listener ports by default.
- Adding unnecessary services or packages to the runtime image.
- Replacing Alpine unless compatibility or maintainability provides a concrete reason.
