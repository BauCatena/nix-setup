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
    property var themes: []
    property real animHeight: animRect.height

    readonly property string scriptsPath: Quickshell.env("HOME") + "/.config/niri/scripts"

    WlrLayershell.keyboardFocus: show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: show || animRect.opacity > 0

    function currentThemeName() {
        if (listView.currentIndex < 0 || listView.currentIndex >= themeModel.count)
            return "";
        return themeModel.get(listView.currentIndex).name;
    }

    function applyCurrent() {
        var name = currentThemeName();
        if (!name) return;
        pExec.command = [scriptsPath + "/switch_theme.sh", name];
        pExec.running = true;
        show = false;
    }

    function handleKeys(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { applyCurrent(); event.accepted = true; return; }
        if (event.key === Qt.Key_Escape) { show = false; event.accepted = true; return; }
        if (event.key === Qt.Key_Down) {
            if (themeModel.count) listView.currentIndex = Math.min(themeModel.count - 1, listView.currentIndex + 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            if (themeModel.count) listView.currentIndex = Math.max(0, listView.currentIndex - 1);
            event.accepted = true;
        }
    }

    onShowChanged: {
        if (show) {
            if (shellRoot) shellRoot.closeAllPopupsExcept("theme");
            searchInput.text = "";
            themeModel.clear();
            themes = [];
            pGetThemes.running = true;
            focusTimer.start();
        }
    }

    Timer { id: focusTimer; interval: 60; onTriggered: searchInput.forceActiveFocus() }

    function filterThemes(query) {
        themeModel.clear();
        var q = query.toLowerCase();
        for (var i = 0; i < themes.length; i++) {
            if (themes[i].toLowerCase().includes(q))
                themeModel.append({ "name": themes[i] });
        }
        listView.currentIndex = themeModel.count > 0 ? 0 : -1;
    }

    Process {
        id: pGetThemes
        command: ["sh", "-c", "ls " + Quickshell.env("HOME") + "/.config/niri/themes/*.conf 2>/dev/null | xargs -n1 basename | sed 's/\\.conf//'"]
        stdout: SplitParser { onRead: data => { var d = data.trim(); if (d) themes.push(d); } }
        onRunningChanged: { if (!running && show) filterThemes(""); }
        onStarted: { themes = []; }
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
            width: show ? 400 : (shellRoot ? shellRoot.notchWidth + 32 : 120)
            height: show ? 300 : 32
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

                Text {
                    text: " Theme "
                    color: shellRoot ? shellRoot.colMuted : "#aaa"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 10
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    placeholderText: " filter… "
                    color: shellRoot ? shellRoot.colFg : "#fff"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 10
                    background: Rectangle { color: Qt.rgba(1,1,1,0.06); radius: 12 }
                    onTextEdited: filterThemes(text)
                    Keys.onPressed: (event) => rootWindow.handleKeys(event)
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: ListModel { id: themeModel }
                    delegate: Rectangle {
                        width: listView.width
                        height: 36
                        radius: 10
                        color: listView.currentIndex === index ? Qt.rgba(1,1,1,0.1) : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: model.name
                            color: shellRoot ? shellRoot.colFg : "#fff"
                            font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                            font.pixelSize: 10
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                listView.currentIndex = index;
                                applyCurrent();
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "↵ or click to apply   ·   Esc close"
                    color: shellRoot ? shellRoot.colMuted : "#666"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 9
                }
            }
        }
    }
}
