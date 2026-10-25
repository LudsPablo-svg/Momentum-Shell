pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configHome: {
        const configured = Quickshell.env("XDG_CONFIG_HOME");
        return configured && configured.length > 0
            ? configured
            : (Quickshell.env("HOME") || "") + "/.config";
    }

    property string saveStatus: ""
    readonly property int barHeight: Math.max(32, Math.min(52, preferences.barHeight))
    readonly property bool showDate: preferences.showDate
    readonly property bool showNetwork: preferences.showNetwork
    readonly property bool showTray: preferences.showTray

    function setBarHeight(value: int): void {
        preferences.barHeight = Math.max(32, Math.min(52, Math.round(value)));
    }

    function setShowDate(value: bool): void {
        preferences.showDate = value;
    }

    function setShowNetwork(value: bool): void {
        preferences.showNetwork = value;
    }

    function setShowTray(value: bool): void {
        preferences.showTray = value;
    }

    function restoreDefaults(): void {
        preferences.barHeight = 38;
        preferences.showDate = true;
        preferences.showNetwork = true;
        preferences.showTray = true;
    }

    function normalize(): void {
        const boundedHeight = Math.max(32, Math.min(52, preferences.barHeight));
        if (preferences.barHeight !== boundedHeight) {
            preferences.barHeight = boundedHeight;
        }
    }

    FileView {
        id: settingsFile
        path: Qt.resolvedUrl(root.configHome + "/void-shell/settings.json")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: {
            root.saveStatus = "Salvando…";
            writeAdapter();
        }
        onSaved: root.saveStatus = "Preferências salvas"
        onSaveFailed: root.saveStatus = "Falha ao salvar preferências"
        onLoaded: root.normalize()
        onLoadFailed: root.saveStatus = "Usando padrões; salve para criar o arquivo"

        JsonAdapter {
            id: preferences
            property int barHeight: 38
            property bool showDate: true
            property bool showNetwork: true
            property bool showTray: true
        }
    }
}
