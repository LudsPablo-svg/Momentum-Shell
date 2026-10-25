import Quickshell
import Quickshell.I3
import Quickshell.Io
import QtQuick
import "components" as Components
import "widgets" as Widgets
import "apps" as Apps
import "services" as Services

ShellRoot {
    id: root

    property bool dashboardVisible: false
    property bool themeManagerVisible: false
    property bool settingsVisible: false
    readonly property var dashboardScreen: {
        const screens = Quickshell.screens;
        if (screens.length === 0) return null;

        const focusedMonitor = I3.focusedMonitor;
        if (focusedMonitor !== null && focusedMonitor !== undefined) {
            for (const screen of screens) {
                if (screen.name === focusedMonitor.name) return screen;
            }
        }

        return screens[0];
    }

    function toggleDashboard(): void {
        dashboardVisible = !dashboardVisible;
        if (dashboardVisible) {
            themeManagerVisible = false;
            settingsVisible = false;
        }
    }

    function toggleThemeManager(): void {
        themeManagerVisible = !themeManagerVisible;
        if (themeManagerVisible) {
            dashboardVisible = false;
            settingsVisible = false;
        }
    }

    function toggleShellSettings(): void {
        settingsVisible = !settingsVisible;
        if (settingsVisible) {
            dashboardVisible = false;
            themeManagerVisible = false;
        }
    }

    IpcHandler {
        target: "void"

        function toggleDashboard(): void {
            root.toggleDashboard();
        }

        function toggleThemeManager(): void {
            root.toggleThemeManager();
        }

        function toggleShellSettings(): void {
            root.toggleShellSettings();
        }

        function ping(): bool {
            return true;
        }

        function reloadShell(): void {
            Quickshell.reload(false);
        }

        function refreshTheme(): void {
            Services.Theme.refreshPalette();
        }

        function stopShell(): void {
            Qt.quit();
        }
    }

    Variants {
        model: Quickshell.screens

        Components.Bar {
            required property var modelData
            targetScreen: modelData
            onDashboardRequested: {
                root.themeManagerVisible = false;
                root.settingsVisible = false;
                root.dashboardVisible = true;
            }
        }
    }

    Widgets.Dashboard {
        targetScreen: root.dashboardScreen
        open: root.dashboardVisible
        onCloseRequested: root.dashboardVisible = false
        onThemeManagerRequested: root.toggleThemeManager()
        onSettingsRequested: root.toggleShellSettings()
    }

    Apps.ThemeManager {
        targetScreen: root.dashboardScreen
        open: root.themeManagerVisible
        onCloseRequested: root.themeManagerVisible = false
    }

    Apps.ShellSettings {
        targetScreen: root.dashboardScreen
        open: root.settingsVisible
        onCloseRequested: root.settingsVisible = false
        onThemeManagerRequested: root.toggleThemeManager()
    }
}
