import Quickshell
import QtQuick
import "../services" as Services

Item {
    id: root

    signal lockRequested()
    signal exitRequested()

    width: 176
    implicitWidth: 176
    implicitHeight: 42

    Row {
        id: actionRow
        anchors.fill: parent
        spacing: Services.Theme.gap

        Repeater {
            model: [
                { label: "Bloquear", action: "lock" },
                { label: "Encerrar i3", action: "exit" }
            ]

            delegate: Rectangle {
                required property var modelData
                width: (root.width - Services.Theme.gap) / 2
                height: 42
                radius: Services.Theme.radius
                color: pointer.containsMouse ? Services.Theme.elevated : Services.Theme.surface
                border.width: 1
                border.color: Services.Theme.border

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.label
                    color: parent.modelData.action === "exit"
                        ? Services.Theme.error
                        : Services.Theme.text
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 12
                }

                MouseArea {
                    id: pointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.action === "lock") root.lockRequested();
                        else root.exitRequested();
                    }
                }
            }
        }
    }
}
