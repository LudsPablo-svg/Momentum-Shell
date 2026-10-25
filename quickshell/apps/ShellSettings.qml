import Quickshell
import QtQuick
import "../components" as Components
import "../services" as Services

PanelWindow {
    id: root

    property bool open: false
    property var targetScreen: null
    signal closeRequested()
    signal themeManagerRequested()

    function adjustHeight(amount: int): void {
        Services.Settings.setBarHeight(Services.Settings.barHeight + amount);
    }

    screen: root.targetScreen !== null
        ? root.targetScreen
        : (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null)
    visible: root.open
    focusable: true
    aboveWindows: true
    anchors {
        top: true
        right: true
    }
    margins {
        top: Services.Settings.barHeight + 10
        right: 12
    }
    implicitWidth: 560
    implicitHeight: 640
    exclusiveZone: 0

    Rectangle {
        anchors.fill: parent
        color: Services.Theme.background
        border.width: 1
        border.color: Services.Theme.border
        radius: 14
    }

    Column {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 13

        Components.AppHeader {
            width: parent.width
            title: "Ajustes do Quickshell"
            onCloseRequested: root.closeRequested()
        }

        Text {
            width: parent.width
            text: "Preferências persistentes em settings.json. A barra responde às mudanças imediatamente."
            color: Services.Theme.muted
            font.family: Services.Theme.fontUi
            font.pixelSize: 10
            wrapMode: Text.WordWrap
        }

        Rectangle {
            width: parent.width
            height: 88
            radius: Services.Theme.radius
            color: Services.Theme.surface
            border.width: 1
            border.color: Services.Theme.border

            Row {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Column {
                    width: parent.width - 148
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        text: "Aparência e tema"
                        color: Services.Theme.text
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Text {
                        width: parent.width
                        text: Services.Theme.activeName + " · " + Services.Theme.activeDescription
                        color: Services.Theme.muted
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 9
                        wrapMode: Text.WordWrap
                    }
                }

                Components.ActionButton {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 132
                    implicitWidth: 132
                    text: "Abrir temas"
                    secondary: true
                    onClicked: {
                        root.closeRequested();
                        root.themeManagerRequested();
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 112
            radius: Services.Theme.radius
            color: Services.Theme.surface
            border.width: 1
            border.color: Services.Theme.border

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    text: "BARRA"
                    color: Services.Theme.accent
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                Row {
                    width: parent.width
                    height: 38
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Altura"
                        color: Services.Theme.text
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 11
                    }

                    Item { width: parent.width - 240; height: 1 }

                    Components.ActionButton {
                        width: 32
                        implicitWidth: 32
                        implicitHeight: 30
                        text: "−"
                        secondary: true
                        enabled: Services.Settings.barHeight > 32
                        onClicked: root.adjustHeight(-2)
                    }

                    Text {
                        width: 48
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: Services.Settings.barHeight + " px"
                        color: Services.Theme.text
                        font.family: Services.Theme.fontMono
                        font.pixelSize: 10
                    }

                    Components.ActionButton {
                        width: 32
                        implicitWidth: 32
                        implicitHeight: 30
                        text: "+"
                        secondary: true
                        enabled: Services.Settings.barHeight < 52
                        onClicked: root.adjustHeight(2)
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 172
            radius: Services.Theme.radius
            color: Services.Theme.surface
            border.width: 1
            border.color: Services.Theme.border

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 2

                Text {
                    text: "MÓDULOS DA BARRA"
                    color: Services.Theme.accent
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                Components.SettingToggle {
                    width: parent.width
                    title: "Data no relógio"
                    description: "Mantém a hora e oculta a segunda linha de data."
                    checked: Services.Settings.showDate
                    onToggled: Services.Settings.setShowDate(checked)
                }

                Components.SettingToggle {
                    width: parent.width
                    title: "Indicador de rede"
                    description: "Mostra a interface com rota IPv4 padrão."
                    checked: Services.Settings.showNetwork
                    onToggled: Services.Settings.setShowNetwork(checked)
                }

                Components.SettingToggle {
                    width: parent.width
                    title: "Bandeja do sistema"
                    description: "Exibe itens StatusNotifier publicados por aplicativos."
                    checked: Services.Settings.showTray
                    onToggled: Services.Settings.setShowTray(checked)
                }
            }
        }

        Row {
            width: parent.width
            height: 38
            spacing: 10

            Components.ActionButton {
                id: defaultsButton
                text: "Restaurar padrões"
                secondary: true
                onClicked: Services.Settings.restoreDefaults()
            }

            Item {
                width: Math.max(0, parent.width - defaultsButton.width - saveStatus.width
                                - parent.spacing * 2)
                height: 1
            }

            Text {
                id: saveStatus
                width: 205
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: Services.Settings.saveStatus
                color: Services.Settings.saveStatus.indexOf("Falha") >= 0
                    ? Services.Theme.error
                    : Services.Theme.muted
                font.family: Services.Theme.fontUi
                font.pixelSize: 9
                elide: Text.ElideRight
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Services.Theme.border
        }

        Text {
            width: parent.width
            text: "Sessão: i3 / X11    ·    Tema: " + Services.Theme.activeId
            color: Services.Theme.muted
            font.family: Services.Theme.fontMono
            font.pixelSize: 9
        }
    }
}
