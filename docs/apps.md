# Void Shell Apps

Este diretório documenta as aplicações funcionais da primeira versão do Void Shell. A interface usa QML/Quickshell 0.3.2 e integra o i3/X11 existente; não cria uma sessão Wayland.

## Theme & Wallpaper Manager

Abra pelo atalho **Super + Shift + T**, pelo dashboard ou pelo IPC:

```sh
qs ipc call void toggleThemeManager
```

O painel reúne três temas declarativos — Void Classic, Void Forest e Void Mono — e a biblioteca de imagens. O filtro pesquisa nomes; como as imagens não têm metadados de categoria, não há filtros fictícios. São aceitos PNG e JPEG. A prévia QML marca imagens inacessíveis ou inválidas, e a aplicação real é feita por `feh` no X11.

**Adicionar imagem** abre um seletor Qt, copia a escolha para `$XDG_DATA_HOME/void-shell/wallpapers` (normalmente `~/.local/share/void-shell/wallpapers`) e tenta aplicá-la. **Recarregar** atualiza a biblioteca. Para selecionar um wallpaper pelo terminal:

```sh
void-wallpaper set "/caminho/com espaços/foto.jpg"
void-wallpaper import "/caminho/com espaços/foto.jpg"
```

A escolha atual fica em `$XDG_STATE_HOME/void-shell/wallpaper`. O i3 executa `void-wallpaper` ao iniciar; se o arquivo salvo tiver sido removido, o script usa a imagem Void incluída. Os argumentos do processo são passados em posições separadas, sem montar uma linha de shell. A importação normaliza o nome e acrescenta um sufixo em caso de colisão.

Os temas estão em `themes/<id>/theme.conf`. O parser aceita somente IDs conhecidos, campos enumerados, cores hexadecimais e um caminho de wallpaper relativo validado. Arquivos de tema não executam comandos. `void-theme apply <id>` prepara os snippets em `$XDG_CONFIG_HOME/void-shell/generated/`, troca atomicamente `current-theme`, aplica o wallpaper e recarrega i3, Quickshell e Dunst quando as sessões estão disponíveis. Se o wallpaper falhar, o link e o identificador anteriores são restaurados. O estado do wallpaper só é atualizado depois de `feh` terminar com sucesso.

Os snippets gerados são consumidos por inclusões controladas do projeto:

- i3: barra nativa de recuperação e cores de janela; `i3-msg reload` é chamado ao trocar o tema.
- Quickshell: paleta semântica central lida de `current-theme/theme.json`.
- Alacritty: import TOML relativo ao arquivo principal; a recarga dinâmica depende da configuração local do terminal.
- Rofi: o `colors.rasi` gerenciado aponta para o tema ativo.
- GTK 3: CSS de seleção; aplicativos podem precisar ser reabertos.
- Dunst: drop-in `99-void-theme.conf`; `dunstctl reload` é tentado quando disponível.

Os diretórios gerados são mantidos em `generated/` para que uma troca malsucedida possa voltar ao alvo anterior. Eles contêm apenas seis pequenos arquivos declarativos por aplicação de tema; podem ser removidos manualmente depois de confirmar o tema atual. Backups de destinos que já existiam antes da instalação recebem o sufixo `.backup.DATA-HORA`.

## Shell Settings

Abra com **Super + Shift + F6**, pelo dashboard ou pelo IPC:

```sh
qs ipc call void toggleShellSettings
```

O painel controla somente opções que têm efeito real na barra: altura (32–52 px), data, indicador de rede e bandeja StatusNotifier. A gravação em `$XDG_CONFIG_HOME/void-shell/settings.json` é atômica via `FileView`/`JsonAdapter`; a barra reage sem reiniciar. Restaurar padrões grava os valores iniciais. Se o arquivo ainda não existir, os padrões continuam em memória até uma opção ser salva.

## Integração e limites atuais

O dashboard já inclui calendário, métricas de CPU/memória lidas de `/proc`, launcher Rofi, bloqueio i3lock e saída do i3 com confirmação via `i3-nagbar`. A barra mantém workspaces do i3, relógio, rota IPv4 padrão e bandeja. A integração IPC dedicada usa `Quickshell.I3` e `IpcHandler`; `qs ipc call void ping` confirma se o shell está ativo.

Esta primeira versão não implementa mixer gráfico, controle de brilho, lista de redes, bateria, central de notificações, workspace overview nem gerenciador de energia de sessão. As teclas de áudio/brilho existentes continuam usando os backends instalados ou já disponíveis. A indicação de rede significa “rota IPv4 padrão encontrada”, não conectividade com a Internet. O launcher continua sendo Rofi, que descobre os aplicativos instalados.

O tema pode ser preparado sem uma sessão X11 com `void-theme prepare void-classic`. Aplicar o tema e o wallpaper requer `DISPLAY`, `feh` e acesso ao root window do X11. `PanelWindow` é a janela de barra documentada para o Quickshell, mas foco, posicionamento, bandeja e interação com i3 precisam de validação na sessão gráfica real deste usuário. Quickshell `WlrLayershell` continua sendo específico de Wayland e não é usado aqui.

## Recuperação

- Mostrar a barra nativa do i3: `qs ipc call void stopShell`, depois `i3-msg bar mode dock`.
- Reativar a barra Quickshell: `i3-msg bar mode hide` e `~/.local/bin/void-quickshell-start`.
- Restaurar um tema incluído: `void-theme apply void-classic` dentro da sessão X11.
- Se não houver sessão gráfica, `void-theme prepare void-classic`, depois `i3-msg reload` e `qs ipc call void refreshTheme` ao entrar na sessão; o wallpaper é restaurado no próximo início do i3.
- Diagnosticar o shell: `qs ipc call void ping`, `qs log` e `qs --help`.
- Recuperar arquivos originais: revise os links e restaure o backup `.backup.DATA-HORA` correspondente. Não apague o checkout enquanto `~/.config/quickshell/void` ainda apontar para ele.

## Referências consultadas

- [Quickshell 0.3.2: PanelWindow](https://quickshell.org/docs/v0.3.2/types/Quickshell/PanelWindow/), [Process](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/Process/), [FileView](https://quickshell.org/docs/v0.3.2/types/Quickshell.Io/FileView/) e [FAQ sobre IPC/i3](https://quickshell.org/docs/v0.3.2/guide/faq/).
- [Qt 6: FileDialog](https://doc.qt.io/qt-6/qml-qtquick-dialogs-filedialog.html) e [FolderListModel](https://doc.qt.io/qt-6/qml-qt-labs-folderlistmodel-folderlistmodel.html). A receita Void do `qt6-declarative`, dependência transitiva do Quickshell consultado, inclui os dois módulos QML.
- [Manual i3: includes e escopo de variáveis](https://i3wm.org/docs/userguide.html#_include_directive).
- [Omarchy: organização de temas](https://github.com/omacom/omarchy/blob/quattro/docs/theming.md) e [seleção de temas e backgrounds](https://github.com/omacom/omarchy/blob/quattro/manual/06-themes.md). A referência é a experiência de temas coesos e wallpapers por tema; nenhum script, arquivo ou dependência do Omarchy foi copiado.
