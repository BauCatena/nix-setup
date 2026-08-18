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
    property var clipItems: []
    property real animHeight: animRect.height
    property int panelHeight: 320

    WlrLayershell.keyboardFocus: show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: show || animRect.opacity > 0

    Timer { id: focusTimer; interval: 60; onTriggered: searchInput.forceActiveFocus() }

    onShowChanged: {
        if (show) {
            if (shellRoot) shellRoot.closeAllPopupsExcept("clipboard");
            searchInput.text = "";
            clipModel.clear();
            clipItems = [];
            pGetClips.running = true;
            focusTimer.start();
        }
    }

    function filterClips(query) {
        clipModel.clear();
        var q = query.toLowerCase();
        var count = 0;
        for (var i = 0; i < clipItems.length; i++) {
            if (clipItems[i].text.toLowerCase().includes(q)) {
                clipModel.append(clipItems[i]);
                if (++count >= 50) break;
            }
        }
        listView.currentIndex = clipModel.count > 0 ? 0 : -1;
        panelHeight = Math.min(360, 72 + Math.min(clipModel.count, 8) * 38);
    }

    function copyClip(index) {
        if (index < 0 || index >= clipModel.count) return;
        var item = clipModel.get(index);
        pExec.command = [Quickshell.env("HOME") + "/.config/niri/scripts/copy_clip.sh", item.id];
        pExec.running = true;
        show = false;
    }

    Process {
        id: pGetClips
        command: ["sh", "-c", "export PATH=\"" + (shellRoot ? shellRoot.nixPath : "") + ":$PATH\"; cliphist list"]
        stdout: SplitParser {
            onRead: data => {
                var d = data.trim();
                var idx = d.indexOf("\t");
                if (idx > -1) clipItems.push({ "id": d.substring(0, idx), "text": d.substring(idx + 1) });
            }
        }
        onRunningChanged: { if (!running && show) filterClips(""); }
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
            width: show ? 480 : (shellRoot ? shellRoot.notchWidth + 32 : 120)
            height: show ? panelHeight : 32
            color: Qt.rgba(0.02, 0.02, 0.02, 0.95)
            radius: show ? 24 : (shellRoot && shellRoot.isBarMode ? 0 : 16)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: show ? 1 : 0
            opacity: (!show && height <= 36) ? 0.0 : 1.0
            Behavior on width { NumberAnimation { duration: show ? 450 : 300; easing.type: Easing.OutBack } }
            Behavior on height { NumberAnimation { duration: show ? 450 : 300; easing.type: Easing.OutBack } }

            Item {
                anchors.fill: parent
                anchors.margins: 14
                opacity: show ? 1 : 0
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: " Clipboard "
                        color: shellRoot ? shellRoot.colMuted : "#aaa"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.06)
                        border.color: searchInput.activeFocus ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 6
                            Text {
                                text: "clip:"
                                color: shellRoot ? shellRoot.colMuted : "#888"
                                font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: " filter… "
                                color: shellRoot ? shellRoot.colFg : "#fff"
                                font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                font.pixelSize: 10
                                background: Item {}
                                onTextEdited: filterClips(text)
                                Keys.onDownPressed: { if (clipModel.count) listView.currentIndex = Math.min(clipModel.count - 1, listView.currentIndex + 1); }
                                Keys.onUpPressed: { if (clipModel.count) listView.currentIndex = Math.max(0, listView.currentIndex - 1); }
                                Keys.onReturnPressed: copyClip(listView.currentIndex)
                                Keys.onEscapePressed: show = false
                            }
                        }
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(clipModel.count, 8) * 38
                        clip: true
                        model: ListModel { id: clipModel }
                        spacing: 2

                        delegate: Rectangle {
                            width: listView.width
                            height: 36
                            radius: 10
                            color: listView.currentIndex === index || ma.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            Text {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: model.text
                                elide: Text.ElideRight
                                color: shellRoot ? shellRoot.colFg : "#fff"
                                font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                font.pixelSize: 10
                                verticalAlignment: Text.AlignVCenter
                            }
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: { listView.currentIndex = index; copyClip(index); }
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "↑↓ browse   ·   ↵ copy   ·   Esc close"
                        color: shellRoot ? shellRoot.colMuted : "#666"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 9
                    }
                }
            }
        }
    }
}
