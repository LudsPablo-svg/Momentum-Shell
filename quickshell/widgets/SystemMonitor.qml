import Quickshell.Io
import QtQuick
import "../services" as Services

Item {
    id: root

    property bool active: false
    implicitHeight: monitorCard.implicitHeight
    height: implicitHeight

    function refresh(): void {
        loadFile.reload();
        memoryFile.reload();
        uptimeFile.reload();
    }

    onActiveChanged: {
        if (active) refresh();
    }

    FileView {
        id: loadFile
        path: "/proc/loadavg"
    }

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    Timer {
        interval: 5000
        running: root.active
        repeat: true
        onTriggered: root.refresh()
    }

    readonly property string loadAverage: {
        const value = loadFile.text().trim().split(/\s+/)[0];
        return value || "Indisponível";
    }

    readonly property string memorySummary: {
        const lines = memoryFile.text().split("\n");
        let totalKiB = 0;
        let availableKiB = 0;
        let hasTotal = false;
        let hasAvailable = false;

        for (const line of lines) {
            const fields = line.trim().split(/\s+/);
            if (fields[0] === "MemTotal:") {
                totalKiB = Number(fields[1]);
                hasTotal = true;
            }
            if (fields[0] === "MemAvailable:") {
                availableKiB = Number(fields[1]);
                hasAvailable = true;
            }
        }

        if (!hasTotal || !hasAvailable || totalKiB <= 0) return "Indisponível";

        const usedKiB = Math.max(0, totalKiB - availableKiB);
        const percentage = Math.round((usedKiB / totalKiB) * 100);
        const usedGiB = (usedKiB / 1048576).toFixed(1);
        const totalGiB = (totalKiB / 1048576).toFixed(1);
        return `${percentage}% · ${usedGiB} / ${totalGiB} GiB`;
    }

    readonly property string uptimeSummary: {
        const raw = uptimeFile.text().trim().split(/\s+/)[0];
        if (raw === "") return "Indisponível";
        const seconds = Number(raw);
        if (!Number.isFinite(seconds)) return "Indisponível";

        const minutes = Math.floor(seconds / 60);
        const days = Math.floor(minutes / 1440);
        const hours = Math.floor((minutes % 1440) / 60);
        const remainder = minutes % 60;
        if (days > 0) return `${days}d ${hours}h`;
        return `${hours}h ${remainder}m`;
    }

    Rectangle {
        id: monitorCard
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: monitorContent.implicitHeight + 24
        height: implicitHeight
        radius: Services.Theme.radius
        color: Services.Theme.surface
        border.width: 1
        border.color: Services.Theme.border

        Column {
            id: monitorContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            Text {
                text: "SISTEMA"
                color: Services.Theme.accent
                font.family: Services.Theme.fontMono
                font.pixelSize: 10
                font.bold: true
            }

            Row {
                width: parent.width
                spacing: 10
                Text {
                    width: 102
                    text: "Carga (1 min)"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 11
                }
                Text {
                    text: root.loadAverage
                    color: Services.Theme.text
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 11
                }
            }

            Row {
                width: parent.width
                spacing: 10
                Text {
                    width: 102
                    text: "Memória"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 11
                }
                Text {
                    text: root.memorySummary
                    color: Services.Theme.text
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 11
                }
            }

            Row {
                width: parent.width
                spacing: 10
                Text {
                    width: 102
                    text: "Ligado há"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 11
                }
                Text {
                    text: root.uptimeSummary
                    color: Services.Theme.text
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 11
                }
            }
        }
    }
}
