#!/usr/bin/env bash
set -Eeuo pipefail

mode=${1:-selection}
case $mode in
    selection|full) ;;
    *) printf 'Uso: %s [selection|full]\n' "$0" >&2; exit 2 ;;
esac
command -v scrot >/dev/null 2>&1 || {
    printf 'scrot não está instalado.\n' >&2
    exit 1
}

output_dir="$HOME/Pictures/Screenshots"
mkdir -p -- "$output_dir"
stamp="$(date '+%Y-%m-%d_%H-%M-%S')"
destination="$output_dir/$stamp.png"
suffix=1
while [[ -e $destination ]]; do
    destination="$output_dir/$stamp-$suffix.png"
    ((suffix += 1))
done

if [[ $mode == selection ]]; then
    scrot -s "$destination"
else
    scrot "$destination"
fi
[[ -e $destination ]] && printf 'Captura salva em %s\n' "$destination"
