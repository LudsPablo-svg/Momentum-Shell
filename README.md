# Void Linux i3 + Quickshell

Dotfiles para uma sessão desktop X11 com i3 no Void Linux. O projeto mantém o i3 como gerenciador de janelas e usa Quickshell para a barra, o dashboard e aplicações próprias de temas, wallpapers e preferências. A identidade visual combina carvão e grafite com verde Void para foco e ações principais.

## Aparência e arquitetura

| Função | Componente |
| --- | --- |
| Janelas, atalhos e workspaces | i3 |
| Barra, bandeja, relógio, dashboard e apps Void Shell | Quickshell 0.3.2, QML |
| Barra de recuperação | i3bar + i3status, incluídos e ocultos por padrão |
| Launcher | Rofi |
| Terminal | Alacritty |
| Compositor X11 | Picom |
| Notificações | Dunst |
| Wallpaper | feh e a imagem Void incluída em `wallpapers/` |

O Quickshell tem suporte de janelas X11 e inclui integração IPC com i3. A barra usa `PanelWindow` e o dashboard acompanha o monitor focado no i3. O instalador ativa essa configuração sem migrar para Wayland. A API `WlrLayershell` é específica de Wayland; o projeto não usa essa API no i3/X11. O comportamento visual e o posicionamento ainda precisam de validação numa sessão real do Void com o hardware gráfico local.

A paleta semântica é centralizada em `quickshell/services/Theme.qml` e carregada do tema ativo. Void Classic usa fundo `#1B1B1B`, superfícies `#252525` e `#303030`, borda `#404040`, texto `#E0E0E0`, texto secundário `#A0A0A0` e verde `#80B918`. Os temas também geram os snippets nativos do i3, Alacritty, Rofi, Dunst e GTK.

## Barra e dashboard

A barra mostra os seis workspaces configurados no i3, destaca o workspace ativo por monitor, apresenta data e hora, indica a interface com rota IPv4 padrão e hospeda itens de bandeja StatusNotifier quando existem. Clique no relógio ou na marca VOID para abrir o dashboard.

O dashboard inclui relógio ampliado, calendário, carga média de CPU, uso de memória, uptime, launcher, bloqueio de tela e encerramento do i3. As métricas vêm de `/proc` e são atualizadas apenas enquanto o painel está aberto; a rota IPv4 é lida em intervalos de 15 segundos. A indicação de rede confirma apenas a presença de uma rota IPv4 padrão, não acesso à Internet. A primeira versão não inclui bateria nem controle gráfico de áudio: não instala UPower, servidor de áudio ou gerenciador de rede. As teclas multimídia continuam usando `scripts/volume.sh` e `scripts/brightness.sh` conforme os backends e o hardware disponíveis.

## Aplicações Void Shell

O **Theme & Wallpaper Manager** alterna entre Void Classic, Void Forest e Void Mono, pesquisa imagens por nome, mostra uma prévia e aplica a seleção ao root window do X11 via feh. A escolha persiste entre sessões; imagens próprias são copiadas para a biblioteca XDG do usuário. **Shell Settings** grava altura da barra, data, rede e bandeja em JSON e aplica essas opções imediatamente. Os dois painéis também abrem pelo dashboard.

Atalhos: **Super + Shift + T** abre temas e wallpapers; **Super + Shift + F6** abre os ajustes. Comandos, persistência, integração e limites estão em [docs/apps.md](docs/apps.md). O launcher continua no Rofi e o dashboard mantém as métricas atuais; mixer gráfico, bateria, notificações centralizadas e controle de rede não fazem parte desta versão.

## Requisitos e dependências

- Void Linux com repositórios XBPS configurados e sessão X11.
- i3, Xorg e uma sessão D-Bus; o instalador instala `xorg`, `i3`, `dbus` e `xinit`.
- Usuário normal com `sudo` configurado para executar `xbps-install`.
- Quickshell `0.3.2` e dependências Qt/X11 fornecidas pelo pacote oficial do Void.
- `qs`, i3, i3status, Picom, feh, Alacritty, Rofi, Dunst, i3lock, scrot, DejaVu Sans e `alsa-utils` estão listados em `packages/packages.txt`.

