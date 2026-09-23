# Configuration preflight

The packaging includes `scripts/preflight.sh` for non-invasive checks before starting or upgrading a Psotnic deployment.

Run it against the default configuration path:

```sh
sh scripts/preflight.sh /path/to/psotnic.conf
```

When run in an environment where `PSOTNIC_CONFIG` is set, the script uses that value if no path argument is supplied.

The preflight checks that:

- the configuration path is non-empty;
- the target exists and is a regular file;
- the file is readable and non-empty;
- the containing directory exists and is searchable.

A successful preflight means the deployment has a structurally usable configuration file. It does **not** mean that Psotnic has accepted the file's syntax, credentials, IRC settings, botnet topology, or semantics.

This distinction is intentional. The Ploos AS container packaging does not invent a parser or silently reinterpret upstream Psotnic configuration.

## Container example

For a named volume, the packaging script can be mounted read-only and run against the same persistent data used by the bot:

```sh
docker run --rm \
  -v psotnic-data:/data:ro \
  -v "$PWD/scripts/preflight.sh:/preflight.sh:ro" \
  --entrypoint sh \
  ghcr.io/ploos-as/psotnic:0.1.1 \
  /preflight.sh /data/psotnic.conf
```

Do not print the configuration itself during validation. It may contain credentials or administrative secrets.

For actual runtime validation, start the intended image in a controlled environment and inspect its exit status, health state, and logs. See `docs/OPERATIONS.md` and `docs/UPGRADE_ROLLBACK.md`.
