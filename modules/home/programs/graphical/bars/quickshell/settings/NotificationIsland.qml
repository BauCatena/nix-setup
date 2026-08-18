import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    id: rootWindow

    property bool show: false
    property var shellRoot
    property real animHeight: animRect.height
    property var items: []
    readonly property int unreadCount: items.length
    property bool hasUnread: unreadCount > 0
    property int selectedIndex: 0
    readonly property var currentItem: (items.length > 0 && selectedIndex >= 0 && selectedIndex < items.length)
        ? items[selectedIndex] : null
    readonly property string currentImage: currentItem ? (currentItem.image || "") : ""
    readonly property string currentAppIcon: currentItem ? (currentItem.appIcon || "") : ""

    function truncate(s, max) {
        if (!s) return "";
        return s.length > max ? s.substring(0, max - 1) + "…" : s;
    }

    function pushNotification(notification) {
        notification.tracked = true;
        var entry = {
            id: notification.id,
            notification: notification,
            summary: notification.summary || "",
            body: notification.body || "",
            appName: notification.appName || "",
            image: notification.image || "",
            appIcon: notification.appIcon || "",
            time: Date.now()
        };
        var next = [entry];
        for (var i = 0; i < items.length; i++) {
            if (items[i].id !== notification.id)
                next.push(items[i]);
            if (next.length >= 12) break;
        }
        items = next;
        selectedIndex = 0;
        show = true;
        autoHideTimer.restart();
        if (shellRoot) shellRoot.syncUnreadFromIsland();
    }

    function removeAt(index) {
        if (index < 0 || index >= items.length) return;
        var next = items.slice();
        next.splice(index, 1);
        items = next;
        if (selectedIndex >= items.length)
            selectedIndex = Math.max(0, items.length - 1);
        if (items.length === 0)
            show = false;
        if (shellRoot) shellRoot.syncUnreadFromIsland();
    }

    function dismissAt(index) {
        if (index < 0 || index >= items.length) return;
        var n = items[index].notification;
        if (n && n.dismiss)
            n.dismiss();
        removeAt(index);
    }

    function dismissAll() {
        for (var i = 0; i < items.length; i++) {
            var n = items[i].notification;
            if (n && n.dismiss)
                n.dismiss();
        }
        items = [];
        show = false;
        if (shellRoot) shellRoot.syncUnreadFromIsland();
    }

    WlrLayershell.keyboardFocus: show ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: show || animRect.opacity > 0

    Timer {
        id: autoHideTimer
        interval: 6000
        repeat: false
        onTriggered: rootWindow.show = false
    }

    onShowChanged: {
        if (show) focusTimer.start();
        else autoHideTimer.stop();
    }

    Timer {
        id: focusTimer
        interval: 50
        onTriggered: islandContent.forceActiveFocus()
    }

    Item {
        id: islandContent
        anchors.fill: parent
        focus: show
        Keys.onEscapePressed: show = false

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

            width: show ? Math.min(420, parent.width - 32) : (shellRoot ? shellRoot.notchWidth + 32 : 120)
            height: show ? Math.min(360, detailColumn.implicitHeight + 32) : 32

            color: Qt.rgba(0.08, 0.08, 0.08, 0.95)
            radius: show ? 24 : (shellRoot && shellRoot.isBarMode ? 0 : 16)
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: show ? 1 : 0
            opacity: (!show && height <= 36) ? 0.0 : 1.0

            Behavior on radius { NumberAnimation { duration: (shellRoot && shellRoot.batteryMode) ? 0 : show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.2 : 0 } }
            Behavior on width { NumberAnimation { duration: (shellRoot && shellRoot.batteryMode) ? 0 : show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.2 : 0 } }
            Behavior on height { NumberAnimation { duration: (shellRoot && shellRoot.batteryMode) ? 0 : show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.2 : 0 } }
            Behavior on anchors.topMargin { NumberAnimation { duration: (shellRoot && shellRoot.batteryMode) ? 0 : show ? 450 : 300; easing.type: show ? Easing.OutBack : Easing.OutExpo; easing.overshoot: show ? 1.2 : 0 } }

            Item {
                anchors.fill: parent
                anchors.margins: 16
                opacity: show ? 1.0 : 0.0
                clip: true
                Behavior on opacity { NumberAnimation { duration: (shellRoot && shellRoot.batteryMode) ? 0 : show ? 300 : 100; easing.type: Easing.InOutQuad } }

                ColumnLayout {
                    id: detailColumn
                    anchors.fill: parent
                    spacing: 10
                    visible: items.length > 0

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Text {
                            text: "󰂚"
                            color: shellRoot ? shellRoot.colAccent : "#ffffff"
                            font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                            font.pixelSize: 16
                        }
                        Text {
                            text: currentItem ? (currentItem.appName || "Notification") : ""
                            color: shellRoot ? shellRoot.colMuted : "#aaaaaa"
                            font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                            font.pixelSize: 11
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        MouseArea {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            onClicked: rootWindow.dismissAt(selectedIndex)
                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: shellRoot ? shellRoot.colMuted : "#888888"
                                font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                font.pixelSize: 12
                            }
                        }
                        MouseArea {
                            visible: items.length > 1
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            onClicked: rootWindow.dismissAll()
                            Text {
                                anchors.centerIn: parent
                                text: "󰩈"
                                color: shellRoot ? shellRoot.colMuted : "#888888"
                                font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                font.pixelSize: 12
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        visible: items.length > 0

                        Rectangle {
                            Layout.preferredWidth: 52
                            Layout.preferredHeight: 52
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.06)
                            visible: currentImage !== "" || currentAppIcon !== ""
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                source: currentImage !== ""
                                    ? (currentImage.startsWith("file://")
                                        ? currentImage
                                        : "file://" + currentImage)
                                    : ""
                                visible: currentImage !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: currentImage === ""
                                text: "󰂞"
                                color: shellRoot ? shellRoot.colFg : "#ffffff"
                                font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                font.pixelSize: 22
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text {
                                text: currentItem ? currentItem.summary : ""
                                color: shellRoot ? shellRoot.colFg : "#ffffff"
                                font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                font.pixelSize: 13
                                font.bold: true
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                            }
                            Text {
                                text: currentItem ? currentItem.body : ""
                                color: shellRoot ? shellRoot.colMuted : "#bbbbbb"
                                font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                visible: currentItem && currentItem.body !== ""
                            }
                        }
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.min(120, count * 44)
                        visible: items.length > 1
                        clip: true
                        spacing: 4
                        model: items.length
                        currentIndex: selectedIndex
                        onCurrentIndexChanged: selectedIndex = currentIndex

                        delegate: Rectangle {
                            width: listView.width
                            height: 40
                            radius: 10
                            color: listView.currentIndex === index ? Qt.rgba(1, 1, 1, 0.1) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8
                                Text {
                                    text: rootWindow.truncate(items[index].summary, 36)
                                    color: shellRoot ? shellRoot.colFg : "#ffffff"
                                    font.family: shellRoot ? shellRoot.fontFamily : "sans-serif"
                                    font.pixelSize: 11
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: listView.currentIndex = index
                            }
                        }
                    }
                }
            }
        }
    }
}
