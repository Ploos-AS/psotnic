# Upgrade and rollback

Psotnic container upgrades should be treated as a change to the container image, not as a migration of persistent data unless an upstream release explicitly requires one.

## Before upgrading

1. Record the currently deployed image tag or digest.
2. Stop the bot cleanly.
3. Back up its `/data` volume using `scripts/backup-data.sh`.
4. Keep the previous image available until the upgraded bot has been verified.
5. Read the Ploos AS release notes and relevant upstream Psotnic changes.

For a multi-bot deployment, upgrade one role at a time where the topology permits it. Back up every bot's volume independently.

## Upgrade

Use an explicit stable version rather than `latest` for controlled deployments.

Pull the target image, update the deployment definition, and recreate the container while retaining the same persistent volume. Then verify container health and IRC/botnet behavior appropriate to your deployment.

Do not delete the pre-upgrade backup during initial verification.

## Rollback

If the new image fails before persistent state has changed incompatibly, stop it and redeploy the exact previous image against the existing volume.

If state may have changed, use the safer recovery path:

1. stop the upgraded container;
2. preserve the current volume for diagnosis;
3. restore the pre-upgrade backup into a new empty volume;
4. deploy the previous image against that restored volume;
5. verify operation before removing either recovery copy.

The restore helper deliberately refuses to merge a backup into a non-empty volume.

## Digests

For deployments requiring strict reproducibility, record and deploy the qualified image digest rather than relying only on a mutable alias such as `latest`.

Ploos AS release CI verifies published multi-architecture images and release aliases, but an operator should still record the exact image used by a production deployment.

## Secrets

Configuration and backup archives may contain credentials or botnet/channel administration secrets. Never attach them to bug reports or CI logs.
