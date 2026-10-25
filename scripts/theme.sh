#!/usr/bin/env bash
set -Eeuo pipefail

die() {
    printf 'Erro: %s\n' "$*" >&2
    exit 1
}

script_path=$(readlink -f -- "${BASH_SOURCE[0]}")
repo_dir=$(cd -- "$(dirname -- "$script_path")/.." && pwd -P)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
[[ $config_home == /* ]] || config_home="$HOME/.config"
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
[[ $state_home == /* ]] || state_home="$HOME/.local/state"
app_config="$config_home/void-shell"
generated_root="$app_config/generated"
state_dir="$state_home/void-shell"
active_state="$state_dir/active-theme"
current_theme="$app_config/current-theme"

list_themes() {
    printf '%s\n' 'void-classic' 'void-forest' 'void-mono'
}

read_theme() {
    local theme_id=$1
    local config_file="$repo_dir/themes/$theme_id/theme.conf"
    local key value
    declare -gA theme_values=()

    case $theme_id in
        void-classic|void-forest|void-mono) ;;
        *) die "Tema desconhecido: $theme_id" ;;
    esac
    [[ -r $config_file ]] || die "Metadados do tema ausentes: $config_file"

    while IFS='=' read -r key value || [[ -n $key ]]; do
        value=${value%$'\r'}
        [[ -z $key || $key == \#* ]] && continue
        case $key in
            name|description|wallpaper|background|surface|elevated|border|text|muted|accent|accent_dark|error|warning) ;;
            *) die "Campo não permitido em $config_file: $key" ;;
        esac
        [[ -z ${theme_values[$key]+present} ]] || die "Campo duplicado em $config_file: $key"

        case $key in
            name)
                [[ $value =~ ^[A-Za-z0-9._\ -]{1,48}$ ]] || die "Nome de tema inválido em $config_file"
                ;;
            description)
                [[ $value =~ ^[A-Za-z0-9.,_\ -]{1,120}$ ]] || die "Descrição inválida em $config_file"
                ;;
            wallpaper)
                [[ $value =~ ^wallpapers/[A-Za-z0-9._-]+$ ]] || die "Caminho de wallpaper inválido em $config_file"
                [[ -r $repo_dir/$value ]] || die "Wallpaper do tema ausente: $repo_dir/$value"
                ;;
            *)
                [[ $value =~ ^#[A-Fa-f0-9]{6}$ ]] || die "Cor inválida em $config_file: $key"
                ;;
        esac
        theme_values[$key]=$value
    done < "$config_file"

    local required_key
    for required_key in name description wallpaper background surface elevated border text muted accent accent_dark error warning; do
        [[ -n ${theme_values[$required_key]:-} ]] || die "Campo obrigatório ausente em $config_file: $required_key"
    done
}

write_theme_files() {
    local generation_dir=$1

    cat > "$generation_dir/theme.json" <<EOF
{
  "id": "$theme_id",
  "name": "${theme_values[name]}",
  "description": "${theme_values[description]}",
  "background": "${theme_values[background]}",
  "surface": "${theme_values[surface]}",
  "elevated": "${theme_values[elevated]}",
  "border": "${theme_values[border]}",
  "text": "${theme_values[text]}",
  "muted": "${theme_values[muted]}",
  "accent": "${theme_values[accent]}",
  "accentDark": "${theme_values[accent_dark]}",
  "error": "${theme_values[error]}",
  "warning": "${theme_values[warning]}"
}
EOF

    cat > "$generation_dir/i3.conf" <<EOF
bar {
    id void-i3-fallback
    mode hide
    position top
    status_command i3status
    i3bar_command i3bar --transparency
    font pango:DejaVu Sans Mono 10
    padding 6px 0
    workspace_min_width 34
    tray_padding 6
    separator_symbol "  "
    colors {
        background ${theme_values[background]}E8
        statusline ${theme_values[text]}
        separator ${theme_values[muted]}
        focused_workspace ${theme_values[accent]} ${theme_values[accent]} ${theme_values[background]}
        active_workspace ${theme_values[border]} ${theme_values[border]} ${theme_values[text]}
        inactive_workspace ${theme_values[background]} ${theme_values[background]} ${theme_values[muted]}
        urgent_workspace ${theme_values[error]} ${theme_values[error]} ${theme_values[background]}
        binding_mode ${theme_values[warning]} ${theme_values[warning]} ${theme_values[background]}
    }
}

client.focused          ${theme_values[accent]} ${theme_values[surface]} ${theme_values[text]} ${theme_values[accent]} ${theme_values[accent]}
client.focused_inactive ${theme_values[border]} ${theme_values[surface]} ${theme_values[muted]} ${theme_values[border]} ${theme_values[border]}
client.unfocused        ${theme_values[surface]} ${theme_values[background]} ${theme_values[muted]} ${theme_values[surface]} ${theme_values[surface]}
client.urgent           ${theme_values[error]} ${theme_values[surface]} ${theme_values[text]} ${theme_values[error]} ${theme_values[error]}
client.placeholder      ${theme_values[border]} ${theme_values[background]} ${theme_values[muted]} ${theme_values[border]} ${theme_values[border]}
client.background       ${theme_values[background]}
EOF

    cat > "$generation_dir/rofi.rasi" <<EOF
* {
    background: ${theme_values[background]}F2;
    surface: ${theme_values[surface]}E8;
    border: ${theme_values[border]};
    muted: ${theme_values[muted]};
    text: ${theme_values[text]};
    accent: ${theme_values[accent]};
    warning: ${theme_values[warning]};
    error: ${theme_values[error]};
}
EOF

    cat > "$generation_dir/gtk.css" <<EOF
@define-color void_accent ${theme_values[accent]};
@define-color void_selection_text ${theme_values[background]};

*:selected {
    background-color: @void_accent;
    color: @void_selection_text;
}
EOF

    cat > "$generation_dir/alacritty.toml" <<EOF
[colors.primary]
background = "${theme_values[background]}"
foreground = "${theme_values[text]}"

[colors.cursor]
text = "${theme_values[background]}"
cursor = "${theme_values[accent]}"

[colors.selection]
text = "${theme_values[background]}"
background = "${theme_values[accent]}"

[colors.normal]
black = "${theme_values[surface]}"
red = "${theme_values[error]}"
green = "${theme_values[accent]}"
yellow = "${theme_values[warning]}"
blue = "#6F91C4"
magenta = "#A788BD"
cyan = "#6BA9A4"
white = "${theme_values[muted]}"

[colors.bright]
black = "${theme_values[border]}"
red = "#E66B67"
green = "${theme_values[accent]}"
yellow = "#E6B856"
blue = "#86A6D4"
magenta = "#B99BCF"
cyan = "#82BDB8"
white = "${theme_values[text]}"
EOF

    cat > "$generation_dir/dunst.conf" <<EOF
[global]
    frame_color = "${theme_values[accent]}"
    separator_color = "${theme_values[border]}"
    background = "${theme_values[background]}"
    foreground = "${theme_values[text]}"

[urgency_low]
    background = "${theme_values[surface]}"
    foreground = "${theme_values[muted]}"
    frame_color = "${theme_values[border]}"

[urgency_normal]
    background = "${theme_values[surface]}"
    foreground = "${theme_values[text]}"
    frame_color = "${theme_values[accent]}"

[urgency_critical]
    background = "${theme_values[surface]}"
    foreground = "${theme_values[text]}"
    frame_color = "${theme_values[error]}"
EOF

    chmod 644 "$generation_dir"/*
}

make_generation() {
    mkdir -p -- "$generated_root"
    generation_dir=$(mktemp -d "$generated_root/$theme_id.XXXXXX")
    write_theme_files "$generation_dir"
}

restore_previous_theme() {
    local previous_target=$1
    local previous_state=$2
    local previous_backup=$3
    local link_tmp="$app_config/.current-theme.rollback.$$"

    if [[ -n $previous_target ]]; then
        ln -s -- "$previous_target" "$link_tmp"
        mv -Tf -- "$link_tmp" "$current_theme"
    elif [[ -n $previous_backup && ( -e $previous_backup || -L $previous_backup ) ]]; then
        mv -Tf -- "$previous_backup" "$current_theme"
    else
        unlink -- "$current_theme" 2>/dev/null || true
    fi

    if [[ -n $previous_state ]]; then
        local state_tmp
        state_tmp=$(mktemp "$state_dir/.active-theme.rollback.XXXXXX")
        printf '%s\n' "$previous_state" > "$state_tmp"
        mv -f -- "$state_tmp" "$active_state"
    else
        unlink -- "$active_state" 2>/dev/null || true
    fi
}

commit_generation() {
    local generation=$1
    local current_target=''
    local generated_real_root
    local temporary_link="$app_config/.current-theme.$$"
    local state_tmp
    local backup_stamp backup_path suffix=1

    previous_theme_target=''
    previous_theme_backup=''
    previous_theme_id=''
    [[ -r $active_state ]] && IFS= read -r previous_theme_id < "$active_state" || true
    generated_real_root=$(readlink -f -- "$generated_root")

    if [[ -L $current_theme ]]; then
        current_target=$(readlink -f -- "$current_theme" 2>/dev/null || true)
        if [[ $current_target == "$generated_real_root/"* ]]; then
            previous_theme_target=$current_target
        else
            backup_stamp=$(date '+%Y%m%d-%H%M%S')
            backup_path="$current_theme.backup.$backup_stamp"
            while [[ -e $backup_path || -L $backup_path ]]; do
                backup_path="$current_theme.backup.$backup_stamp.$suffix"
                ((suffix += 1))
            done
            mv -- "$current_theme" "$backup_path"
            previous_theme_backup=$backup_path
            printf 'Backup do tema anterior: %s\n' "$backup_path"
        fi
    elif [[ -e $current_theme ]]; then
        backup_stamp=$(date '+%Y%m%d-%H%M%S')
        backup_path="$current_theme.backup.$backup_stamp"
        while [[ -e $backup_path || -L $backup_path ]]; do
            backup_path="$current_theme.backup.$backup_stamp.$suffix"
            ((suffix += 1))
        done
        mv -- "$current_theme" "$backup_path"
        previous_theme_backup=$backup_path
        printf 'Backup do tema anterior: %s\n' "$backup_path"
    fi

    ln -s -- "$generation" "$temporary_link"
    if ! mv -Tf -- "$temporary_link" "$current_theme"; then
        unlink -- "$temporary_link" 2>/dev/null || true
        if [[ -n $previous_theme_backup ]]; then
            mv -Tf -- "$previous_theme_backup" "$current_theme" || true
        fi
        die 'Não foi possível ativar o novo conjunto de arquivos do tema.'
    fi

    state_tmp=$(mktemp "$state_dir/.active-theme.XXXXXX")
    if ! printf '%s\n' "$theme_id" > "$state_tmp" || ! mv -f -- "$state_tmp" "$active_state"; then
        rm -f -- "$state_tmp"
        restore_previous_theme "$previous_theme_target" "$previous_theme_id" "$previous_theme_backup"
        die 'Falha ao registrar o tema ativo; a configuração anterior foi restaurada.'
    fi
}

reload_desktop() {
    if command -v i3-msg >/dev/null 2>&1 && i3-msg -t get_version >/dev/null 2>&1; then
        i3-msg reload >/dev/null 2>&1 || printf 'Aviso: i3 não recarregou a configuração.\n' >&2
    fi
    if command -v qs >/dev/null 2>&1; then
        qs ipc call void refreshTheme >/dev/null 2>&1 || true
    fi
    if command -v dunstctl >/dev/null 2>&1; then
        dunstctl reload >/dev/null 2>&1 || true
    fi
}

action=${1:-}
case $action in
    list)
        (($# == 1)) || die "Uso: $0 list"
        list_themes
        exit 0
        ;;
    prepare|apply)
        (($# == 2)) || die "Uso: $0 {prepare|apply} TEMA"
        action=$1
        theme_id=$2
        ;;
    *)
        die "Uso: $0 {list|prepare TEMA|apply TEMA}"
        ;;
esac

read_theme "$theme_id"
mkdir -p -- "$app_config" "$state_dir"
make_generation
commit_generation "$generation_dir"

if [[ $action == prepare ]]; then
    printf 'Tema %s preparado.\n' "${theme_values[name]}"
    exit 0
fi

old_wallpaper=''
if [[ -r $state_dir/wallpaper ]]; then
    IFS= read -r old_wallpaper < "$state_dir/wallpaper" || [[ -n $old_wallpaper ]]
fi
wallpaper_path="$repo_dir/${theme_values[wallpaper]}"
if ! "$repo_dir/scripts/wallpaper.sh" set "$wallpaper_path"; then
    restore_previous_theme "$previous_theme_target" "$previous_theme_id" "$previous_theme_backup"
    if [[ -n $old_wallpaper && -r $old_wallpaper ]]; then
        "$repo_dir/scripts/wallpaper.sh" set "$old_wallpaper" >/dev/null 2>&1 || true
    else
        "$repo_dir/scripts/wallpaper.sh" restore >/dev/null 2>&1 || true
    fi
    die 'O wallpaper falhou; o tema anterior foi restaurado.'
fi

reload_desktop
printf 'Tema %s aplicado. GTK e janelas de terminal abertas podem precisar ser reabertos.\n' "${theme_values[name]}"
