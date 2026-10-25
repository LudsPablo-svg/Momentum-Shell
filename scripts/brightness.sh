#!/usr/bin/env bash
set -Eeuo pipefail

case ${1:-} in
    up) brightnessctl -q set +5% ;;
    down) brightnessctl -q set 5%- ;;
    *)
        printf 'Uso: %s {up|down}\n' "$0" >&2
        exit 2
        ;;
esac
