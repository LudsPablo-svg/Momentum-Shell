import Quickshell
import QtQuick
import "../services" as Services
import "../components" as Components

PanelWindow {
    id: root

    property var targetScreen: null
    property bool open: false
    signal closeRequested()
    signal themeManagerRequested()
    signal settingsRequested()

    screen: root.targetScreen
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
    implicitWidth: 360
    implicitHeight: 600
    exclusiveZone: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Item {
        id: dashboardContent
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: root.closeRequested()

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Services.Theme.background
            border.width: 1
            border.color: Services.Theme.border
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            Row {
                width: parent.width
                height: 20

                Text {
                    id: panelTitle
                    text: "PAINEL"
                    color: Services.Theme.accent
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 11
                    font.bold: true
                }

                Item {
                    width: parent.width - panelTitle.implicitWidth - closeLabel.implicitWidth
                }

                Text {
                    id: closeLabel
                    text: "FECHAR  ×"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 10

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.closeRequested()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 2

                Text {
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    color: Services.Theme.text
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 38
                    font.bold: true
                }

                Text {
                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 12
                }
            }

            Rectangle {
                width: parent.width
                height: calendarCard.implicitHeight
                radius: Services.Theme.radius
                color: Services.Theme.surface
                border.width: 1
                border.color: Services.Theme.border

                Column {
                    id: calendarCard
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    readonly property int firstWeekday:
                        new Date(clock.date.getFullYear(), clock.date.getMonth(), 1).getDay()
                    readonly property int daysInMonth:
                        new Date(clock.date.getFullYear(), clock.date.getMonth() + 1, 0).getDate()

                    Text {
                        text: Qt.formatDateTime(clock.date, "MMMM yyyy")
                        color: Services.Theme.text
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 13
                        font.bold: true
                    }

                    Grid {
                        columns: 7
                        rowSpacing: 2
                        columnSpacing: 2

                        Repeater {
                            model: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]

                            delegate: Text {
                                required property string modelData
                                width: 40
                                height: 22
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                text: modelData
                                color: Services.Theme.muted
                                font.family: Services.Theme.fontUi
                                font.pixelSize: 9
                            }
                        }

                        Repeater {
                            model: 42

                            delegate: Item {
                                required property int index
                                readonly property int day:
                                    index - calendarCard.firstWeekday + 1
                                readonly property bool inMonth:
                                    day >= 1 && day <= calendarCard.daysInMonth
                                readonly property bool today:
                                    inMonth && day === clock.date.getDate()

                                width: 40
                                height: 25

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: parent.today ? Services.Theme.accent : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.inMonth ? String(parent.day) : ""
                                    color: parent.today ? Services.Theme.background : Services.Theme.text
                                    font.family: Services.Theme.fontMono
                                    font.pixelSize: 10
                                    font.bold: parent.today
                                }
                            }
                        }
                    }
                }
            }

            SystemMonitor {
                width: parent.width
                active: root.open
            }

            Row {
                width: parent.width
                height: 38
                spacing: Services.Theme.gap

                Rectangle {
                    width: 140
                    height: parent.height
                    radius: Services.Theme.radius
                    color: launchPointer.containsMouse
                        ? Services.Theme.accentDark
                        : Services.Theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: "Aplicativos"
                        color: Services.Theme.background
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 12
                        font.bold: true
                    }

                    MouseArea {
                        id: launchPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.closeRequested();
                            Quickshell.execDetached(["rofi", "-show", "drun", "-show-icons"]);
                        }
                    }
                }

                PowerMenu {
                    onLockRequested: {
                        root.closeRequested();
                        Quickshell.execDetached(["i3lock", "--color=1B1B1B"]);
                    }
                    onExitRequested: {
                        root.closeRequested();
                        Quickshell.execDetached([
                            "i3-nagbar", "-t", "warning", "-m", "Encerrar a sessão i3?",
                            "-B", "Encerrar", "i3-msg exit"
                        ]);
                    }
                }
            }

            Row {
                width: parent.width
                height: 38
                spacing: Services.Theme.gap

                Components.ActionButton {
                    width: (parent.width - Services.Theme.gap) / 2
                    text: "Temas e wallpapers"
                    secondary: true
                    onClicked: {
                        root.closeRequested();
                        root.themeManagerRequested();
                    }
                }

                Components.ActionButton {
                    width: (parent.width - Services.Theme.gap) / 2
                    text: "Ajustes do shell"
                    secondary: true
                    onClicked: {
                        root.closeRequested();
                        root.settingsRequested();
                    }
                }
            }

            Item { width: 1; height: 1 }
        }
    }
}