O pacote Quickshell foi encontrado nos índices XBPS x86_64 consultados: `quickshell-0.3.2_1`, repositório `current`. A consulta de dependências diretas do pacote inclui os módulos Qt 6, `libxcb`, Wayland client, PipeWire, Polkit e bibliotecas gráficas. O Quickshell do repositório oficial é compilado com suporte a X11; XBPS resolve as dependências declaradas automaticamente. O instalador não habilita serviços runit, não adiciona repositórios e não instala um servidor de áudio ou rede. Veja [docs/dependencies.md](docs/dependencies.md) para as consultas e referências.

O Quickshell ainda pode mudar APIs antes da versão 1.0. Valide a configuração QML depois de atualizações do pacote; o número consultado aqui descreve o estado dos índices XBPS deste ambiente, não uma versão fixada pelo instalador.

## Instalação

Clone o repositório num caminho permanente, pois as configurações apontam para este checkout:

```sh
git clone URL_DO_SEU_REPOSITORIO ~/Projetos/void-i3-dotfiles
cd ~/Projetos/void-i3-dotfiles
./install.sh
```

Execute como usuário normal, sem `sudo` no script. O instalador usa `sudo` apenas no XBPS. Ele instala os pacotes da lista, cria links para as configurações e scripts auxiliares e move destinos existentes para arquivos `.backup.DATA-HORA` antes de substituí-los. Reexecutá-lo atualiza os links já gerenciados e não cria entradas duplicadas.

O instalador configura `~/.config/quickshell/void` como link para `quickshell/` no checkout, prepara a biblioteca XDG de imagens e instala os comandos `void-quickshell-start`, `void-theme` e `void-wallpaper` em `~/.local/bin`. Também prepara o tema Void Classic na primeira instalação; em uma reinstalação, preserva o tema selecionado. Inicie ou reinicie a sessão i3 para carregar o Quickshell. Para iniciar pelo console, `x11/xinitrc` executa `dbus-run-session -- /usr/bin/i3`; o i3 chama o wrapper, que consulta o alvo IPC `void` antes de executar `qs --config void`, evitando iniciar uma segunda instância durante recargas. O instalador só cria `~/.xinitrc` quando ele ainda não existe; se você já tem esse arquivo, integre a linha de sessão D-Bus sem remover suas inicializações.

O projeto não instala nem habilita display manager, serviço de áudio, gerenciador de rede ou serviço runit. `xorg` instala a base Xorg e drivers livres; GPUs que exigem driver proprietário precisam da configuração apropriada do sistema local.

## Atalhos principais

Super é a tecla Windows/Command.

| Atalho | Ação |
| --- | --- |
| Super + Enter | Abrir Alacritty |
| Super + D | Abrir Rofi |
| Super + Shift + D | Abrir/fechar o dashboard |
| Super + Shift + T | Abrir/fechar Theme & Wallpaper Manager |
| Super + Shift + F6 | Abrir/fechar Shell Settings |
| Super + Shift + F5 | Recarregar a configuração Quickshell |
| Super + H/J/K/L ou setas | Mover o foco |
| Super + Shift + H/J/K/L ou setas | Mover janela |
| Super + 1…6 | Alternar workspace |
| Super + Shift + 1…6 | Enviar janela para workspace |
| Super + E | Alternar orientação de divisão |
| Super + S / W | Layout empilhado / abas |
| Super + R | Entrar no modo de redimensionamento; Escape ou Enter sai |
| Super + F | Alternar tela cheia |
| Super + Shift + Space | Alternar janela flutuante |
| Super + Ctrl + L | Bloquear a tela |
| Super + Shift + C | Recarregar a configuração i3 |
| Super + Shift + R | Reiniciar i3 |
| Super + Shift + E | Abrir confirmação de saída do i3 |
| Print / Super + Print | Captura de região / tela inteira |
| Teclas de volume e brilho | Ajustar áudio e brilho quando backend/hardware oferecer suporte |
| Super + Shift + I | Mostrar informações do sistema no terminal |

