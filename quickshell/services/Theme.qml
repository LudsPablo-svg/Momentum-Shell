pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    function refreshPalette(): void {
        paletteFile.reload();
    }

    readonly property string configHome: {
        const configured = Quickshell.env("XDG_CONFIG_HOME");
        return configured && configured.length > 0
            ? configured
            : (Quickshell.env("HOME") || "") + "/.config";
    }
    readonly property string stateHome: {
        const configured = Quickshell.env("XDG_STATE_HOME");
        return configured && configured.length > 0
            ? configured
            : (Quickshell.env("HOME") || "") + "/.local/state";
    }

    FileView {
        id: paletteFile
        path: Qt.resolvedUrl(root.configHome + "/void-shell/current-theme/theme.json")
        watchChanges: true
        onFileChanged: reload()
        printErrors: false
    }

    FileView {
        id: wallpaperFile
        path: Qt.resolvedUrl(root.stateHome + "/void-shell/wallpaper")
        watchChanges: true
        onFileChanged: reload()
        printErrors: false
    }

    readonly property var palette: {
        let parsed = ({});
        try {
            parsed = JSON.parse(paletteFile.text());
        } catch (error) {
            parsed = ({});
        }
        parsed;
    }

    readonly property string activeId: palette.id || "void-classic"
    readonly property string activeName: palette.name || "Void Classic"
    readonly property string activeDescription: palette.description || "Grafite e verde Void"
    readonly property string currentWallpaper: {
        const value = wallpaperFile.text();
        return value.endsWith("\n") ? value.slice(0, -1) : value;
    }

    readonly property color background: palette.background || "#1B1B1B"
    readonly property color surface: palette.surface || "#252525"
    readonly property color elevated: palette.elevated || "#303030"
    readonly property color border: palette.border || "#404040"
    readonly property color text: palette.text || "#E0E0E0"
    readonly property color muted: palette.muted || "#A0A0A0"
    readonly property color accent: palette.accent || "#80B918"
    readonly property color accentDark: palette.accentDark || "#527A12"
    readonly property color error: palette.error || "#D9534F"
    readonly property color warning: palette.warning || "#D9A441"

    readonly property string fontUi: "DejaVu Sans"
    readonly property string fontMono: "DejaVu Sans Mono"
    readonly property int gap: 8
    readonly property int radius: 8
}
