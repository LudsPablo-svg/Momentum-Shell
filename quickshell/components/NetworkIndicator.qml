import QtQuick
import "../services" as Services

Item {
    id: root

    implicitWidth: networkText.implicitWidth
    implicitHeight: Services.Settings.barHeight
    width: implicitWidth
    height: implicitHeight

    Text {
        id: networkText
        anchors.verticalCenter: parent.verticalCenter
        text: Services.NetworkInfo.statusText
        color: Services.NetworkInfo.defaultInterface === ""
            ? Services.Theme.muted
            : Services.Theme.text
        font.family: Services.Theme.fontMono
        font.pixelSize: 10
        Accessible.name: Services.NetworkInfo.accessibleText
    }
}
