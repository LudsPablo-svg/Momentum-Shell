#!/usr/bin/env bash
set -Eeuo pipefail

on_error() {
    local line=$1
    local command=$2
    printf 'Erro na linha %s ao executar: %s\n' "$line" "$command" >&2
    printf 'A instalação foi interrompida; confira as mensagens acima e os links/backups já aplicados antes de executá-la novamente.\n' >&2
    exit 1
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

die() {
    printf 'Erro: %s\n' "$*" >&2
    exit 1
}

info() {
    printf '==> %s\n' "$*"
}

readonly repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
[[ -n ${HOME:-} ]] || die 'HOME não está definido.'
(( EUID != 0 )) || die 'Execute como seu usuário normal; o instalador usa sudo apenas para o XBPS.'
command -v xbps-install >/dev/null 2>&1 || die 'xbps-install não foi encontrado.'
command -v sudo >/dev/null 2>&1 || die 'sudo é necessário para instalar pacotes. Configure-o e execute novamente.'
for required_command in basename chmod cp date dirname ln mkdir mktemp mv readlink rm unlink; do
    command -v "$required_command" >/dev/null 2>&1 || die "Comando necessário não encontrado: $required_command"
done
[[ -r $repo_dir/packages/packages.txt ]] || die 'packages/packages.txt não foi encontrado.'

required_files=(
    i3/config
    bar/i3status.conf
    picom/picom.conf
    terminal/alacritty.toml
    rofi/config.rasi
    rofi/colors.rasi
    notifications/dunstrc
    gtk/settings.ini
    gtk/gtk.css
    scripts/volume.sh
    scripts/brightness.sh
    scripts/screenshot.sh
    scripts/system-info.sh
    scripts/wallpaper.sh
    scripts/theme.sh
    scripts/quickshell-start.sh
    x11/xinitrc
    quickshell/shell.qml
    quickshell/components/Bar.qml
    quickshell/components/Clock.qml
    quickshell/components/NetworkIndicator.qml
    quickshell/components/PowerMenu.qml
    quickshell/components/SystemTray.qml
    quickshell/components/WorkspaceIndicator.qml
    quickshell/components/qmldir
    quickshell/services/Theme.qml
    quickshell/services/NetworkInfo.qml
    quickshell/services/qmldir
    quickshell/widgets/Dashboard.qml
    quickshell/widgets/SystemMonitor.qml
    quickshell/widgets/qmldir
    quickshell/services/Settings.qml
    quickshell/apps/ThemeManager.qml
    quickshell/apps/ShellSettings.qml
    quickshell/apps/qmldir
    quickshell/components/ActionButton.qml
    quickshell/components/AppHeader.qml
    quickshell/components/SettingToggle.qml
    themes/void-classic/theme.conf
    themes/void-forest/theme.conf
    themes/void-mono/theme.conf
    i3/current-theme.conf
)
for relative_source in "${required_files[@]}"; do
    [[ -r $repo_dir/$relative_source ]] || die "Arquivo do projeto ausente ou sem leitura: $relative_source"
done
[[ -d $repo_dir/quickshell ]] || die 'Diretório quickshell não foi encontrado.'
for required_directory in quickshell/themes quickshell/wallpapers themes/void-classic themes/void-forest themes/void-mono; do
    [[ -d $repo_dir/$required_directory ]] || die "Diretório do projeto ausente: $required_directory"
done

config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
[[ $config_home = /* ]] || config_home="$HOME/.config"
readonly config_home
data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
[[ $data_home = /* ]] || data_home="$HOME/.local/share"
readonly data_home
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
[[ $state_home = /* ]] || state_home="$HOME/.local/state"
readonly state_home
readonly backup_stamp="$(date '+%Y%m%d-%H%M%S')"

packages=()
while IFS= read -r package || [[ -n $package ]]; do
    [[ -z $package || $package == \#* ]] && continue
    [[ $package =~ ^[a-zA-Z0-9][a-zA-Z0-9+_.-]*$ ]] ||
        die "Nome de pacote inválido em packages.txt: $package"
    packages+=("$package")
done < "$repo_dir/packages/packages.txt"
((${#packages[@]} > 0)) || die 'A lista de pacotes está vazia.'

info 'Sincronizando os repositórios e instalando os pacotes Void listados.'
sudo xbps-install -S -y "${packages[@]}"
command -v qs >/dev/null 2>&1 || die 'O pacote quickshell foi solicitado, mas o comando qs não está disponível no PATH.'

last_backup=''
backup_existing() {
    local target=$1
    local backup="$target.backup.$backup_stamp"
    local suffix=1

    while [[ -e $backup || -L $backup ]]; do
        backup="$target.backup.$backup_stamp.$suffix"
        ((suffix += 1))
    done
    mv -- "$target" "$backup"
    last_backup=$backup
    info "Backup criado: $backup"
}

link_path() {
    local relative_source=$1
    local target=$2
    local kind=$3
    local source="$repo_dir/$relative_source"
    local resolved_target=''
    local saved_backup=''

    if [[ $kind == directory ]]; then
        [[ -d $source ]] || die "Diretório do projeto ausente: $relative_source"
    else
        [[ -f $source ]] || die "Arquivo do projeto ausente: $relative_source"
    fi
    mkdir -p -- "$(dirname -- "$target")"

    if [[ -L $target ]]; then
        resolved_target="$(readlink -f -- "$target" 2>/dev/null || true)"
        if [[ $resolved_target == "$source" ]]; then
            info "Já aplicado: $target"
            return
        fi
    fi

    if [[ -e $target || -L $target ]]; then
        backup_existing "$target"
        saved_backup=$last_backup
    fi
    if ! ln -s -- "$source" "$target"; then
        if [[ -n $saved_backup ]]; then
            mv -- "$saved_backup" "$target" || die "Falha ao restaurar o backup $saved_backup para $target"
            info "Backup restaurado após falha: $target"
        fi
        die "Não foi possível criar o link $target"
    fi
    info "Link aplicado: $target"
}

link_file() {
    link_path "$1" "$2" file
}

link_directory() {
    link_path "$1" "$2" directory
}

link_runtime_target() {
    local target=$1
    local source=$2
    local link_value=''
    local saved_backup=''

    mkdir -p -- "$(dirname -- "$target")"
    if [[ -L $target ]]; then
        link_value=$(readlink -- "$target")
        if [[ $link_value == "$source" ]]; then
            info "Já aplicado: $target"
            return
        fi
    fi

    if [[ -e $target || -L $target ]]; then
        backup_existing "$target"
        saved_backup=$last_backup
    fi
    if ! ln -s -- "$source" "$target"; then
        if [[ -n $saved_backup ]]; then
            mv -- "$saved_backup" "$target" || die "Falha ao restaurar o backup $saved_backup para $target"
            info "Backup restaurado após falha: $target"
        fi
        die "Não foi possível criar o link de tema $target"
    fi
    info "Link de tema aplicado: $target"
}

link_if_absent() {
    local relative_source=$1
    local target=$2
    local source="$repo_dir/$relative_source"
    local resolved_target=''

    if [[ -L $target ]]; then
        resolved_target="$(readlink -f -- "$target" 2>/dev/null || true)"
        if [[ $resolved_target == "$source" ]]; then
            return
        fi
        if [[ ! -e $target ]]; then
            link_file "$relative_source" "$target"
            return
        fi
    fi
    if [[ -e $target || -L $target ]]; then
        printf 'Mantido sem alteração: %s já existe. Consulte README.md para integrar o xinitrc.\n' "$target"
        return
    fi
    link_file "$relative_source" "$target"
}

info 'Aplicando configurações como o usuário atual.'
mkdir -p -- "$config_home/void-shell" "$data_home/void-shell/wallpapers" "$state_home/void-shell"
link_file i3/config "$config_home/i3/config"
link_runtime_target "$config_home/i3/current-theme.conf" "$config_home/void-shell/current-theme/i3.conf"
link_file bar/i3status.conf "$config_home/i3status/config"
link_file picom/picom.conf "$config_home/picom/picom.conf"
link_file terminal/alacritty.toml "$config_home/alacritty/alacritty.toml"
link_runtime_target "$config_home/alacritty/void-theme.toml" "$config_home/void-shell/current-theme/alacritty.toml"
link_file rofi/config.rasi "$config_home/rofi/config.rasi"
link_runtime_target "$config_home/rofi/colors.rasi" "$config_home/void-shell/current-theme/rofi.rasi"
link_file notifications/dunstrc "$config_home/dunst/dunstrc"
link_runtime_target "$config_home/dunst/dunstrc.d/99-void-theme.conf" "$config_home/void-shell/current-theme/dunst.conf"
link_file gtk/settings.ini "$config_home/gtk-3.0/settings.ini"
link_runtime_target "$config_home/gtk-3.0/gtk.css" "$config_home/void-shell/current-theme/gtk.css"
link_directory quickshell "$config_home/quickshell/void"

link_file scripts/volume.sh "$HOME/.local/bin/void-volume"
link_file scripts/brightness.sh "$HOME/.local/bin/void-brightness"
link_file scripts/screenshot.sh "$HOME/.local/bin/void-screenshot"
link_file scripts/system-info.sh "$HOME/.local/bin/void-system-info"
link_file scripts/wallpaper.sh "$HOME/.local/bin/void-wallpaper"
link_file scripts/theme.sh "$HOME/.local/bin/void-theme"
link_file scripts/quickshell-start.sh "$HOME/.local/bin/void-quickshell-start"
link_if_absent x11/xinitrc "$HOME/.xinitrc"

info 'Preparando o tema padrão e os arquivos de inclusão do desktop.'
current_theme_path="$config_home/void-shell/current-theme"
if [[ ! -e $current_theme_path ]]; then
    initial_theme=void-classic
    if [[ -r $state_home/void-shell/active-theme ]]; then
        IFS= read -r saved_theme < "$state_home/void-shell/active-theme" || true
        case $saved_theme in
            void-classic|void-forest|void-mono) initial_theme=$saved_theme ;;
        esac
    fi
    "$HOME/.local/bin/void-theme" prepare "$initial_theme"
else
    info 'Tema ativo existente preservado.'
fi

info 'Instalação concluída. Encerre e inicie sua sessão X11/i3 para carregar os arquivos.'
