# Backup and restore

Psotnic stores persistent configuration and state under `/data`. Treat backups as sensitive because configuration may contain IRC credentials, botnet secrets, and channel administration data.

## Backup

Stop the bot before taking a consistent backup:

```sh
docker compose stop psotnic
sh scripts/backup-data.sh psotnic-data psotnic-data-backup.tar.gz
docker compose start psotnic
```

The helper mounts the named volume read-only and writes a gzip-compressed tar archive. Store the archive with access controls appropriate for credentials.

For the multi-bot example, back up `main-data`, `slave-data`, and `leaf-data` independently.

## Restore

Restore into a new or empty named volume:

```sh
sh scripts/restore-data.sh psotnic-data-backup.tar.gz psotnic-data-restored
```

The restore helper refuses to merge an archive into a non-empty volume. This prevents accidental mixing of old and new state.

Inspect the restored configuration before starting Psotnic. To use the restored volume, point your deployment at that volume or deliberately replace the old volume after verification.

## Recovery test

A backup is not considered useful until it has been restored successfully. Periodically restore into a temporary volume and verify that expected files are present. Do not print configuration contents into CI logs because they may contain secrets.
