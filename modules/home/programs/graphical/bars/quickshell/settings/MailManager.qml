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
    property var mailItems: []
    property string fetchError: ""
    property bool configured: true
    property real animHeight: animRect.height
    property int panelHeight: 360

    readonly property string scriptsPath: Quickshell.env("HOME") + "/.config"

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
            if (shellRoot) shellRoot.closeAllPopupsExcept("mail");
            searchInput.text = "";
            mailModel.clear();
            mailItems = [];
            pFetch.running = true;
            focusTimer.start();
        }
    }

    function filterMails(query) {
        mailModel.clear();
        var q = query.toLowerCase();
        var count = 0;
        for (var i = 0; i < mailItems.length; i++) {
            var m = mailItems[i];
            var hay = (m.subject + " " + m.from + " " + m.bestCode).toLowerCase();
            if (hay.includes(q)) {
                mailModel.append(m);
                if (++count >= 40) break;
            }
        }
        listView.currentIndex = mailModel.count > 0 ? 0 : -1;
        var rows = Math.max(1, Math.min(mailModel.count, 7));
        panelHeight = Math.min(420, 96 + rows * 52);
    }

    function copyCode(code) {
        if (!code) return;
        pCopy.command = [scriptsPath + "/quickshell/mail_copy_code.sh", code];
        pCopy.running = true;
        if (shellRoot) {
            shellRoot.pendingMailCode = "";
            shellRoot.showIslandFlash("", "Code copied");
        }
        show = false;
    }

    function copyCurrent() {
        if (listView.currentIndex < 0) return;
        var row = mailModel.get(listView.currentIndex);
        if (row.bestCode)
            copyCode(row.bestCode);
    }

    function handleKeys(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { copyCurrent(); event.accepted = true; return; }
        if (event.key === Qt.Key_Escape) { show = false; event.accepted = true; return; }
        if (event.key === Qt.Key_Down && mailModel.count) {
            listView.currentIndex = Math.min(mailModel.count - 1, listView.currentIndex + 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up && mailModel.count) {
            listView.currentIndex = Math.max(0, listView.currentIndex - 1);
            event.accepted = true;
        }
    }

    Process {
        id: pFetch
        command: ["python3", scriptsPath + "/quickshell/mail_fetch.py", "--limit", "20"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var payload = JSON.parse(data);
                    configured = payload.configured !== false;
                    fetchError = payload.error || "";
                    mailItems = payload.emails || [];
                    if (rootWindow.show) filterMails(searchInput.text);
                } catch (e) {
                    fetchError = "Failed to parse mail";
                    mailItems = [];
                }
            }
        }
        onRunningChanged: { if (!running && show) filterMails(searchInput.text); }
    }

    Process { id: pCopy }

    Item {
        anchors.fill: parent
        MouseArea { anchors.fill: parent; enabled: show; onClicked: show = false }

        Rectangle {
            id: animRect
            anchors.top: parent.top
            anchors.topMargin: show ? 16 : (shellRoot && shellRoot.isBarMode ? 0 : 4)
            anchors.horizontalCenter: parent.horizontalCenter
            width: show ? 520 : (shellRoot ? shellRoot.notchWidth + 32 : 120)
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
                        text: " Mail "
                        color: shellRoot ? shellRoot.colMuted : "#aaa"
                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                        font.pixelSize: 10
                    }
                    Item { Layout.fillWidth: true }
                    MouseArea {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 22
                        onClicked: pFetch.running = true
                        Text {
                            anchors.centerIn: parent
                            text: "refresh"
                            color: shellRoot ? shellRoot.colMuted : "#888"
                            font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                            font.pixelSize: 9
                        }
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
                    onTextEdited: filterMails(text)
                    Keys.onPressed: (event) => rootWindow.handleKeys(event)
                }

                Text {
                    Layout.fillWidth: true
                    visible: !configured
                    wrapMode: Text.WordWrap
                    text: fetchError || "Configure himalaya first (~/.config/himalaya/config.toml)"
                    color: "#FFA500"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 9
                }

                Text {
                    Layout.fillWidth: true
                    visible: configured && fetchError !== ""
                    wrapMode: Text.WordWrap
                    text: fetchError
                    color: "#FF6B6B"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 9
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(mailModel.count, 7) * 52
                    clip: true
                    spacing: 4
                    model: ListModel { id: mailModel }

                    delegate: Rectangle {
                        width: listView.width
                        height: 48
                        radius: 10
                        color: listView.currentIndex === index ? Qt.rgba(1,1,1,0.1) : Qt.rgba(1,1,1,0.03)
                        border.color: model.bestCode ? Qt.rgba(0.4, 1, 0.5, 0.35) : Qt.rgba(1,1,1,0.06)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: model.subject || "(no subject)"
                                    color: shellRoot ? shellRoot.colFg : "#fff"
                                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: model.from
                                    color: shellRoot ? shellRoot.colMuted : "#888"
                                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                    font.pixelSize: 9
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            MouseArea {
                                visible: model.bestCode !== ""
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 28
                                onClicked: rootWindow.copyCode(model.bestCode)
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    color: Qt.rgba(0.2, 0.9, 0.4, 0.18)
                                    border.color: Qt.rgba(0.4, 1, 0.5, 0.5)
                                    border.width: 1
                                    Text {
                                        anchors.centerIn: parent
                                        text: model.bestCode
                                        color: "#7CFFB2"
                                        font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                        font.pixelSize: 10
                                        font.bold: true
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            onClicked: {
                                listView.currentIndex = index;
                                if (model.bestCode)
                                    rootWindow.copyCode(model.bestCode);
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: "↵ or click code to copy   ·   Esc close"
                    color: shellRoot ? shellRoot.colMuted : "#666"
                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                    font.pixelSize: 9
                }
            }
        }
    }

    Item {
        focus: show
        Keys.onPressed: (event) => rootWindow.handleKeys(event)
    }
}
