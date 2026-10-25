# Dependências e pesquisa

Pesquisa realizada em 24/10/2026. Os nomes abaixo são os nomes de pacote Void, confirmados nas receitas oficiais de void-packages ou no manual oficial do Void. Cada nome também retornou um pacote no índice XBPS configurado neste ambiente ao consultar com xbps-query -Rs. A disponibilidade binária pode variar por arquitetura e repositório habilitado; confirme no sistema local com xbps-query -Rs NOME antes de instalar, conforme a documentação XBPS. O instalador sincroniza os índices e pede a instalação explícita dos nomes abaixo.

| Pacote Void | Finalidade | Referência consultada |
| --- | --- | --- |
| xorg | Meta-pacote do servidor X, drivers livres de vídeo e entrada, fontes e utilitários. Escolhido pela cobertura geral do manual do Void. GPUs que exigem driver proprietário ficam a cargo da instalação local. | [Manual Void: Xorg](https://docs.voidlinux.org/config/graphical-session/xorg.html), [receita xorg](https://github.com/void-linux/void-packages/blob/master/srcpkgs/xorg/template) |
| xinit | Fornece startx para iniciar a sessão X pelo console. Nenhum display manager é instalado. | [Manual Void: Xorg e startx](https://docs.voidlinux.org/config/graphical-session/xorg.html), [receita xinit](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/xinit/template) |
| i3 | Gerenciador tiled X11, barra de recuperação i3bar, i3-msg e i3-nagbar. O nome Void do pacote é i3. | [Receita Void i3](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/i3/template), [guia do i3](https://i3wm.org/docs/userguide.html) |
| quickshell | Toolkit QtQuick/QML para a barra e o dashboard. O pacote `quickshell-0.3.2_1` apareceu em `current` na consulta XBPS x86_64 deste ambiente. O pacote Void compila suporte X11 e declara suas dependências de execução; o instalador adiciona somente `quickshell` à lista explícita, e XBPS resolve as bibliotecas. | [Receita Void quickshell](https://github.com/void-linux/void-packages/blob/master/srcpkgs/quickshell/template), [documentação Quickshell 0.3.2](https://quickshell.org/docs/v0.3.2/), [BUILD.md: X11 e recursos opcionais](https://github.com/quickshell-mirror/quickshell/blob/master/BUILD.md), [sobre as integrações](https://quickshell.org/about/) |
| i3status | Status de rede, carga, memória e relógio para i3bar. Não configura conexão de rede. | [Receita Void i3status](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/i3status/template), [manual i3status](https://i3wm.org/i3status/manpage.html) |
| picom | Compositor X11 que fornece sombras, transparência e blur das superfícies translúcidas. | [Receita Void picom](https://github.com/void-linux/void-packages/blob/master/srcpkgs/picom/template), [manual Picom](https://github.com/yshui/picom/blob/next/man/picom.1.adoc) |
| feh | Visualizador de imagens usado para definir o wallpaper do X11 com ajuste para preencher a tela. | [Receita Void feh](https://github.com/void-linux/void-packages/blob/master/srcpkgs/feh/template), [manual feh](https://feh.finalrewind.org/) |
| alacritty | Terminal X11 rápido, configurado por TOML. | [Receita Void Alacritty](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/alacritty/template), [formato e opções oficiais](https://alacritty.org/config-alacritty.html) |
| rofi | Launcher, janela de execução e alternador de janelas. Usa o pacote rofi do Void e o tema Rasi nativo; não depende de fork de outra distribuição. | [Receita Void Rofi](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/rofi/template), [manual Rasi](https://davatorium.github.io/rofi/CONFIGURATION/) |
| dunst | Daemon leve de notificações X11; é iniciado pela sessão i3 e usa sua sessão D-Bus. | [Receita Void Dunst](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/dunst/template), [documentação Dunst](https://dunst-project.org/documentation/) |
| i3lock | Bloqueio manual da tela com autenticação PAM; não configura suspensão ou bloqueio automático. | [Receita Void i3lock](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/i3lock/template), [projeto i3lock](https://i3wm.org/i3lock/) |
| scrot | Captura de região selecionada ou tela inteira no X11. | [Receita Void scrot](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/scrot/template), [projeto scrot](https://github.com/resurrecting-open-source-projects/scrot) |
| dbus | Fornece dbus-run-session para a sessão iniciada por startx. O instalador não habilita o serviço de barramento do sistema. | [Receita Void D-Bus](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/dbus/template), [manual Void de sessão e D-Bus](https://docs.voidlinux.org/config/session-management.html), [manual dbus-run-session](https://man.voidlinux.org/dbus-run-session.1) |
| dejavu-fonts-ttf | Fonte monoespaçada e fonte de interface usadas pelos arquivos do tema. | [Receita Void DejaVu](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/dejavu-fonts-ttf/template), [manual Void de fontes](https://docs.voidlinux.org/config/graphical-session/fonts.html) |
| alsa-utils | Fornece amixer como fallback de áudio quando wpctl/pactl não estão presentes. Não instala nem escolhe um servidor de áudio. O pacote pode instalar a definição de serviço ALSA, mas nada é habilitado pelo instalador. | [Receita Void alsa-utils](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/alsa-utils/template), [projeto ALSA](https://www.alsa-project.org/wiki/Main_Page) |
| brightnessctl | Ferramenta de brilho para dispositivos backlight compatíveis; atalhos são dependentes do hardware e das permissões do dispositivo. | [Receita Void brightnessctl](https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/brightnessctl/template), [projeto brightnessctl](https://github.com/Hummer12007/brightnessctl) |

## Consulta XBPS no Void

Sincronize os índices e consulte individualmente um pacote quando quiser confirmar o repositório e arquitetura da instalação:

    sudo xbps-install -S
    xbps-query -Rs i3
    xbps-query -Rs picom
    xbps-query -Rs alacritty

Para ver os arquivos instalados de um pacote:

    xbps-query -f i3

XBPS documenta -R para consultar os repositórios e -s para pesquisar nomes/descrições. Um pacote-fonte oficial não garante binário em todo repositório/arquitetura, por isso a consulta local é a referência final.

### Consulta Quickshell feita antes da integração

Em 24/10/2026, estes comandos foram executados nos índices XBPS locais para validar o nome do pacote e as dependências antes de incluí-lo:

```sh
xbps-query -Rs quickshell
xbps-query -R quickshell
xbps-query -R --property=run_depends quickshell
```

O primeiro retornou `quickshell-0.3.2_1` como correspondência exata no repositório `current` x86_64 (`repo-fastly.voidlinux.org`). A propriedade `run_depends` declarou `qt6-svg`, `qt6-core`, `libEGL`, `libglvnd`, `qt6-dbus`, `qt6-gui`, `qt6-network`, `qt6-declarative`, `qt6-wayland-client`, `qt6-widgets`, `cpptrace`, `libdrm`, `libgbm`, `glib`, `jemalloc`, `pam-libs`, `libpipewire`, `polkit`, `wayland` e `libxcb`, além das bibliotecas base da plataforma. Cada nome listado retornou pacote nos índices consultados por `xbps-query -R NOME`. Não adicionamos essas bibliotecas individualmente a `packages/packages.txt`: a receita binária oficial as declara e o XBPS as resolve ao instalar `quickshell`.

Para confirmar a cadeia X11 da interface Qt, também foi consultado `xbps-query -R --property=run_depends qt6-gui`. O pacote `qt6-gui` traz `libX11`, `libxcb`, `xcb-util-cursor`, `xcb-util-wm`, `xcb-util-image`, `xcb-util-keysyms`, `xcb-util-renderutil`, `libxkbcommon` e `libxkbcommon-x11`, entre outros; cada um desses nomes também retornou pacote em `xbps-query -R NOME`. O template oficial `qt6-base` habilita a integração XCB e separa os plugins de plataforma Qt no pacote `qt6-gui`. Assim, o caminho do backend X11 está coberto pela dependência Qt GUI instalada pelo próprio XBPS.

O template atual do Void declara `qt6-svg` como dependência de execução e Qt 6/Wayland como dependências de build. O guia de build upstream também lista `libxcb` para habilitar o backend X11. O Quickshell upstream documenta `PanelWindow` para X11; `WlrLayershell` e gravação de tela são recursos específicos de Wayland. A API de workspaces `Quickshell.I3`, `SystemClock`, `SystemTray` e `IpcHandler` usada aqui está documentada na versão 0.3.2. Consulte [PanelWindow](https://quickshell.org/docs/v0.3.2/types/Quickshell/PanelWindow/), [I3](https://quickshell.org/docs/v0.3.2/types/Quickshell.I3/I3/), [SystemTray](https://quickshell.org/docs/v0.3.2/types/Quickshell.Services.SystemTray/SystemTray/), [SystemClock](https://quickshell.org/docs/v0.3.2/types/Quickshell/SystemClock/) e [IpcHandler](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/IpcHandler/).

### Módulos QML das aplicações Void Shell

O gerenciador de wallpapers usa `QtQuick.Dialogs.FileDialog` para selecionar um arquivo e `Qt.labs.folderlistmodel.FolderListModel` para listar a biblioteca sem iniciar um processo de busca periódico. Ambos são módulos Qt, não pacotes XBPS próprios. A consulta `xbps-query -R -f qt6-declarative` no índice configurado listou `/usr/lib/qt6/qml/QtQuick/Dialogs/qmldir` e `/usr/lib/qt6/qml/Qt/labs/folderlistmodel/qmldir`; `qt6-declarative` já é dependência de execução indireta do pacote `quickshell`. Não foi acrescentado pacote novo à lista. `Qt.labs.folderlistmodel` é uma API experimental do Qt, portanto futuras atualizações do Qt podem exigir migração; o botão Recarregar oferece uma alternativa quando a observação de diretório não atualiza a lista.

As fontes oficiais consultadas para essas APIs são a [documentação Qt 6 de FileDialog](https://doc.qt.io/qt-6/qml-qtquick-dialogs-filedialog.html), [FolderListModel](https://doc.qt.io/qt-6/qml-qt-labs-folderlistmodel-folderlistmodel.html) e a [lista de módulos experimentais Qt Labs](https://doc.qt.io/qt-6/qtlabs-modules.html). Os processos QML usam `Quickshell.Io.Process` com argumentos separados e `StdioCollector`, conforme a [documentação Quickshell 0.3.2](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/Process/).

O i3 executa `void-quickshell-start`, que consulta `qs ipc call void ping` e inicia `qs --config void` somente quando o alvo ainda não responde. A documentação de distribuição do Quickshell recomenda uma configuração com nome sob `$XDG_CONFIG_HOME/quickshell/<nome>` e selecioná-la com `qs -c <nome>` ou `qs --config <nome>`: [Distributing Configurations](https://quickshell.org/docs/v0.3.2/guide/distribution/).

## Serviços, hardware e integrações

- startx usa dbus-run-session -- /usr/bin/i3 para iniciar um barramento de sessão limitado àquela sessão. Se o gerenciador de login já cria a sessão D-Bus, use sua entrada i3 sem outro barramento aninhado. Um barramento D-Bus do sistema é uma configuração separada do Void e não é ativado aqui.
- Picom inicia como compositor X11 junto com o i3. O blur é aplicado atrás de superfícies translúcidas; a intensidade e as regras de opacidade ficam em picom/picom.conf. O backend GLX depende do suporte do driver gráfico.
- O wallpaper é mantido em wallpapers/ e aplicado pelo script scripts/wallpaper.sh, instalado como ~/.local/bin/void-wallpaper. O script resolve o caminho do checkout para continuar funcionando depois que ele for movido.
- A barra usada é i3bar. O [Waybar upstream](https://github.com/Alexays/Waybar) documenta integração com Sway e compositores wlroots; ele não substitui a barra do i3 nesta sessão X11.
- Nenhum serviço runit é habilitado. O instalador não cria links em /var/service.
- As teclas de áudio procuram wpctl (PipeWire/WirePlumber), pactl (PulseAudio ou compatibilidade PulseAudio) e então amixer (ALSA). Somente alsa-utils é instalado pelo projeto; os outros dois comandos são opcionais e usados apenas se já estiverem no sistema.
- brightnessctl necessita de um dispositivo backlight e permissões concedidas pelo sistema. Não há ajuste de grupos feito pelo instalador.
- O status de rede apenas lê interfaces disponíveis pelo i3status. Não instala NetworkManager, ConnMan, wpa_supplicant nem substitui o gerenciador existente.
- Não são instalados tema de ícones, cursor, display manager, servidor de áudio, gerenciador de rede ou ferramenta de suspensão.
