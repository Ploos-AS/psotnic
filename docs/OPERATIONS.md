# Operations and troubleshooting

This guide covers the Ploos AS Psotnic container packaging. Psotnic-specific IRC and botnet configuration remains an upstream concern.

## Basic status

With Compose:

```sh
docker compose ps
docker compose logs --tail=100 psotnic
```

For a standalone container:

```sh
docker inspect --format '{{.State.Status}} {{.State.Health.Status}}' psotnic
docker logs --tail=100 psotnic
```

The image includes `/usr/local/bin/healthcheck`. A container with no configuration is intentionally allowed to remain in a healthy idle state so configuration can be mounted or generated separately. A present but invalid configuration is not treated as healthy idle.

## Persistent data

All persistent configuration and state belongs under `/data`. The normal runtime identity is UID/GID `1000:1000`.

Check ownership without printing secret configuration:

```sh
docker exec psotnic sh -c 'id && ls -ld /data'
```

Do not dump `psotnic.conf` into CI output, support tickets, or public logs.

If writes fail after moving or restoring a volume, verify numeric ownership. Do not solve routine permission problems by running the bot as root.

## Configuration problems

The configured path defaults to:

```text
/data/psotnic.conf
```

It can be changed with `PSOTNIC_CONFIG`.

If the file does not exist, the container remains idle. If it exists and Psotnic exits, inspect the container logs and validate the configuration using the same image version before changing runtime security settings.

## Networking

The default packaging publishes no ports. Outbound IRC connections normally require no published Docker port.

Only publish a listener/partyline port when the Psotnic configuration explicitly requires one. Restrict exposure with the host firewall and deployment network policy.

## Resource limits

Psotnic itself is lightweight, but explicit limits help small VPS and appliance deployments avoid one service affecting the host.

Example Compose fragment:

```yaml
services:
  psotnic:
    image: ghcr.io/ploos-as/psotnic:0.1.1
    mem_limit: 128m
    cpus: 0.50
    pids_limit: 128
```

Treat these as starting points, not universal requirements. Observe the actual deployment before tightening them.

## Backup and recovery

Use `docs/BACKUP_RESTORE.md`. Stop the bot before a consistency-sensitive backup and restore only into a new or empty target volume.

## Upgrade problems

Use `docs/UPGRADE_ROLLBACK.md`. Keep the previous exact image and a pre-upgrade backup until the new deployment is verified.

CI qualifies persistence across container recreation and the supported stable-to-development upgrade/rollback path, but it cannot validate a site's IRC network policy, credentials, or bot topology.

## Useful diagnostics

Collect metadata rather than secrets:

```sh
docker inspect psotnic
docker logs --tail=200 psotnic
docker image inspect ghcr.io/ploos-as/psotnic:0.1.1
```

Before sharing diagnostics, review them for environment variables, mount paths, hostnames, IP addresses, credentials, channel names, and other deployment-sensitive information.
