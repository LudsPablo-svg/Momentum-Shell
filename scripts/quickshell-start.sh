#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v qs >/dev/null 2>&1; then
    printf 'Quickshell não está instalado ou o comando qs não está no PATH.\n' >&2
    exit 1
fi

if qs ipc call void ping >/dev/null 2>&1; then
    exit 0
fi

exec qs --config void
