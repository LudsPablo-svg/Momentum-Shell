import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Dialogs
import Qt.labs.folderlistmodel
import "../components" as Components
import "../services" as Services

PanelWindow {
    id: root

    property bool open: false
    property var targetScreen: null
    property string selectedThemeId: Services.Theme.activeId
    property string selectedPath: ""
    property string selectedUrl: ""
    property string selectedName: ""
    property string searchText: ""
    property string statusText: "Escolha um tema ou wallpaper para visualizar."
    property string operationKind: ""
    property string operationMessage: ""
    property string taskError: ""
    property string taskOutput: ""
    property bool operationFailed: false
    signal closeRequested()

    readonly property string dataHome: {
        const configured = Quickshell.env("XDG_DATA_HOME");
        return configured && configured.length > 0
            ? configured
            : (Quickshell.env("HOME") || "") + "/.local/share";
    }
    readonly property string userBin: (Quickshell.env("HOME") || "") + "/.local/bin"
    readonly property string repositoryWallpaperDirectory: Quickshell.shellDir + "/wallpapers"
    readonly property string personalWallpaperDirectory: dataHome + "/void-shell/wallpapers"

    function nameForTheme(themeId: string): string {
        if (themeId === "void-forest") return "Void Forest";
        if (themeId === "void-mono") return "Void Mono";
        return "Void Classic";
    }

    function descriptionForTheme(themeId: string): string {
        if (themeId === "void-forest") return "Grafite profundo com verdes naturais.";
        if (themeId === "void-mono") return "Tons neutros e foco discreto.";
        return "Grafite equilibrado e verde Void.";
    }

    function themeValue(key: string, fallback: string): string {
        const lines = themeConfig.text().split("\n");
        const prefix = key + "=";
        for (let i = 0; i < lines.length; ++i) {
            if (lines[i].startsWith(prefix)) return lines[i].slice(prefix.length);
        }
        return fallback;
    }

    function addModelImages(model, section: string): void {
        for (let index = 0; index < model.count; ++index) {
            const name = model.get(index, "fileName");
            const path = model.get(index, "filePath");
            const url = model.get(index, "fileUrl");
            if (!name || !path || !url) continue;
            allWallpapers.append({
                imageName: name,
                imagePath: path,
                imageUrl: url.toString(),
                imageSection: section
            });
        }
    }

    function rebuildGallery(): void {
        allWallpapers.clear();
        addModelImages(repositoryImages, "Projeto");
        addModelImages(personalImages, "Pessoais");
        filterGallery();
        if (selectedPath === "" && allWallpapers.count > 0) {
            chooseImage(allWallpapers.get(0, "imagePath"),
                        allWallpapers.get(0, "imageUrl"),
                        allWallpapers.get(0, "imageName"));
        }
    }

    function filterGallery(): void {
        filteredWallpapers.clear();
        const query = searchText.trim().toLowerCase();
        for (let index = 0; index < allWallpapers.count; ++index) {
            const item = allWallpapers.get(index);
            if (query === "" || item.imageName.toLowerCase().indexOf(query) !== -1) {
                filteredWallpapers.append(item);
            }
        }
    }

    function chooseImage(path: string, url: string, name: string): void {
        selectedPath = path;
        selectedUrl = url;
        selectedName = name;
    }

    function startOperation(command, kind: string, message: string): void {
        if (worker.running) return;
        operationKind = kind;
        operationMessage = message;
        statusText = message;
        taskError = "";
        taskOutput = "";
        operationFailed = false;
        worker.command = command;
        worker.running = true;
    }

    function applySelectedWallpaper(): void {
        if (selectedPath === "") {
            statusText = "Selecione uma imagem legível primeiro.";
            return;
        }
        startOperation([userBin + "/void-wallpaper", "set", selectedPath], "wallpaper",
                       "Aplicando wallpaper…");
    }

    function importSelectedImage(): void {
        imageDialog.open();
    }

    onOpenChanged: {
        if (open) selectedThemeId = Services.Theme.activeId;
    }

    screen: root.targetScreen !== null
        ? root.targetScreen
        : (Quickshell.screens.length > 0 ? Quickshell.screens[0] : null)
    visible: root.open
    focusable: true
    aboveWindows: true
    anchors {
        top: true
        right: true
    }
    margins {
        top: Services.Settings.barHeight + 10
        right: 12
    }
    implicitWidth: 820
    implicitHeight: 640
    exclusiveZone: 0

    FileView {
        id: themeConfig
        path: Quickshell.shellDir + "/themes/" + root.selectedThemeId + "/theme.conf"
        printErrors: false
    }

    FolderListModel {
        id: repositoryImages
        folder: root.repositoryWallpaperDirectory
        nameFilters: ["*.png", "*.PNG", "*.jpg", "*.JPG", "*.jpeg", "*.JPEG"]
        showDirs: false
        showHidden: false
        showOnlyReadable: true
        caseSensitive: false
        onCountChanged: root.rebuildGallery()
    }

    FolderListModel {
        id: personalImages
        folder: root.personalWallpaperDirectory
        nameFilters: ["*.png", "*.PNG", "*.jpg", "*.JPG", "*.jpeg", "*.JPEG"]
        showDirs: false
        showHidden: false
        showOnlyReadable: true
        caseSensitive: false
        onCountChanged: root.rebuildGallery()
    }

    ListModel { id: allWallpapers }
    ListModel { id: filteredWallpapers }

    FileDialog {
        id: imageDialog
        title: "Adicionar imagem à biblioteca Void"
        fileMode: FileDialog.OpenFile
        nameFilters: ["PNG (*.png)", "JPEG (*.jpg *.jpeg)"]
        onAccepted: {
            const encoded = imageDialog.selectedFile.toString();
            const sourcePath = decodeURIComponent(encoded.replace(/^file:\/\//, ""));
            root.startOperation([root.userBin + "/void-wallpaper", "import", sourcePath], "import",
                                "Copiando e aplicando a imagem…");
        }
    }

    Timer {
        id: refreshTimer
        interval: 250
        repeat: false
        onTriggered: {
            personalImages.folder = "";
            personalImages.folder = root.personalWallpaperDirectory;
        }
    }

    Process {
        id: worker
        command: []
        stdout: StdioCollector { id: workerOutput }
        stderr: StdioCollector { id: workerErrors }

        onExited: function(exitCode, exitStatus) {
            root.taskOutput = workerOutput.text.trim();
            root.taskError = workerErrors.text.trim();
            root.operationFailed = exitCode !== 0;
            if (exitCode === 0) {
                const successMessage = root.taskOutput !== ""
                    ? root.taskOutput
                    : "Concluído: " + root.operationMessage;
                root.statusText = root.taskError !== ""
                    ? successMessage + " · Aviso: " + root.taskError
                    : successMessage;
                if (root.operationKind === "import") {
                    refreshTimer.start();
                }
            } else {
                root.statusText = root.taskError !== ""
                    ? root.taskError
                    : "A operação falhou (código " + exitCode + "). Consulte o log do shell.";
            }
            root.operationKind = "";
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Services.Theme.background
        border.width: 1
        border.color: Services.Theme.border
        radius: 14
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Components.AppHeader {
            width: parent.width
            title: "Temas e wallpapers"
            onCloseRequested: root.closeRequested()
        }

        Row {
            width: parent.width
            height: 34
            spacing: 10

            Rectangle {
                width: 9
                height: 9
                radius: 5
                color: Services.Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Ativo: " + Services.Theme.activeName
                    + "  ·  " + (Services.Theme.currentWallpaper.split("/").slice(-1)[0] || "sem wallpaper")
                color: Services.Theme.muted
                font.family: Services.Theme.fontUi
                font.pixelSize: 11
                elide: Text.ElideMiddle
                width: parent.width - 24
            }
        }

        Row {
            id: themeRow
            width: parent.width
            height: 92
            spacing: 9

            Repeater {
                model: ["void-classic", "void-forest", "void-mono"]

                delegate: Rectangle {
                    required property string modelData
                    readonly property bool activeTheme: Services.Theme.activeId === modelData
                    width: (themeRow.width - 18) / 3
                    height: themeRow.height
                    radius: Services.Theme.radius
                    color: activeTheme ? Services.Theme.elevated : Services.Theme.surface
                    border.width: activeTheme ? 2 : 1
                    border.color: activeTheme ? Services.Theme.accent : Services.Theme.border

                    Column {
                        anchors.fill: parent
                        anchors.margins: 11
                        spacing: 5

                        Text {
                            text: root.nameForTheme(modelData)
                            color: Services.Theme.text
                            font.family: Services.Theme.fontUi
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            width: parent.width
                            text: root.descriptionForTheme(modelData)
                            color: Services.Theme.muted
                            font.family: Services.Theme.fontUi
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }

                        Row {
                            width: parent.width
                            height: 30
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: activeTheme ? "ATIVO" : ""
                                color: Services.Theme.accent
                                font.family: Services.Theme.fontMono
                                font.pixelSize: 9
                                font.bold: true
                            }

                            Item { width: parent.width - 145; height: 1 }

                            Components.ActionButton {
                                width: 100
                                implicitWidth: 100
                                implicitHeight: 28
                                text: activeTheme ? "Reaplicar" : "Aplicar"
                                secondary: activeTheme
                                enabled: !worker.running
                                onClicked: {
                                    root.selectedThemeId = modelData;
                                    root.startOperation([root.userBin + "/void-theme", "apply", modelData], "theme",
                                                        "Aplicando " + root.nameForTheme(modelData) + "…");
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Services.Theme.border
        }

        Row {
            width: parent.width
            height: 30
            spacing: 10

            Text {
                id: libraryTitle
                anchors.verticalCenter: parent.verticalCenter
                text: "BIBLIOTECA"
                color: Services.Theme.accent
                font.family: Services.Theme.fontMono
                font.pixelSize: 10
                font.bold: true
            }

            Text {
                id: imageCount
                anchors.verticalCenter: parent.verticalCenter
                text: allWallpapers.count + " imagens"
                color: Services.Theme.muted
                font.family: Services.Theme.fontUi
                font.pixelSize: 10
            }

            Item {
                width: Math.max(0, parent.width - libraryTitle.implicitWidth
                                - imageCount.implicitWidth - addImageButton.width
                                - refreshButton.width - parent.spacing * 4)
                height: 1
            }

            Components.ActionButton {
                id: addImageButton
                width: 126
                implicitWidth: 126
                implicitHeight: 30
                text: "Adicionar imagem"
                secondary: true
                enabled: !worker.running
                onClicked: root.importSelectedImage()
            }

            Components.ActionButton {
                id: refreshButton
                width: 108
                implicitWidth: 108
                implicitHeight: 30
                text: "Recarregar"
                secondary: true
                enabled: !worker.running
                onClicked: refreshTimer.start()
            }
        }

        Row {
            width: parent.width
            height: 320
            spacing: 14

            Column {
                width: 434
                height: parent.height
                spacing: 8

                Rectangle {
                    width: parent.width
                    height: 34
                    radius: 7
                    color: Services.Theme.surface
                    border.width: 1
                    border.color: Services.Theme.border

                    TextInput {
                        anchors.fill: parent
                        anchors.leftMargin: 11
                        anchors.rightMargin: 11
                        verticalAlignment: TextInput.AlignVCenter
                        color: Services.Theme.text
                        selectionColor: Services.Theme.accent
                        selectedTextColor: Services.Theme.background
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 11
                        clip: true
                        text: root.searchText
                        onTextChanged: {
                            root.searchText = text;
                            root.filterGallery();
                        }
                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "Pesquisar por nome…"
                            color: Services.Theme.muted
                            font: parent.font
                            visible: parent.text.length === 0
                            z: -1
                        }
                    }
                }

                GridView {
                    id: gallery
                    width: parent.width
                    height: parent.height - 42
                    cellWidth: 144
                    cellHeight: 112
                    clip: true
                    model: filteredWallpapers
                    currentIndex: -1
                    delegate: Rectangle {
                        required property string imageName
                        required property string imagePath
                        required property string imageUrl
                        required property string imageSection
                        width: gallery.cellWidth - 8
                        height: gallery.cellHeight - 8
                        radius: 7
                        color: imagePath === root.selectedPath
                            ? Services.Theme.elevated
                            : Services.Theme.surface
                        border.width: imagePath === root.selectedPath ? 2 : 1
                        border.color: imagePath === root.selectedPath
                            ? Services.Theme.accent
                            : Services.Theme.border
                        clip: true

                        Image {
                            id: thumbnail
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 76
                            source: imageUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            visible: status === Image.Ready
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 76
                            color: Services.Theme.elevated
                            visible: thumbnail.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: thumbnail.status === Image.Error ? "Imagem inválida" : "Carregando…"
                                color: thumbnail.status === Image.Error
                                    ? Services.Theme.error
                                    : Services.Theme.muted
                                font.family: Services.Theme.fontUi
                                font.pixelSize: 9
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 7
                            anchors.rightMargin: 7
                            anchors.bottomMargin: 5
                            text: imageName
                            color: Services.Theme.text
                            font.family: Services.Theme.fontUi
                            font.pixelSize: 9
                            elide: Text.ElideMiddle
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.chooseImage(imagePath, imageUrl, imageName)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 24
                        horizontalAlignment: Text.AlignHCenter
                        text: allWallpapers.count === 0
                            ? "Nenhuma imagem encontrada. Adicione um arquivo PNG ou JPEG para começar."
                            : "Nenhum resultado para esta pesquisa."
                        color: Services.Theme.muted
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        visible: filteredWallpapers.count === 0
                    }
                }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: Services.Theme.border
            }

            Column {
                width: parent.width - 463
                height: parent.height
                spacing: 10

                Text {
                    text: "PRÉVIA"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 205
                    radius: Services.Theme.radius
                    color: Services.Theme.elevated
                    border.width: 1
                    border.color: Services.Theme.border
                    clip: true

                    Image {
                        id: previewImage
                        anchors.fill: parent
                        source: root.selectedUrl
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        width: parent.width - 24
                        horizontalAlignment: Text.AlignHCenter
                        text: root.selectedPath === ""
                            ? "Selecione uma imagem"
                            : previewImage.status === Image.Error
                                ? "Não foi possível abrir esta imagem."
                                : "Carregando prévia…"
                        color: previewImage.status === Image.Error
                            ? Services.Theme.error
                            : Services.Theme.muted
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        visible: previewImage.status !== Image.Ready
                    }
                }

                Text {
                    width: parent.width
                    text: root.selectedName || "Nenhum wallpaper selecionado"
                    color: Services.Theme.text
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideMiddle
                }

                Text {
                    width: parent.width
                    text: root.selectedPath === Services.Theme.currentWallpaper
                        ? "Este wallpaper já está aplicado."
                        : "A seleção será aplicada ao desktop X11."
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontUi
                    font.pixelSize: 10
                    wrapMode: Text.WordWrap
                }

                Components.ActionButton {
                    width: parent.width
                    implicitWidth: parent.width
                    text: worker.running ? "Aguarde…" : "Aplicar wallpaper"
                    enabled: !worker.running && root.selectedPath !== ""
                    onClicked: root.applySelectedWallpaper()
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Services.Theme.border
                }

                Text {
                    text: "PALETA DO TEMA"
                    color: Services.Theme.muted
                    font.family: Services.Theme.fontMono
                    font.pixelSize: 9
                    font.bold: true
                }

                Row {
                    width: parent.width
                    height: 26
                    spacing: 6
                    Repeater {
                        model: [
                            root.themeValue("background", "#1B1B1B"),
                            root.themeValue("surface", "#252525"),
                            root.themeValue("elevated", "#303030"),
                            root.themeValue("accent", "#80B918"),
                            root.themeValue("error", "#D9534F")
                        ]
                        delegate: Rectangle {
                            required property string modelData
                            width: 26
                            height: 26
                            radius: 6
                            color: modelData
                            border.width: 1
                            border.color: Services.Theme.border
                        }
                    }
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.nameForTheme(root.selectedThemeId)
                        color: Services.Theme.muted
                        font.family: Services.Theme.fontUi
                        font.pixelSize: 9
                    }
                }
            }
        }

        Text {
            width: parent.width
            text: worker.running ? "Processando…  " + root.operationMessage : root.statusText
            color: root.operationFailed
                ? Services.Theme.error
                : root.taskError !== ""
                    ? Services.Theme.warning
                    : Services.Theme.muted
            font.family: Services.Theme.fontUi
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }
}
