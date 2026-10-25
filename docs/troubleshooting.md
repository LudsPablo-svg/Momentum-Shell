# Solução de problemas

## startx volta ao console ou não abre o i3

Confirme que os pacotes xorg e xinit estão instalados, que há um driver compatível com a GPU e que existe um arquivo ~/.xinitrc. Este projeto cria esse link apenas se o caminho estiver ausente:

    readlink ~/.xinitrc
    cat ~/.xinitrc

Se você já tinha ~/.xinitrc, mantenha suas inicializações e use exec dbus-run-session -- /usr/bin/i3 como última linha quando ainda não houver sessão D-Bus. O manual do Void cobre drivers e a inicialização por startx em [Xorg](https://docs.voidlinux.org/config/graphical-session/xorg.html).

## A sessão gráfica abre, mas faltam notificações

Dunst precisa de uma sessão D-Bus. A configuração gerenciada do xinitrc cria uma ao iniciar o i3. Ao usar um gerenciador de login, verifique se a sessão exporta DBUS_SESSION_BUS_ADDRESS. Não habilite o serviço D-Bus de sistema indiscriminadamente: ele é diferente do barramento de sessão.

## A barra Quickshell ou o dashboard não aparecem

Confirme se o pacote e o comando estão disponíveis, se o link nomeado aponta para este checkout e se o i3 tem um socket IPC acessível:

```sh
command -v qs
readlink -f ~/.config/quickshell/void
qs --config void
i3-msg -t get_workspaces
```

O projeto requer a configuração Quickshell 0.3.2 ou posterior compatível com os imports usados. No i3, Super + Shift + F5 chama a recarga Quickshell pelo IPC; salvar arquivos QML também ativa o reload automático do Quickshell. Super + Shift + C recarrega apenas a configuração i3. Verifique o log no terminal em que `qs --config void` foi iniciado se houver erro de QML ou do plugin de plataforma Qt.

O Quickshell precisa iniciar dentro da sessão X11 e da sessão D-Bus do i3. Uma variável `QT_QPA_PLATFORM` forçada para `wayland` pode impedir o uso do backend X11. `PanelWindow` usa o suporte X11 do Quickshell; os recursos específicos `WlrLayershell` não se aplicam a esta sessão.

Se o painel ficar numa posição incorreta no X11, a documentação do Quickshell lista `QS_NO_XINERAMA_STRUTS=1` como workaround experimental para struts Xinerama. Essa opção pode corrigir ou agravar o posicionamento; teste-a apenas temporariamente e remova-a se não ajudar. Veja [Advanced Options](https://quickshell.org/docs/v0.3.2/guide/advanced/).

## Restaurar a barra i3bar

Se o Quickshell responde ao IPC, pare a instância e mostre a barra de recuperação:

```sh
qs ipc call void stopShell
i3-msg bar mode dock
```

Para retornar à barra Quickshell:

```sh
i3-msg bar mode hide
qs --config void
```

Se o IPC do Quickshell estiver indisponível, encerre a sessão i3 e inicie novamente depois de comentar o comando de autostart do Quickshell e alterar `mode hide` para `mode dock` em `i3/config`.

## Ícones da bandeja não aparecem

O componente apresenta clientes StatusNotifier que se registrarem na sessão D-Bus. Se a sessão foi iniciada sem barramento de sessão, use o `x11/xinitrc` do projeto ou confirme que o gerenciador de login exporta `DBUS_SESSION_BUS_ADDRESS`. A ausência de clientes registrados deixa a área da bandeja vazia.

## Indicador de rede mostra traço

O indicador consulta a tabela `/proc/net/route` e mostra apenas interfaces com rota IPv4 padrão ativa. O traço significa que nenhuma rota desse tipo foi encontrada; conexões apenas IPv6 não aparecem nesse indicador. Ele não testa conectividade externa e não altera o gerenciador de rede do sistema.

## O wallpaper não aparece

Confirme se o pacote feh está instalado e se o link do script aponta para este checkout. Execute o script manualmente para ver qualquer mensagem de erro:

    command -v feh
    readlink -f ~/.local/bin/void-wallpaper
    ~/.local/bin/void-wallpaper

Sem argumento, o script restaura a última imagem salva e usa `wallpapers/wallhaven-ogg3em_3840x2160.png` como fallback. As imagens pessoais importadas ficam em `$XDG_DATA_HOME/void-shell/wallpapers`; o caminho aplicado é persistido em `$XDG_STATE_HOME/void-shell/wallpaper`.

O gerenciador aceita PNG e JPEG. Tente a aplicação direta e veja a mensagem real de `feh`:

```sh
void-wallpaper set "/caminho/com espaços/foto.jpg"
void-wallpaper import "/caminho/com espaços/foto.jpg"
```

O tema escolhido por `void-theme apply` também aplica o wallpaper padrão daquele tema. Para apenas preparar os arquivos e testar o parser sem uma sessão X11, use `void-theme prepare void-classic`.

## O tema do Quickshell não muda ou uma preferência não persiste

O caminho `~/.config/void-shell/current-theme` deve ser um link para um diretório em `generated/`; os arquivos gerados correspondem ao tema ativo. `void-theme apply <id>` aplica o tema e recarrega os componentes disponíveis dentro da sessão X11. Se o Quickshell estiver ativo, confira o IPC e o arquivo atual:

```sh
qs ipc call void ping
readlink -f ~/.config/void-shell/current-theme
cat ~/.config/void-shell/settings.json
```

Se `XDG_CONFIG_HOME` ou `XDG_STATE_HOME` estiver personalizado, use esse caminho no lugar de `~/.config` ou `~/.local/state`. Aplicativos GTK e janelas Alacritty já abertas podem precisar ser reabertos. Para restaurar as opções do shell, use **Restaurar padrões** em Super + Shift + F6.

Se as cores do i3 falharem ao recarregar, confira o snippet gerado pelo tema e valide o arquivo ativo:

```sh
readlink -f ~/.config/i3/current-theme.conf
i3 -C -c ~/.config/i3/config
```

Os nomes dos arquivos podem variar quando `XDG_CONFIG_HOME` foi definido.

## Transparência ou blur não aparecem

Confirme se Picom está rodando e recarregue sua configuração:

    pgrep -a picom
    pkill -USR1 picom

O blur aparece atrás de superfícies translúcidas. Picom usa o backend GLX e pode precisar de suporte compatível do driver gráfico.

## Áudio não muda com as teclas

O script seleciona o primeiro backend encontrado: wpctl, pactl ou amixer. Confira qual ferramenta existe e se há um sink/controle:

    command -v wpctl
    command -v pactl
    amixer scontrols

Se o sistema usa PipeWire ou PulseAudio, mantenha o serviço e a configuração atuais e confirme que a ferramenta de controle correspondente está instalada. Para ALSA direta, confira se existe controle Master, PCM, Speaker ou Headphone.

## Brilho não muda

Nem todo computador expõe um backlight compatível. Liste os dispositivos disponíveis e confira as mensagens de permissão:

    brightnessctl -l
    brightnessctl set +5%

Monitores externos normalmente não aparecem como backlight do kernel; esta configuração não adiciona ferramentas de controle DDC.

## Rofi abre sem aplicativos

O modo Apps lista aplicações que fornecem arquivos .desktop. O modo Run continua disponível para executar um comando. Use Super + D e comece a digitar.

## Configuração alterada não aparece

Os links em ~/.config apontam para o checkout. Confirme o destino e recarregue o i3 com Super + Shift + C. Alacritty e Dunst podem exigir reinício do respectivo processo.

    readlink ~/.config/i3/config
    readlink ~/.config/rofi/config.rasi

Se moveu o checkout para outro diretório, os links existentes podem ficar quebrados. Execute install.sh no novo caminho para salvar esses links antigos e criar novos.

## Arquivo anterior precisa ser recuperado

Antes de instalar, cada arquivo substituído é movido para o mesmo diretório com sufixo .backup.DATA-HORA. Localize o backup e mova-o de volta ao nome original depois de remover o link do projeto.

    ls -la ~/.config/i3
    readlink ~/.config/i3/config
