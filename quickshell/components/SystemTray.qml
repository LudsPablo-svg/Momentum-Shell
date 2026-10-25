import Quickshell.Services.SystemTray
import QtQuick

Item {
    id: root

    property var panelWindow
    implicitWidth: trayRow.implicitWidth
    implicitHeight: 30
    width: implicitWidth
    height: implicitHeight

    Row {
        id: trayRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property var modelData
                width: 24
                height: 24
                Accessible.name: modelData.tooltipTitle || modelData.title

                Image {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: modelData.icon
                    sourceSize.width: 36
                    sourceSize.height: 36
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    visible: modelData.icon !== ""
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            const position = mapToItem(
                                root.panelWindow.contentItem,
                                mouse.x,
                                mouse.y
                            );
                            modelData.display(
                                root.panelWindow,
                                Math.round(position.x),
                                Math.round(position.y)
                            );
                        } else {
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
