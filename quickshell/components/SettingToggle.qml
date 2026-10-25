import QtQuick
import "../services" as Services

Item {
    id: root

    property string title: ""
    property string description: ""
    property bool checked: false
    signal toggled(bool checked)

    implicitHeight: 48
    height: implicitHeight

    Column {
        anchors.left: parent.left
        anchors.right: toggle.left
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: root.title
            color: Services.Theme.text
            font.family: Services.Theme.fontUi
            font.pixelSize: 11
            font.bold: true
        }

        Text {
            width: parent.width
            text: root.description
            color: Services.Theme.muted
            font.family: Services.Theme.fontUi
            font.pixelSize: 9
            elide: Text.ElideRight
        }
    }

    Rectangle {
        id: toggle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 42
        height: 23
        radius: 12
        color: root.checked ? Services.Theme.accentDark : Services.Theme.elevated
        border.width: 1
        border.color: root.checked ? Services.Theme.accent : Services.Theme.border

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 3
            width: 17
            height: 17
            radius: 9
            color: root.checked ? Services.Theme.accent : Services.Theme.muted
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        activeFocusOnTab: true
        Accessible.role: Accessible.CheckBox
        Accessible.name: root.title
        Accessible.checked: root.checked
        Keys.onSpacePressed: root.toggled(!root.checked)
        Keys.onReturnPressed: root.toggled(!root.checked)
        onClicked: root.toggled(!root.checked)
    }
}
