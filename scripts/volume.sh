#!/usr/bin/env bash
set -Eeuo pipefail

action=${1:-}
case $action in
    up|down|mute) ;;
    *) printf 'Uso: %s {up|down|mute}\n' "$0" >&2; exit 2 ;;
esac

if command -v wpctl >/dev/null 2>&1; then
    case $action in
        up) wpctl set-volume --limit 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
    esac
elif command -v pactl >/dev/null 2>&1; then
    case $action in
        up) pactl set-sink-volume @DEFAULT_SINK@ +5% ;;
        down) pactl set-sink-volume @DEFAULT_SINK@ -5% ;;
        mute) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    esac
elif command -v amixer >/dev/null 2>&1; then
    control=''
    for candidate in Master PCM Speaker Headphone; do
        if amixer -q get "$candidate" >/dev/null 2>&1; then
            control=$candidate
            break
        fi
    done
    [[ -n $control ]] || {
        printf 'Nenhum controle ALSA Master/PCM/Speaker/Headphone foi encontrado.\n' >&2
        exit 1
    }
    case $action in
        up) amixer -q sset "$control" 5%+ unmute ;;
        down) amixer -q sset "$control" 5%- ;;
        mute) amixer -q sset "$control" toggle ;;
    esac
else
    printf 'Controle de áudio indisponível. Instale alsa-utils ou use wpctl/pactl do servidor de áudio já configurado.\n' >&2
    exit 1
fi
