# M0.4 Deployment Hardening

## Scope

M0.4 turns the Docker Compose and Podman Quadlet deployment examples into an explicit, CI-enforced security contract.

The application image already runs as UID/GID `1000:1000`. M0.4 also declares that identity at the deployment layer so later image or deployment changes cannot silently broaden privileges.

## Required deployment properties

Both supported deployment definitions must preserve these properties:

- runtime identity is explicitly `1000:1000`;
- no new privileges are allowed;
- all Linux capabilities are dropped;
- privileged mode is not enabled;
- host networking is not enabled;
- host PID/IPC namespaces are not enabled;
- Docker or Podman control sockets are not mounted into the container;
- `/data` remains the only documented persistent application data location.

Compose expresses the principal controls with:

```yaml
user: "1000:1000"
security_opt:
  - no-new-privileges:true
cap_drop:
  - ALL
```

Quadlet expresses the equivalent controls with:

```ini
User=1000:1000
DropCapability=all
NoNewPrivileges=true
```

## Automated gate

Run:

```sh
sh tests/deployment-hardening.sh
```

The static CI gate invokes this test automatically. It checks the required security settings and rejects known privilege-expanding deployment settings or container-engine socket mounts.

The Compose file is additionally parsed with `docker compose config --quiet` by the existing static gate.

## Runtime qualification boundary

Static validation proves the repository deployment definitions retain the intended hardening contract. It does not replace a real rootless Podman/systemd runtime qualification.

For full host qualification, the Quadlet unit should still be exercised under a non-root systemd user session and verified to start, stop, restart, persist `/data`, and remain UID/GID `1000:1000` inside the container.

## Status

Repository deployment hardening: **implemented and CI-enforced**.

Real-host rootless Quadlet execution remains an environment-dependent runtime qualification step rather than a claim inferred from source inspection.
