import Quickshell.I3
import QtQuick
import "../services" as Services

Item {
    id: root

    property var screen: null
    readonly property var monitor: screen === null ? null : I3.monitorFor(screen)
    readonly property int activeNumber: {
        if (monitor && monitor.activeWorkspace) {
            return monitor.activeWorkspace.number;
        }
        return I3.focusedWorkspace ? I3.focusedWorkspace.number : -1;
    }

    implicitWidth: workspaceRow.implicitWidth
    implicitHeight: Services.Settings.barHeight
    width: implicitWidth
    height: implicitHeight

    Row {
        id: workspaceRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        Repeater {
            model: [1, 2, 3, 4, 5, 6]

            delegate: Rectangle {
                required property int modelData
                readonly property var workspace: I3.findWorkspaceByName(String(modelData))
                readonly property bool selected: root.activeNumber === modelData
                readonly property bool urgent: workspace ? workspace.urgent : false

                width: 30
                height: 28
                radius: 6
                color: selected ? Services.Theme.accent : "transparent"
                border.width: urgent && !selected ? 1 : 0
                border.color: Services.Theme.error

                Text {
                    anchors.centerIn: parent
                    text: String(modelData)
                    color: parent.selected ? Services.Theme.background : Services.Theme.text
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 12
                    font.bold: parent.selected || parent.urgent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: I3.dispatch("workspace number " + modelData)
                }
            }
        }
    }
}
