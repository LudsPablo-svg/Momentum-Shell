#!/usr/bin/env bash
set -Eeuo pipefail

die() {
    printf 'Erro: %s\n' "$*" >&2
    exit 1
}

script_path=$(readlink -f -- "${BASH_SOURCE[0]}")
repo_dir=$(cd -- "$(dirname -- "$script_path")/.." && pwd -P)
default_wallpaper="$repo_dir/wallpapers/wallhaven-ogg3em_3840x2160.png"
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
[[ $data_home == /* ]] || data_home="$HOME/.local/share"
[[ $state_home == /* ]] || state_home="$HOME/.local/state"
state_dir="$state_home/void-shell"
wallpaper_state="$state_dir/wallpaper"
library_dir="$data_home/void-shell/wallpapers"

command -v feh >/dev/null 2>&1 || die 'feh não está instalado; não foi possível aplicar o wallpaper.'

validate_image() {
    local path=$1
    local extension

    if [[ $path == *$'\n'* ]]; then
        printf 'Caminhos de wallpaper não podem conter quebra de linha.\n' >&2
        return 1
    fi
    if [[ ! -f $path || ! -r $path ]]; then
        printf 'Imagem ausente ou sem leitura: %s\n' "$path" >&2
        return 1
    fi
    extension=${path##*.}
    extension=${extension,,}
    case $extension in
        png|jpg|jpeg) ;;
        *)
            printf 'Formato não suportado: .%s (use PNG ou JPEG).\n' "$extension" >&2
            return 1
            ;;
    esac
}

persist_path() {
    local path=$1
    local temporary

    mkdir -p -- "$state_dir"
    temporary=$(mktemp "$state_dir/.wallpaper.XXXXXX")
    chmod 600 "$temporary"
    if ! printf '%s\n' "$path" > "$temporary"; then
        rm -f -- "$temporary"
        printf 'Não foi possível gravar o estado do wallpaper.\n' >&2
        return 1
    fi
    if ! mv -f -- "$temporary" "$wallpaper_state"; then
        rm -f -- "$temporary"
        printf 'Não foi possível salvar a escolha do wallpaper.\n' >&2
        return 1
    fi
}

apply_path() {
    local path=$1

    validate_image "$path" || return 1
    if ! feh --no-fehbg --bg-fill "$path"; then
        printf 'feh não conseguiu aplicar a imagem: %s\n' "$path" >&2
        return 1
    fi
    persist_path "$path"
}

import_image() {
    local source=$1
    local original_name extension safe_name destination stem suffix=1

    validate_image "$source" || die "Imagem não suportada: $source"
    mkdir -p -- "$library_dir"
    original_name=$(basename -- "$source")
    extension=${original_name##*.}
    extension=${extension,,}
    case $extension in
        png|jpg|jpeg) ;;
        *) die "Formato não suportado: .$extension (use PNG ou JPEG)." ;;
    esac
    safe_name=${original_name//[^[:alnum:]_.-]/_}
    [[ -n $safe_name && $safe_name != .* ]] || safe_name="wallpaper.$extension"
    stem=${safe_name%.*}
    destination="$library_dir/$safe_name"

    while [[ -e $destination || -L $destination ]]; do
        destination="$library_dir/$stem-$suffix.$extension"
        ((suffix += 1))
    done

    if ! cp -- "$source" "$destination"; then
        rm -f -- "$destination"
        die "Não foi possível copiar a imagem para a biblioteca: $destination"
    fi
    if ! apply_path "$destination"; then
        rm -f -- "$destination"
        die 'A imagem foi copiada, mas não pôde ser aplicada; o arquivo foi removido.'
    fi
    printf 'Wallpaper importado e aplicado: %s\n' "$destination"
}

case ${1:-restore} in
    --set|set)
        (($# == 2)) || die "Uso: $0 set /caminho/para/imagem.png"
        apply_path "$2" || die "Não foi possível aplicar o wallpaper: $2"
        ;;
    --import|import)
        (($# == 2)) || die "Uso: $0 import /caminho/para/imagem.png"
        import_image "$2"
        ;;
    restore)
        (($# <= 1)) || die "Uso: $0 [restore|set IMAGEM|import IMAGEM]"
        wallpaper=''
        if [[ -r $wallpaper_state ]]; then
            IFS= read -r wallpaper < "$wallpaper_state" || [[ -n $wallpaper ]]
        fi
        if [[ -n $wallpaper ]] && validate_image "$wallpaper"; then
            if apply_path "$wallpaper"; then
                exit 0
            fi
            printf 'Não foi possível restaurar a imagem salva; usando o padrão incluído.\n' >&2
        else
            printf 'Wallpaper salvo indisponível; restaurando o padrão incluído.\n' >&2
        fi
        [[ -r $default_wallpaper ]] || die "Wallpaper padrão não encontrado: $default_wallpaper"
        apply_path "$default_wallpaper" || die 'Não foi possível aplicar o wallpaper padrão.'
        ;;
    *)
        die "Uso: $0 [restore|set IMAGEM|import IMAGEM]"
        ;;
esac
