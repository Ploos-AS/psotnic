# Multi-bot deployment example

This example provides separate containers and persistent storage for Psotnic main, slave, and leaf roles.

It intentionally does not ship example credentials, IRC network settings, botnet passwords, listener exposure, or a generated Psotnic configuration. Generate and review each bot configuration separately and use the deployment only on IRC networks and channels where you are authorized to operate the bots.

## Prepare each bot

Create the volumes:

```sh
docker compose -f examples/multi-bot/compose.yaml create
```

Generate configuration interactively for each role, one at a time:

```sh
docker compose -f examples/multi-bot/compose.yaml run --rm main -n
docker compose -f examples/multi-bot/compose.yaml run --rm slave -n
docker compose -f examples/multi-bot/compose.yaml run --rm leaf -n
```

Review the generated configuration in each bot's own `/data` volume. Configure the Psotnic topology according to upstream Psotnic documentation. The Compose service names are deployment labels only; they do not automatically configure Psotnic's main/slave/leaf relationships.

## Start

```sh
docker compose -f examples/multi-bot/compose.yaml up -d
docker compose -f examples/multi-bot/compose.yaml ps
```

## Isolation

Each bot has a distinct named volume:

- `main-data`
- `slave-data`
- `leaf-data`

Do not share a writable `/data` volume between bots. Configurations and state may contain credentials or other sensitive IRC administration data.

The example keeps the same hardened runtime contract as the single-bot deployment: UID/GID 1000:1000, all Linux capabilities dropped, and `no-new-privileges` enabled.

No ports are published by default. Only expose a Psotnic listener when your topology requires it, and restrict access appropriately.
