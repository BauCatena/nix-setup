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
    property var allApps: []
    property real animHeight: animRect.height
    property int panelHeight: 340

    WlrLayershell.keyboardFocus: show ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: show || animRect.opacity > 0

    Timer {
        id: focusTimer
        interval: 60
        onTriggered: searchInput.forceActiveFocus()
    }

    onShowChanged: {
        if (show) {
            if (shellRoot) shellRoot.closeAllPopupsExcept("launcher");
            searchInput.text = "";
            filterApps("");
            if (allApps.length === 0) pGetApps.running = true;
            focusTimer.start();
        }
    }

    function filterApps(query) {
        appModel.clear();
        var q = query.toLowerCase();
        var count = 0;
        for (var i = 0; i < allApps.length; i++) {
            if (allApps[i].name.toLowerCase().includes(q)) {
                appModel.append(allApps[i]);
                count++;
                if (count >= 50) break;
            }
        }
        listView.currentIndex = appModel.count > 0 ? 0 : -1;
        panelHeight = Math.min(360, 72 + Math.min(appModel.count, 8) * 38);
    }

    function launchApp(index) {
        if (index < 0 || index >= appModel.count) return;
        var app = appModel.get(index);
        pExec.running = false;
        pExec.command = [Quickshell.env("HOME") + "/.config/quickshell/launch_app.sh", app.cmd];
        pExec.running = true;
        show = false;
    }

    Process {
        id: pGetApps
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/get_apps.py", "--no-icons"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    rootWindow.allApps = JSON.parse(data);
                    if (rootWindow.show) rootWindow.filterApps(searchInput.text);
                } catch (e) {
                    console.log("AppLauncher:", e);
                }
            }
        }
    }

    Process { id: pExec }

    Item {
        anchors.fill: parent

        MouseArea {
            anchors.fill: parent
            enabled: show
            onClicked: show = false
        }

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

            Behavior on radius { NumberAnimation { duration: show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.1 : 0 } }
            Behavior on width { NumberAnimation { duration: show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.1 : 0 } }
            Behavior on height { NumberAnimation { duration: show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.1 : 0 } }
            Behavior on anchors.topMargin { NumberAnimation { duration: show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.1 : 0 } }

            Item {
                anchors.fill: parent
                anchors.margins: 14
                opacity: show ? 1.0 : 0.0
                clip: true
                Behavior on opacity { NumberAnimation { duration: show ? 280 : 80 } }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

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
                                text: "run:"
                                color: shellRoot ? shellRoot.colMuted : "#888"
                                font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                font.pixelSize: 10
                                font.bold: true
                            }
                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                color: shellRoot ? shellRoot.colFg : "#fff"
                                font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                font.pixelSize: 10
                                background: Item {}
                                onTextEdited: filterApps(text)
                                Keys.onDownPressed: { if (appModel.count) listView.currentIndex = Math.min(appModel.count - 1, listView.currentIndex + 1); }
                                Keys.onUpPressed: { if (appModel.count) listView.currentIndex = Math.max(0, listView.currentIndex - 1); }
                                Keys.onReturnPressed: launchApp(listView.currentIndex)
                                Keys.onEscapePressed: show = false
                            }
                        }
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(appModel.count, 8) * 38
                        clip: true
                        model: ListModel { id: appModel }
                        spacing: 2

                        delegate: Rectangle {
                            width: listView.width
                            height: 36
                            radius: 10
                            color: listView.currentIndex === index || ma.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8
                                Rectangle {
                                    Layout.preferredWidth: 24
                                    Layout.preferredHeight: 24
                                    radius: 6
                                    color: Qt.rgba(1, 1, 1, 0.06)
                                    clip: true
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        fillMode: Image.PreserveAspectFit
                                        visible: model.iconPath && model.iconPath !== ""
                                        source: model.iconPath ? ("file://" + model.iconPath) : ""
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        visible: !model.iconPath
                                        text: model.name ? model.name.charAt(0) : "?"
                                        color: shellRoot ? shellRoot.colMuted : "#aaa"
                                        font.pixelSize: 10
                                    }
                                }
                                Text {
                                    text: model.name
                                    color: shellRoot ? shellRoot.colFg : "#fff"
                                    font.family: shellRoot ? shellRoot.fontFamily : "monospace"
                                    font.pixelSize: 10
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }
                            MouseArea {
                                id: ma
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: { listView.currentIndex = index; launchApp(index); }
                            }
                        }
                    }
                }
            }
        }
    }
}
