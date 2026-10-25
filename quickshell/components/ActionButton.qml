import QtQuick
import "../services" as Services

Rectangle {
    id: root

    property string text: ""
    property bool secondary: false
    signal clicked()

    implicitWidth: Math.max(92, label.implicitWidth + 28)
    implicitHeight: 38
    width: implicitWidth
    height: implicitHeight
    radius: Services.Theme.radius
    color: !root.enabled
        ? Services.Theme.surface
        : pointer.containsMouse
            ? (secondary ? Services.Theme.elevated : Services.Theme.accentDark)
            : (secondary ? Services.Theme.surface : Services.Theme.accent)
    border.width: secondary ? 1 : 0
    border.color: Services.Theme.border
    opacity: root.enabled ? 1 : 0.55

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.secondary ? Services.Theme.text : Services.Theme.background
        font.family: Services.Theme.fontUi
        font.pixelSize: 12
        font.bold: true
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        activeFocusOnTab: true
        Accessible.role: Accessible.Button
        Accessible.name: root.text
        Keys.onSpacePressed: root.clicked()
        Keys.onReturnPressed: root.clicked()
        onClicked: root.clicked()
    }
}
