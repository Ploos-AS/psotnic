# Psotnic container

Production-oriented OCI packaging of upstream [Psotnic](https://github.com/psotnic/psotnic), maintained by Ploos AS.

This image pins upstream Psotnic **0.2.14** at commit `b598a8dc25686e2785fb0f9970103cb6a39cdaa6`. The Ploos AS container version is **0.1.0**.

Psotnic is an IRC channel-protection bot designed around coordinated botnets and channel administration. Use it only on IRC networks and channels where you are authorized to run it.

## Image

```sh
docker pull ghcr.io/ploos-as/psotnic:0.1.0
```

Release images target `linux/amd64` and `linux/arm64`.

## Runtime model

The container runs as UID/GID `1000:1000`, uses `/data` as its persistent working directory, and defaults to:

```text
PSOTNIC_CONFIG=/data/psotnic.conf
```

If no configuration exists, the container deliberately stays in a healthy idle state rather than crash-looping.

## First-run configuration

Upstream Psotnic provides an interactive configuration generator. With Docker:

```sh
docker volume create psotnic-data

docker run --rm -it \
  -v psotnic-data:/data \
  ghcr.io/ploos-as/psotnic:0.1.0 -n
```

Ensure the resulting configuration is available as `/data/psotnic.conf`, or set `PSOTNIC_CONFIG` to another file under `/data`.

Psotnic supports main, slave, and leaf bot roles. For multi-bot deployments, create a separate persistent data directory or volume for each bot instance.

## Docker Compose

```sh
docker compose up -d
```

`compose.yaml` uses the exact stable image tag, a named persistent volume, no-new-privileges, and drops all Linux capabilities.

Check status with:

```sh
docker compose ps
docker compose logs -f psotnic
```

## Podman Quadlet

The example unit is `quadlet/psotnic.container`. Create the data directory first:

```sh
mkdir -p ~/.local/share/psotnic
chown 1000:1000 ~/.local/share/psotnic
```

Install the unit into `~/.config/containers/systemd/`, reload the user systemd manager, and start it as a rootless user service.

## Healthcheck

The image is healthy when either:

- the Psotnic process is running, or
- no configuration exists yet and the container is intentionally in first-run idle mode.

## Build

The build checks out the exact upstream commit and compiles the dynamic target with SSL support. The image does not track an upstream moving branch at runtime.

```sh
docker build -t psotnic:test .
IMAGE=psotnic:test sh scripts/smoke-test.sh
```

## Persistence and backup

Back up `/data` for each bot. It contains the local Psotnic configuration and may contain userlist/state files created by Psotnic. Treat these files as sensitive because they can contain credentials and botnet/channel administration data.

## Security

The supplied deployment examples run non-root, enable `no-new-privileges`, and drop all Linux capabilities. Do not expose Psotnic partyline/listener ports to untrusted networks unless your configuration explicitly requires them and they are appropriately protected.

## Releases

- `edge` follows successful builds of `main`.
- semantic-version tags such as `0.1.0` are stable release images.
- `0.1` tracks the corresponding minor release line.
- `latest` points to the most recent stable release.

BuildKit publishes SBOM and provenance attestations for multi-architecture published images.

## Licensing

Ploos AS packaging is MIT licensed. Upstream Psotnic source headers state GNU GPL version 2 or later. See `NOTICE` for the pinned upstream source and attribution.

This project is an unofficial container distribution and is not affiliated with the upstream Psotnic project.
