#!/bin/sh
set -e

PUID="${PUID:-99}"
PGID="${PGID:-100}"

mkdir -p "${XDG_DATA_HOME}/meshsense"
chown -R "${PUID}:${PGID}" "${XDG_DATA_HOME}"

export HOME="${XDG_DATA_HOME}"
exec setpriv --reuid="${PUID}" --regid="${PGID}" --clear-groups "$@"
