import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: rootWindow

    property bool show: false
    property var shellRoot
    property var wallpapers: []
    property real animHeight: animRect.height
    property int panelWidth: 520
    property int panelHeight: 400
    readonly property string scriptsPath: Quickshell.env("HOME") + "/.config/niri/scripts"

    WlrLayershell.keyboardFocus: show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: show || animRect.opacity > 0

    function currentPath() {
        if (gallery.currentIndex < 0 || gallery.currentIndex >= wallpaperModel.count)
            return "";
        return wallpaperModel.get(gallery.currentIndex).path;
    }

    function currentName() {
        if (gallery.currentIndex < 0 || gallery.currentIndex >= wallpaperModel.count)
            return "";
        return wallpaperModel.get(gallery.currentIndex).name;
    }

    function applyCurrent() {
        var path = currentPath();
        if (!path) return;
        pExec.command = [scriptsPath + "/set_wallpaper.sh", path];
        pExec.running = true;
        show = false;
    }

    function moveGallery(delta) {
        if (wallpaperModel.count === 0) return;
        var next = gallery.currentIndex + delta;
        if (next < 0) next = wallpaperModel.count - 1;
        if (next >= wallpaperModel.count) next = 0;
        gallery.currentIndex = next;
        gallery.positionViewAtIndex(next, ListView.Center);
    }

    function selectIndex(index) {
        if (index < 0 || index >= wallpaperModel.count) return;
        gallery.currentIndex = index;
        gallery.positionViewAtIndex(index, ListView.Center);
    }

    function handleKeys(event) {
        if (event.key === Qt.Key_Left) { moveGallery(-1); event.accepted = true; return; }
        if (event.key === Qt.Key_Right) { moveGallery(1); event.accepted = true; return; }
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { applyCurrent(); event.accepted = true; return; }
        if (event.key === Qt.Key_Escape) { show = false; event.accepted = true; }
    }

    onShowChanged: {
        if (show) {
            if (shellRoot) shellRoot.closeAllPopupsExcept("wallpaper");
            searchInput.text = "";
            wallpaperModel.clear();
            wallpapers = [];
            pGetWallpapers.running = true;
            focusTimer.start();
        }
    }

    Timer { id: focusTimer; interval: 60; onTriggered: keyCatcher.forceActiveFocus() }

    function filterWallpapers(query) {
        wallpaperModel.clear();
        var q = query.toLowerCase();
        for (var i = 0; i < wallpapers.length; i++) {
            if (wallpapers[i].name.toLowerCase().includes(q))
                wallpaperModel.append(wallpapers[i]);
        }
        gallery.currentIndex = wallpaperModel.count > 0 ? 0 : -1;
    }

    Process {
        id: pGetWallpapers
        command: ["sh", "-c", scriptsPath + "/list_wallpapers.sh"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (!line) return;
                var tab = line.indexOf("\t");
                if (tab < 0) return;
                wallpapers.push({ "name": line.substring(0, tab), "path": line.substring(tab + 1) });
            }
        }
        onRunningChanged: { if (!running && show) filterWallpapers(""); }
        onStarted: { wallpapers = []; }
    }

    Process { id: pExec }

    Item {
        anchors.fill: parent
        MouseArea { anchors.fill: parent; enabled: show; onClicked: show = false }

        Rectangle {
            id: animRect
            anchors.top: parent.top
            anchors.topMargin: show ? 16 : (shellRoot && shellRoot.isBarMode ? 0 : 4)
            anchors.horizontalCenter: parent.horizontalCenter
            width: show ? panelWidth : (shellRoot ? shellRoot.notchWidth + 32 : 120)
            height: show ? panelHeight : 32
            color: Qt.rgba(0.02, 0.02, 0.02, 0.95)
            radius: show ? 24 : (shellRoot && shellRoot.isBarMode ? 0 : 16)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: show ? 1 : 0
            opacity: (!show && height <= 36) ? 0.0 : 1.0
            Behavior on width { NumberAnimation { duration: show ? 450 : 300; easing.type: Easing.OutBack } }
            Behavior on height { NumberAnimation { duration: show ? 450 : 300; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                opacity: show ? 1 : 0
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: " Wallpaper "
                        color: shellRoot ? shellRoot.colMuted : "#aaa"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 10
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: currentName()
                        color: shellRoot ? shellRoot.colFg : "#fff"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.maximumWidth: 180
                    }
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: " filter… "
                    color: shellRoot ? shellRoot.colFg : "#fff"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 10
                    background: Rectangle { color: Qt.rgba(1,1,1,0.06); radius: 12 }
                    onTextEdited: filterWallpapers(text)
                    Keys.onPressed: (event) => rootWindow.handleKeys(event)
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 16
                    color: Qt.rgba(1, 1, 1, 0.04)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: currentPath() ? ("file://" + currentPath()) : ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        visible: currentPath() !== ""
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: currentPath() === ""
                        text: "no image"
                        color: shellRoot ? shellRoot.colMuted : "#666"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 10
                    }
                }

                ListView {
                    id: gallery
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    orientation: ListView.Horizontal
                    spacing: 8
                    clip: true
                    model: ListModel { id: wallpaperModel }
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: 180
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    preferredHighlightBegin: width / 2 - 40
                    preferredHighlightEnd: width / 2 + 40
                    snapMode: ListView.SnapToItem

                    delegate: Rectangle {
                        width: 80
                        height: 48
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.04)
                        border.color: gallery.currentIndex === index ? (shellRoot ? shellRoot.colFg : "#fff") : Qt.rgba(1, 1, 1, 0.1)
                        border.width: gallery.currentIndex === index ? 2 : 1
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + model.path
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selectIndex(index);
                                applyCurrent();
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "← → browse   ·   ↵ or click to set   ·   Esc close"
                    color: shellRoot ? shellRoot.colMuted : "#666"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 9
                }
            }
        }
    }

    Item {
        id: keyCatcher
        focus: show
        Keys.onPressed: (event) => rootWindow.handleKeys(event)
    }
}
