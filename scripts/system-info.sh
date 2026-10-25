#!/usr/bin/env bash
set -Eeuo pipefail

load='indisponível'
uptime='indisponível'
mem_total=0
mem_available=0
host='desconhecido'

if [[ -r /proc/loadavg ]]; then
    read -r load _ < /proc/loadavg
fi
if [[ -r /proc/uptime ]]; then
    read -r uptime _ < /proc/uptime
    uptime=${uptime%%.*}
    days=$((uptime / 86400))
    hours=$(((uptime % 86400) / 3600))
    minutes=$(((uptime % 3600) / 60))
    if ((days > 0)); then
        uptime="${days}d ${hours}h ${minutes}m"
    else
        uptime="${hours}h ${minutes}m"
    fi
fi
if [[ -r /proc/sys/kernel/hostname ]]; then
    read -r host < /proc/sys/kernel/hostname
fi
if [[ -r /proc/meminfo ]]; then
    while read -r key value _; do
        case $key in
            MemTotal:) mem_total=$value ;;
            MemAvailable:) mem_available=$value ;;
        esac
    done < /proc/meminfo
fi

mem_used=$((mem_total - mem_available))
printf 'VOID DESKTOP\n'
printf 'Host:   %s\n' "$host"
printf 'Kernel: %s\n' "$(uname -r)"
printf 'Uptime: %s\n' "$uptime"
printf 'Load:   %s\n' "$load"
if ((mem_total > 0)); then
    printf 'Memory: %d / %d MiB used\n' "$((mem_used / 1024))" "$((mem_total / 1024))"
else
    printf 'Memory: unavailable\n'
fi
