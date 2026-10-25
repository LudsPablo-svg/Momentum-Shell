import Quickshell
import QtQuick
import "../services" as Services

PanelWindow {
    id: window

    property var targetScreen: null
    signal dashboardRequested()

    screen: window.targetScreen
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Services.Settings.barHeight
    exclusiveZone: Services.Settings.barHeight
    aboveWindows: true

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: Services.Theme.background
        }

        Row {
            id: leftGroup
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            WorkspaceIndicator {
                screen: window.targetScreen
                height: Services.Settings.barHeight
            }

            Rectangle {
                width: 1
                height: 20
                color: Services.Theme.border
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                width: brand.implicitWidth
                    height: Services.Settings.barHeight

                Text {
                    id: brand
                    anchors.centerIn: parent
                    text: "VOID"
                    color: Services.Theme.accent
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 12
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.dashboardRequested()
                }
            }
        }

        Clock {
            anchors.centerIn: parent
            onClicked: window.dashboardRequested()
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            NetworkIndicator {
                visible: Services.Settings.showNetwork
                height: Services.Settings.barHeight
            }

            SystemTray {
                visible: Services.Settings.showTray
                panelWindow: window
                height: Services.Settings.barHeight
            }
        }
    }
}