Escape também fecha o dashboard quando ele está focado. Clique no relógio ou em VOID para abri-lo.

## Atualizar e personalizar

Os arquivos instalados são links para o checkout. Atualize e reaplique assim:

```sh
cd ~/Projetos/void-i3-dotfiles
git pull --ff-only
./install.sh
```

Quickshell observa alterações QML e recarrega a configuração. Também é possível usar Super + Shift + F5 ou `qs ipc call void reloadShell`. Recarregue o i3 com Super + Shift + C. Para Picom, use `pkill -USR1 picom`.

Edite os arquivos no checkout:

- `themes/<id>/theme.conf`: paleta, nome, descrição e wallpaper padrão dos temas incluídos.
- `quickshell/services/Theme.qml`: paleta ativa, tipografia, espaçamento e cantos do Quickshell.
- `quickshell/services/Settings.qml`: valores padrão e opções persistidas da barra; preferências do usuário ficam em `$XDG_CONFIG_HOME/void-shell/settings.json`.
- `quickshell/apps/`: gerenciador de temas/wallpapers e painel de configurações.
- `quickshell/components/` e `quickshell/widgets/`: barra, bandeja, workspaces, dashboard e ações de sessão.
- `i3/config`: atalhos, bordas, gaps e integração com `i3/current-theme.conf`.
- `bar/i3status.conf`: status usado pela barra i3bar de recuperação.
- `terminal/alacritty.toml`, `rofi/`, `notifications/`, `gtk/` e `picom/`: aparência dos outros componentes.
- `wallpapers/`: imagens incluídas; imagens pessoais ficam em `$XDG_DATA_HOME/void-shell/wallpapers`.

Para aplicar um tema pelo terminal na sessão X11, use `void-theme list` e `void-theme apply void-forest`. Para aplicar outro wallpaper, use `void-wallpaper set "/caminho/com espaços/imagem.jpg"`. As configurações geradas ficam em `$XDG_CONFIG_HOME/void-shell/`; os arquivos fonte e os metadados seguem centralizados neste checkout.

O GTK recebe preferência por aparência escura e seleção verde, mas o projeto não instala um tema GTK ou pacote de ícones. Aplicações GTK 4, Qt e programas que não seguem essas preferências podem exigir configuração própria.

## Barra de recuperação e desativação

O i3bar continua configurado com i3status e fica oculto enquanto o Quickshell ocupa a barra. Para trocar temporariamente para a barra nativa, encerre a instância atual e mostre a barra:

```sh
qs ipc call void stopShell
i3-msg bar mode dock
```

Para iniciar Quickshell outra vez, oculte o i3bar e execute:

```sh
i3-msg bar mode hide
qs --config void
```

Se quiser voltar permanentemente ao i3bar, remova ou comente `exec --no-startup-id ~/.local/bin/void-quickshell-start` em `i3/config` e altere `mode hide` para `mode dock` no bloco `void-i3-fallback`; depois recarregue o i3. A configuração Quickshell e o pacote permanecem disponíveis.

Para desfazer links, confira cada destino com `readlink` e remova apenas links que apontem para este checkout. Restaure o arquivo anterior movendo o backup `.backup.DATA-HORA` correspondente para o destino original. O instalador não remove pacotes.

## Verificações e diagnóstico

Execute no checkout:

```sh
bash -n install.sh scripts/*.sh
git diff --check
i3 -C -c i3/config
```

Se `qmllint` estiver disponível no sistema, valide os arquivos QML com ele e com o caminho de importação do Quickshell. Confira também `qs --help` e teste numa sessão X11/i3. `QtQuick.Dialogs` e `Qt.labs.folderlistmodel` são fornecidos pelo `qt6-declarative`, dependência transitiva do Quickshell no repositório consultado; não são pacotes XBPS adicionais do projeto. A validação de sintaxe do i3 e do Bash não substitui a execução real da barra, das janelas, da bandeja e das ações sobre o wallpaper.

Para problemas comuns, veja [docs/troubleshooting.md](docs/troubleshooting.md). Consultas XBPS, dependências e fontes oficiais estão em [docs/dependencies.md](docs/dependencies.md).
