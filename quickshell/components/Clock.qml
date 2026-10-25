import Quickshell
import QtQuick
import "../services" as Services

Item {
    id: root

    signal clicked()
    implicitWidth: clockText.implicitWidth + 20
    implicitHeight: Services.Settings.barHeight
    width: implicitWidth
    height: implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        anchors.centerIn: parent
        spacing: 0

        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Services.Theme.text
            font.family: Services.Theme.fontMono
            font.pixelSize: 13
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "ddd dd MMM")
            color: Services.Theme.muted
            font.family: Services.Theme.fontUi
            font.pixelSize: 9
            visible: Services.Settings.showDate
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
