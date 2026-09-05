#!/bin/sh
set -eu

compose=compose.yaml
quadlet=quadlet/psotnic.container

# Compose security contract.
grep -Eq '^[[:space:]]+user:[[:space:]]+"1000:1000"$' "$compose"
grep -Eq '^[[:space:]]+security_opt:$' "$compose"
grep -Eq '^[[:space:]]+- no-new-privileges:true$' "$compose"
grep -Eq '^[[:space:]]+cap_drop:$' "$compose"
grep -Eq '^[[:space:]]+- ALL$' "$compose"

if grep -Eq '^[[:space:]]+(privileged:[[:space:]]*true|network_mode:[[:space:]]*host|cap_add:|pid:[[:space:]]*host|ipc:[[:space:]]*host)' "$compose"; then
  echo 'unsafe Compose setting detected' >&2
  exit 1
fi
if grep -Eq '/var/run/docker\.sock|/run/docker\.sock|/run/podman/podman\.sock' "$compose"; then
  echo 'container-engine socket mount detected in Compose' >&2
  exit 1
fi

# Quadlet security contract.
grep -qx 'User=1000:1000' "$quadlet"
grep -qx 'DropCapability=all' "$quadlet"
grep -qx 'NoNewPrivileges=true' "$quadlet"

if grep -Eqi '^(AddCapability=|Network=host$|PodmanArgs=.*--privileged|Volume=.*docker\.sock|Volume=.*podman\.sock)' "$quadlet"; then
  echo 'unsafe Quadlet setting detected' >&2
  exit 1
fi

printf '%s\n' 'deployment hardening: PASS'
