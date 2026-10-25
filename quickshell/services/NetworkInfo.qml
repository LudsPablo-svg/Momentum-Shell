pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    FileView {
        id: routeTable
        path: "/proc/net/route"
    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        onTriggered: routeTable.reload()
    }

    readonly property string defaultInterface: {
        if (!routeTable.loaded) return "";

        const rows = routeTable.text().trim().split("\n");
        for (let index = 1; index < rows.length; index++) {
            const fields = rows[index].trim().split(/\s+/);
            if (fields.length < 4 || fields[1] !== "00000000") continue;
            if ((parseInt(fields[3], 16) & 1) === 1) return fields[0];
        }

        return "";
    }

    readonly property string statusText: {
        if (!routeTable.loaded) return "NET …";
        return defaultInterface === "" ? "NET —" : "NET " + defaultInterface;
    }

    readonly property string accessibleText: {
        if (!routeTable.loaded) return "Consultando rotas IPv4";
        if (defaultInterface === "") return "Nenhuma rota IPv4 padrão detectada";
        return "Rota IPv4 padrão pela interface " + defaultInterface;
    }
}
