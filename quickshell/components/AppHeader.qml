import QtQuick
import "../services" as Services

Item {
    id: root

    property string title: ""
    property string section: "VOID SHELL APPS"
    signal closeRequested()

    implicitHeight: 50
    height: implicitHeight

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: root.section
            color: Services.Theme.accent
            font.family: Services.Theme.fontMono
            font.pixelSize: 9
            font.bold: true
        }

        Text {
            text: root.title
            color: Services.Theme.text
            font.family: Services.Theme.fontUi
            font.pixelSize: 18
            font.bold: true
        }
    }

    Text {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: "FECHAR  ×"
        color: closePointer.containsMouse ? Services.Theme.text : Services.Theme.muted
        font.family: Services.Theme.fontMono
        font.pixelSize: 10

        MouseArea {
            id: closePointer
            anchors.fill: parent
            anchors.margins: -8
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.closeRequested()
        }
    }
}
