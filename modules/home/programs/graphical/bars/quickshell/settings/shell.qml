import Quickshell
import QtQuick
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import Quickshell.Services.Notifications

ShellRoot {
    PanelWindow {
    id: root
    property color colBg: "#000000"
    property color colFg: "#ffffff"
    property color colAccent: "#ffffff"
    property color colMuted: Qt.rgba(1, 1, 1, 0.4)
    property color colHover: Qt.rgba(1, 1, 1, 0.1)
    property color colCrit: "#ff0000"
    property string fontFamily: "JetBrainsMono Nerd Font" 
    property int fontSize: 10
    property int windowCount: 0
    property bool isBarMode: windowCount === 1
    property real notchWidth: notchLayout.implicitWidth
    readonly property string configHome: Quickshell.env("HOME") + "/.config"
    readonly property string quickshellHome: configHome + "/quickshell"
    readonly property string nixPath: "/run/wrappers/bin:/run/current-system/sw/bin:" + Quickshell.env("HOME") + "/.local/bin"

    function lazyPopupOpen(loader) {
        return loader && loader.item && loader.item.show;
    }

    function lazyPopupAnim(loader) {
        return loader && loader.item && loader.item.animHeight > 36;
    }

    function lazyHostOpen(host) {
        return host && lazyPopupOpen(host.loader);
    }

    function lazyHostAnim(host) {
        return host && lazyPopupAnim(host.loader);
    }

    function openLazyPopup(host) {
        if (!host) return;
        host.pendingOpen = true;
        if (host.loader && host.loader.item)
            host.loader.item.show = true;
    }

    function closeLazyPopup(host) {
        if (!host) return;
        host.pendingOpen = false;
        if (host.loader && host.loader.item)
            host.loader.item.show = false;
    }

    function applyStatusPoll(data) {
        try {
            var s = JSON.parse(data.trim());
            root.powerDraw = s.powerDraw;
            root.temperature = s.temperature;
            root.updates = s.updates;
            root.batteryCap = s.batteryCap;
            root.batteryCharging = s.batteryCharging;
            root.volumeOut = s.volumeOut;
            root.volumeMuted = s.volumeMuted;
            root.volumeMic = s.volumeMic;
            root.micMuted = s.micMuted;
            root.bluetoothStatus = s.bluetoothStatus;
            root.micInUse = s.micInUse;
            root.cameraInUse = s.cameraInUse;
            root.brightnessLevel = s.brightnessLevel;
            root.batteryMode = s.batteryMode;
            var wifi = s.wifiSignal;
            if (wifi === "disc") {
                root.wifiIcon = "󰤮";
                root.wifiText = "Disconnected";
            } else {
                var sig = parseInt(wifi);
                root.wifiText = sig + "%";
                if (sig > 80) root.wifiIcon = "󰤨";
                else if (sig > 60) root.wifiIcon = "󰤥";
                else if (sig > 40) root.wifiIcon = "󰤢";
                else if (sig > 20) root.wifiIcon = "󰤟";
                else root.wifiIcon = "󰤯";
            }
        } catch (e) {}
    }
    
    readonly property bool isAnyPopupOpenExceptControl:
                             lazyHostOpen(appLauncherHost) ||
                             lazyHostOpen(clipboardHost) ||
                             lazyHostOpen(themeHost) ||
                             lazyHostOpen(wallpaperHost) ||
                             lazyHostOpen(wifiHost) ||
                             lazyHostOpen(powerHost) ||
                             lazyHostOpen(bluetoothHost) ||
                             lazyHostOpen(notificationHost) ||
                             lazyHostOpen(mailHost)
    property bool isAnyPopupOpen: controlCenter.show || isAnyPopupOpenExceptControl
    property bool isAnyPopupAnimActive: isAnyPopupOpenExceptControl
        || lazyHostAnim(appLauncherHost) || lazyHostAnim(clipboardHost)
        || lazyHostAnim(themeHost) || lazyHostAnim(wallpaperHost)
        || lazyHostAnim(wifiHost) || lazyHostAnim(powerHost)
        || lazyHostAnim(bluetoothHost) || lazyHostAnim(notificationHost)
        || lazyHostAnim(mailHost)

    property bool wantsFastPoll: isAnyPopupOpen || controlCenter.show
    property int unreadNotifCount: 0
    property string pendingMailCode: ""
    property var pendingNotifications: []

    function deliverNotification(notification) {
        closeAllPopupsExcept("notification");
        if (notificationHost && notificationHost.loader && notificationHost.loader.item) {
            notificationHost.loader.item.pushNotification(notification);
            unreadNotifCount = notificationHost.loader.item.unreadCount;
        } else {
            pendingNotifications.push(notification);
            unreadNotifCount = Math.min(unreadNotifCount + 1, 12);
            if (notificationHost)
                notificationHost.pendingOpen = true;
        }
    }

    function flushPendingNotifications() {
        if (!notificationHost || !notificationHost.loader || !notificationHost.loader.item || pendingNotifications.length === 0)
            return;
        for (var i = 0; i < pendingNotifications.length; i++)
            notificationHost.loader.item.pushNotification(pendingNotifications[i]);
        pendingNotifications = [];
        unreadNotifCount = notificationHost.loader.item.unreadCount;
    }

    function syncUnreadFromIsland() {
        if (notificationHost && notificationHost.loader && notificationHost.loader.item)
            unreadNotifCount = notificationHost.loader.item.unreadCount;
    }

    function closeAllPopupsExcept(except) {
        if (except !== "control") controlCenter.show = false;
        if (except !== "launcher") closeLazyPopup(appLauncherHost);
        if (except !== "clipboard") closeLazyPopup(clipboardHost);
        if (except !== "theme") closeLazyPopup(themeHost);
        if (except !== "wallpaper") closeLazyPopup(wallpaperHost);
        if (except !== "wifi") closeLazyPopup(wifiHost);
        if (except !== "power") closeLazyPopup(powerHost);
        if (except !== "bluetooth") closeLazyPopup(bluetoothHost);
        if (except !== "notification") closeLazyPopup(notificationHost);
        if (except !== "mail") closeLazyPopup(mailHost);
    }

    function dispatchQsCommand(line) {
        var cmd = line;
        var arg = "";
        var tab = line.indexOf("\t");
        if (tab > 0) {
            cmd = line.substring(0, tab);
            arg = line.substring(tab + 1);
        }

        if (cmd === "openWallpaperPicker") {
            closeAllPopupsExcept("wallpaper");
            openLazyPopup(wallpaperHost);
        } else if (cmd === "openThemeSwitcher") {
            closeAllPopupsExcept("theme");
            openLazyPopup(themeHost);
        } else if (cmd === "openAppLauncher") {
            closeAllPopupsExcept("launcher");
            openLazyPopup(appLauncherHost);
        } else if (cmd === "openClipboard") {
            closeAllPopupsExcept("clipboard");
            openLazyPopup(clipboardHost);
        } else if (cmd === "openPowerMenu") {
            closeAllPopupsExcept("power");
            openLazyPopup(powerHost);
        } else if (cmd === "openControlCenter") {
            closeAllPopupsExcept("control");
            controlCenter.show = true;
        } else if (cmd === "toggleControlCenter") {
            closeAllPopupsExcept("control");
            controlCenter.show = !controlCenter.show;
        } else if (cmd === "toggleNotifications") {
            closeAllPopupsExcept("notification");
            notificationHost.pendingOpen = true;
            if (notificationHost.loader.item)
                notificationHost.loader.item.show = !notificationHost.loader.item.show;
        } else if (cmd === "openMail") {
            closeAllPopupsExcept("mail");
            openLazyPopup(mailHost);
            mailOpenTimer.restart();
        } else if (cmd === "mailOtp") {
            var otpParts = arg.split("\t");
            var otpCode = otpParts[0] || "";
            var otpSubject = otpParts.length > 1 ? otpParts[1] : "Verification code";
            if (otpCode) {
                pendingMailCode = otpCode;
                showIslandFlash("", "Code: " + otpCode);
            }
        } else if (cmd === "showScreenshotFlash") {
            showIslandFlash("󰄀", "Capture taken");
        } else if (cmd === "showOsd") {
            var osdParts = arg.split("\t");
            applyOsd(osdParts[0] || "V", osdParts[1] || "0");
        }
    }

    function showIslandFlash(icon, label) {
        root.osdIcon = icon;
        root.osdText = label;
        root.osdValue = 100;
        flashTimer.stop();
        root.showOsd = true;
        flashTimer.start();
    }

    function applyOsd(type, val) {
        val = parseFloat(val);
        if (type === "V") {
            root.osdIcon = val === 0 ? "󰝟" : (val > 50 ? "󰕾" : "󰖀");
            root.osdText = Math.round(val) + "%";
        } else if (type === "B") {
            root.osdIcon = "󰃠";
            root.osdText = Math.round(val) + "%";
        }
        root.osdValue = val;
        root.showOsd = true;
        osdTimer.restart();
    }

    Timer {
        id: flashTimer
        interval: 1100
        repeat: false
        onTriggered: root.showOsd = false
    }

    Timer {
        id: mailOpenTimer
        interval: 80
        repeat: false
        onTriggered: {
            if (mailHost.loader && mailHost.loader.item)
                mailHost.loader.item.show = true;
        }
    }

    Process {
        id: pReadyMarker
        command: ["sh", "-c",
            "touch \"" + (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/quickshell.ready\""
        ]
        running: true
    }

    Process {
        id: pQsCmd
        command: ["sh", "-c",
            "export PATH=\"" + root.nixPath + ":$PATH\"; " +
            "f=\"" + (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp") + "/quickshell.cmd\"; " +
            "while true; do if [ -f \"$f\" ]; then cat \"$f\"; rm -f \"$f\"; fi; sleep 0.12; done"
        ]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var cmd = data.trim();
                if (cmd) root.dispatchQsCommand(cmd);
            }
        }
    }

    Process {
        id: pNiriState
        command: ["sh", "-c", root.quickshellHome + "/niri_state.sh"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    var s = JSON.parse(data.trim());
                    root.niriFocusedWorkspace = s.focused || 1;
                    root.niriActiveWorkspaces = s.active || [];
                    root.windowCount = s.tiled || 0;
                } catch (e) {}
            }
        }
    }

    Process {
        id: pStatusPoll
        command: ["python3", root.quickshellHome + "/poll_status.py", "--once"]
        stdout: SplitParser { onRead: data => root.applyStatusPoll(data) }
    }

    Timer {
        id: statusPollTimer
        interval: root.wantsFastPoll ? 2000 : 5000
        running: true
        repeat: true
        onTriggered: {
            if (!pStatusPoll.running)
                pStatusPoll.running = true;
        }
    }

    Process {
        id: pSpotifyPoll
        command: ["python3", root.quickshellHome + "/spotify_poll.py"]
        stdout: SplitParser { onRead: data => root.applySpotifyPoll(data) }
    }

    Timer {
        id: spotifyPollTimer
        interval: root.spotifyStatus === "Playing" ? 1000 : 4000
        running: true
        repeat: true
        onTriggered: {
            if (!pSpotifyPoll.running)
                pSpotifyPoll.running = true;
        }
    }

    Timer {
        id: spotifyElapsedTimer
        interval: 1000
        running: root.spotifyStatus === "Playing"
        repeat: true
        onTriggered: root.spotifyTick++
    }

    Process { id: pSpotCmd; command: ["true"] }

    Component.onCompleted: {
        pStatusPoll.running = true;
        pSpotifyPoll.running = true;
        pBatteryModeCheck.running = true;
    }

    Process {
        id: pBatteryModeCheck
        command: ["sh", "-c", "[ -f " + root.configHome + "/niri/.battery_mode ] && echo true || echo false"]
        stdout: SplitParser { onRead: data => { root.batteryMode = (data.trim() === "true"); } }
    }

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: controlCenter.show
    implicitHeight: controlCenter.show ? 0 : (root.isBarMode ? 32 : 36)
    exclusionMode: controlCenter.show ? ExclusionMode.Ignore : ExclusionMode.Normal
    WlrLayershell.keyboardFocus: controlCenter.show ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "transparent"

    Item {
        id: controlCenter
        property bool show: false
        property real animHeight: notchRect.height
    }

    Connections {
        target: controlCenter
        function onShowChanged() {
            if (controlCenter.show)
                focusTimerCc.start();
        }
    }

    Timer {
        id: focusTimerCc
        interval: 50
        onTriggered: controlCenterFocusScope.forceActiveFocus()
    }

    Item {
        id: controlCenterFocusScope
        anchors.fill: parent
        focus: controlCenter.show
        Keys.onEscapePressed: {
            controlCenter.show = false;
            timerPopup.show = false;
        }
    }

    MouseArea {
        id: controlCenterBackdrop
        anchors.fill: parent
        enabled: controlCenter.show
        visible: controlCenter.show
        z: 0
        onClicked: {
            controlCenter.show = false;
            timerPopup.show = false;
        }
    }

    // State properties
    property string powerDraw: "0.0"
    property string temperature: "0"
    property string updates: "0"
    property string batteryCap: "100"
    property string brightnessLevel: "100%"
    // property string kbdBrightnessLevel: "0"
    // property int cpuWattage: 15
    property bool batteryCharging: false
    //property string gpuMode: "Unknown"
    //property int batLimit: 80
    property string volumeOut: "0%"
    property bool volumeMuted: false
    property string volumeMic: "0%"
    property bool micMuted: false
    property string bluetoothStatus: "off"
    property bool batteryMode: false
    property bool showBatteryModeIndicator: false
    property int niriFocusedWorkspace: 1
    property var niriActiveWorkspaces: []
    
    onBatteryModeChanged: {
        showBatteryModeIndicator = true;
        batteryModeTimer.restart();
    }
    
    Timer {
        id: batteryModeTimer
        interval: 1000
        repeat: false
        onTriggered: root.showBatteryModeIndicator = false
    }

    property bool showMicIndicator: false
    property bool micInUse: false
    property bool cameraInUse: false
    
    onMicMutedChanged: {
        showMicIndicator = true;
        micIndicatorTimer.restart();
    }
    
    Timer {
        id: micIndicatorTimer
        interval: 1000
        repeat: false
        onTriggered: root.showMicIndicator = false
    }

    property string spotifyStatus: "offline"
    property string spotifyText: ""
    property bool spotifyActive: false
    property string spotifyPlayer: ""
    property string spotifyTitle: ""
    property string spotifyArtist: ""
    property string spotifyAlbum: ""
    property string spotifyArtUrl: ""
    property string spotifyTrackId: ""
    property int spotifyPositionMs: 0
    property int spotifyDurationMs: 0
    property int spotifyPollTime: 0
    property bool spotifyPulse: false
    property var spotifyBars: []
    property int spotifyTick: 0
    property string wifiIcon: "󰤯"
    property string wifiText: "Disconnected"

    property bool showOsd: false
    property string osdText: "0%"
    property string osdIcon: "󰕾"
    property real osdValue: 0
    property bool showPowerMenu: false
    property bool showAppLauncher: false
    property bool showClipboard: false

    // Stopwatch & Timer state
    property bool stopwatchRunning: false
    property int stopwatchSeconds: 0
    property string stopwatchText: "00:00"
    
    property bool timerRunning: false
    property int timerSeconds: 0
    property int timerTotal: 300 // 5 minutes default
    property string timerText: "05:00"
    
    property int pomodoroState: 0 // 0 = off, 1 = work, 2 = break
    property int pomodoroWorkTotal: 1500 // 25 minutes
    property int pomodoroBreakTotal: 300 // 5 minutes
    
    function formatTime(s) {
        var m = Math.floor(s / 60);
        var sec = s % 60;
        return (m < 10 ? "0" + m : m) + ":" + (sec < 10 ? "0" + sec : sec);
    }

    function formatMs(ms) {
        var totalSec = Math.max(0, Math.floor(ms / 1000));
        var m = Math.floor(totalSec / 60);
        var s = totalSec % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    function spotifyPositionNow() {
        if (spotifyStatus !== "Playing")
            return spotifyPositionMs;
        return spotifyPositionMs + Math.max(0, Date.now() - spotifyPollTime);
    }

    function spotifyElapsedLabel() {
        return formatMs(spotifyPositionNow());
    }

    function applySpotifyPoll(data) {
        try {
            var s = JSON.parse(data.trim());
            var wasTrack = spotifyTrackId;
            spotifyActive = s.active === true;
            spotifyStatus = s.status || "offline";
            spotifyPlayer = s.player || spotifyPlayer || "spotify";
            spotifyTitle = s.title || "";
            spotifyArtist = s.artist || "";
            spotifyAlbum = s.album || "";
            spotifyArtUrl = s.artUrl || "";
            spotifyTrackId = s.trackId || "";
            spotifyPositionMs = s.positionMs || 0;
            spotifyDurationMs = s.durationMs || 0;
            spotifyPollTime = Date.now();
            spotifyText = s.text || (spotifyTitle + " - " + spotifyArtist).replace(/^\s*-\s*/, "");
            if (s.bars && s.bars.length)
                spotifyBars = s.bars;
            if (spotifyTrackId && spotifyTrackId !== wasTrack)
                spotifyPulse = true;
            if (!spotifyActive) {
                spotifyStatus = "offline";
                spotifyText = "";
            }
        } catch (e) {}
    }

    function runSpotifyCtl(args) {
        pSpotCmd.command = ["sh", "-c", "export PATH=\"" + nixPath + ":$PATH\"; " + (spotifyPlayer ? ("playerctl --player=" + spotifyPlayer + " " + args) : ("player=$(playerctl -l 2>/dev/null | grep -E 'spotify_player|spotify-player|^spotify$' | head -1); [ -n \"$player\" ] && playerctl --player=\"$player\" " + args))];
        pSpotCmd.running = true;
    }

    // Click Actions
    Process { id: pPavu; command: ["pavucontrol"] }
    Process { id: pMicMute; command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"] }
    Process { id: pVolMute; command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"] }
    Process { id: pVolSet } // Dynamic volume setter
    //Process { id: pBatLimitSet }
    Process { id: pBlueberry; command: ["blueberry"] }

    Process { id: pWifiToggle; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; if nmcli radio wifi 2>/dev/null | grep -q enabled; then nmcli radio wifi off; else nmcli radio wifi on; fi"] }
    Process { id: pBtToggle; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then rfkill block bluetooth; else rfkill unblock bluetooth; fi"] }
    Process { id: pWifiOn; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; nmcli radio wifi on"] }
    Process { id: pWifiOff; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; nmcli radio wifi off"] }
    Process { id: pBtOn; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; rfkill unblock bluetooth"] }
    Process { id: pBtOff; command: ["sh", "-c", "export PATH=\"" + root.nixPath + ":$PATH\"; rfkill block bluetooth"] }
    Process { id: pCcShutdown; command: ["systemctl", "poweroff"] }
    Process { id: pCcReboot; command: ["systemctl", "reboot"] }
    Process { id: pCcSuspend; command: ["sh", "-c", "swaylock -c " + Quickshell.env("HOME") + "/.config/niri/swaylock.conf & sleep 1 && systemctl suspend"] }
    Process { id: pCcLock; command: ["swaylock", "-c", Quickshell.env("HOME") + "/.config/niri/swaylock.conf"] }
    Process {
        id: pToggleBatteryMode
        command: [Quickshell.env("HOME") + "/.local/bin/battery_mode.sh"]
        onRunningChanged: if (!running) pBatteryModeCheck.running = true
    }
    Process { id: pFocusWorkspace }

    Timer {
        id: osdTimer
        interval: 2000
        repeat: false
        onTriggered: root.showOsd = false
    }

    Timer {
        id: stopwatchTimer
        interval: 1000
        running: root.stopwatchRunning
        repeat: true
        onTriggered: {
            root.stopwatchSeconds++;
            root.stopwatchText = root.formatTime(root.stopwatchSeconds);
        }
    }

    Timer {
        id: timerTimer
        interval: 1000
        running: root.timerRunning
        repeat: true
        onTriggered: {
            if (root.timerSeconds > 0) {
                root.timerSeconds--;
                root.timerText = root.formatTime(root.timerSeconds);
            } else {
                if (root.pomodoroState === 1) {
                    root.pomodoroState = 2;
                    root.timerTotal = root.pomodoroBreakTotal;
                    root.timerSeconds = root.timerTotal;
                    root.timerText = root.formatTime(root.timerTotal);
                    pNotify.command = ["notify-send", "-u", "critical", "-i", "timer", "Pomodoro", "Work session finished! Time for a break."];
                    pNotify.running = true;
                } else if (root.pomodoroState === 2) {
                    root.pomodoroState = 1;
                    root.timerTotal = root.pomodoroWorkTotal;
                    root.timerSeconds = root.timerTotal;
                    root.timerText = root.formatTime(root.timerTotal);
                    pNotify.command = ["notify-send", "-u", "normal", "-i", "timer", "Pomodoro", "Break finished! Back to work."];
                    pNotify.running = true;
                } else {
                    root.timerRunning = false;
                }
            }
        }
    }
    
    Process { id: pNotify }

    Process {
        id: pBrightSet
        command: ["brightnessctl", "s", "50%"]
    }

    // Process { id: pKbdBrightSet }

    Process { id: pWattSet }

    Process { id: pGpu; command: ["sh", "-c", "supergfxctl -m Hybrid; niri msg action quit skip-confirmation=true"] }

    Process { id: pGpuInt; command: ["sh", "-c", "supergfxctl -m Integrated; niri msg action quit skip-confirmation=true"] }
    Process { id: pGpuHyb; command: ["sh", "-c", "supergfxctl -m Hybrid; niri msg action quit skip-confirmation=true"] }
    
    Process { id: pNoteNiri; command: ["zeditor", Quickshell.env("HOME") + "/.config/niri"] }
    Process { id: pNoteTofi; command: ["zeditor", Quickshell.env("HOME") + "/.config/tofi/"] }
    Process { id: pNoteKitty; command: ["zeditor", Quickshell.env("HOME") + "/.config/kitty"] }
    Process { id: pNoteFoot; command: ["zeditor", Quickshell.env("HOME") + "/.config/foot"] }
    Process { id: pNoteGhostty; command: ["zeditor", Quickshell.env("HOME") + "/.config/ghostty"] }
    Process { id: pNoteFish; command: ["zeditor", Quickshell.env("HOME") + "/.config/fish"] }
    Process { id: pNoteFastfetch; command: ["zeditor", Quickshell.env("HOME") + "/.config/fastfetch"] }
    Process { id: pNoteQuickshell; command: ["zeditor", Quickshell.env("HOME") + "/.config/quickshell"] }

    // A helper to make clickable modules easily
    component Mod: MouseArea {
        id: modRoot
        property string text
        property color textColor: root.colFg
        property color bgColor: "transparent"
        property bool blink: false
        property bool show: true
        property real customWidth: 0
        default property alias customContent: contentBox.data
        
        Layout.fillHeight: true
        Layout.preferredWidth: show ? (customWidth > 0 ? customWidth + 16 : modText.implicitWidth + 16) : 0
        Behavior on Layout.preferredWidth { 
            NumberAnimation { duration: root.batteryMode ? 0 : 300; easing.type: Easing.OutExpo } 
        }
        
        visible: Layout.preferredWidth > 0
        clip: true
        hoverEnabled: true

        Rectangle {
            anchors.fill: parent
            color: parent.bgColor
            Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 200 } }
            
            SequentialAnimation on opacity {
                running: modRoot.blink
                loops: Animation.Infinite
                NumberAnimation { to: 0.1; duration: root.batteryMode ? 0 : 500 }
                NumberAnimation { to: 1.0; duration: root.batteryMode ? 0 : 500 }
            }
        }

        Item {
            anchors.centerIn: parent
            width: modText.width
            height: modText.height
            scale: parent.containsPress ? 0.85 : (parent.containsMouse ? 1.1 : 1.0)
            Behavior on scale { 
                NumberAnimation { duration: root.batteryMode ? 0 : 200; easing.type: Easing.OutBack; easing.overshoot: 2.0 } 
            }
            
            Text {
                id: modText
                text: parent.parent.text
                color: parent.parent.textColor
                font { family: root.fontFamily; pixelSize: root.fontSize; bold: true }
                anchors.centerIn: parent
                Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 200 } }
            }
            Item {
                id: contentBox
                anchors.centerIn: parent
            }
        }
    }

    Rectangle {
        id: notchRect
        z: 1
        readonly property real morphDuration: root.batteryMode ? 0 : (controlCenter.show ? 450 : 300)
        readonly property int morphEasing: controlCenter.show ? Easing.OutBack : Easing.OutExpo
        readonly property real morphOvershoot: controlCenter.show ? 1.2 : 0

        opacity: (!root.isAnyPopupAnimActive) || root.isBarMode || controlCenter.show ? 1.0 : 0.0

        anchors.top: parent.top
        anchors.topMargin: controlCenter.show ? 16 : (root.isBarMode ? 0 : 4)
        anchors.horizontalCenter: parent.horizontalCenter
        width: controlCenter.show ? 380 : (root.isBarMode ? parent.width : notchLayout.implicitWidth + 32)
        height: controlCenter.show ? (mainLayout.implicitHeight + 32) : 32
        color: Qt.rgba(0.02, 0.02, 0.02, 0.95)
        radius: controlCenter.show ? 24 : (root.isBarMode ? 0 : 16)
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: notchRect.morphDuration
                easing.type: notchRect.morphEasing
                easing.overshoot: notchRect.morphOvershoot
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: notchRect.morphDuration
                easing.type: notchRect.morphEasing
                easing.overshoot: notchRect.morphOvershoot
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: notchRect.morphDuration
                easing.type: notchRect.morphEasing
                easing.overshoot: notchRect.morphOvershoot
            }
        }
        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: notchRect.morphDuration
                easing.type: notchRect.morphEasing
                easing.overshoot: notchRect.morphOvershoot
            }
        }
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: (controlCenter.show || !root.isBarMode) ? 1 : 0

        MouseArea {
            anchors.fill: parent
            enabled: controlCenter.show
            hoverEnabled: true
        }

        RowLayout {
            id: notchLayout
            enabled: !controlCenter.show && !root.isAnyPopupOpenExceptControl
            opacity: controlCenter.show ? 0 : (root.isAnyPopupOpenExceptControl ? 0 : 1)
            Behavior on opacity { NumberAnimation { duration: root.batteryMode ? 0 : 150 } }
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            spacing: 8
            
            Mod {
                id: spotifyIsland
                text: ""
                bgColor: "transparent"
                customWidth: root.spotifyActive ? Math.min(210, 28 + Math.min(Math.max(root.spotifyTitle.length, root.spotifyArtist.length), 20) * 5.5 + 38) : 0
                show: root.spotifyActive && !root.isAnyPopupOpen && !root.showOsd && !controlCenter.show
                onClicked: {
                    root.closeAllPopupsExcept("control");
                    controlCenter.show = true;
                }

                Item {
                    anchors.centerIn: parent
                    width: spotifyRow.implicitWidth
                    height: 22

                    RowLayout {
                        id: spotifyRow
                        anchors.centerIn: parent
                        spacing: 6

                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: "#141414"
                            clip: true
                            scale: root.spotifyPulse ? 1.12 : 1.0
                            Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }

                            Image {
                                anchors.fill: parent
                                source: root.spotifyArtUrl
                                fillMode: Image.PreserveAspectCrop
                                visible: root.spotifyArtUrl !== ""
                                asynchronous: true
                                cache: true
                            }
                            Text {
                                anchors.centerIn: parent
                                text: "󰓇"
                                visible: root.spotifyArtUrl === ""
                                color: "#1DB954"
                                font.pixelSize: 11
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                text: root.spotifyTitle || root.spotifyText
                                color: root.spotifyStatus === "Playing" ? "#1DB954" : root.colFg
                                font { family: root.fontFamily; pixelSize: 10; bold: true }
                                elide: Text.ElideRight
                                Layout.maximumWidth: 108
                            }
                            Text {
                                text: root.spotifyArtist
                                color: root.colMuted
                                font { family: root.fontFamily; pixelSize: 9 }
                                elide: Text.ElideRight
                                Layout.maximumWidth: 108
                                visible: root.spotifyArtist !== ""
                            }
                        }

                        Text {
                            property int _tick: root.spotifyTick
                            text: root.spotifyElapsedLabel()
                            color: root.colMuted
                            font { family: root.fontFamily; pixelSize: 9 }
                            visible: root.spotifyBars.length < 5
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Row {
                            spacing: 2
                            visible: root.spotifyBars.length >= 5
                            Layout.alignment: Qt.AlignVCenter
                            Repeater {
                                model: 5
                                Rectangle {
                                    property int barVal: root.spotifyBars[index] || 12
                                    width: 3
                                    height: Math.max(4, barVal * 0.15)
                                    radius: 1
                                    color: root.spotifyStatus === "Playing" ? "#1DB954" : root.colMuted
                                    anchors.bottom: parent.bottom
                                    Behavior on height { NumberAnimation { duration: 90 } }
                                }
                            }
                        }
                    }
                }

                Timer {
                    interval: 450
                    running: root.spotifyPulse
                    repeat: false
                    onTriggered: root.spotifyPulse = false
                }
            }

            Repeater {
                model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                Mod {
                    property bool isActive: root.niriFocusedWorkspace === modelData
                    property bool hasWindows: root.niriActiveWorkspaces.indexOf(modelData) !== -1
                    
                    text: modelData
                    textColor: isActive ? root.colFg : root.colMuted
                    bgColor: "transparent"
                    show: (hasWindows || isActive) && !root.showOsd
                    onClicked: {
                        pFocusWorkspace.command = ["niri", "msg", "action", "focus-workspace", String(modelData)]
                        pFocusWorkspace.running = true
                    }
                }
            }

            Mod {
                id: barClockMod
                property string timeText: Qt.formatDateTime(new Date(), "HH:mm")
                text: timeText
                textColor: root.colFg
                bgColor: "transparent"
                customWidth: 42
                show: !root.isAnyPopupOpen && !root.showOsd && !controlCenter.show
                onClicked: {
                    root.closeAllPopupsExcept("control");
                    controlCenter.show = true;
                }
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: barClockMod.timeText = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }
            
            Mod {
                property int cap: parseInt(root.batteryCap)
                property bool isCrit: cap <= 15 && !root.batteryCharging
                property bool isWarn: cap <= 30 && cap > 15 && !root.batteryCharging
                property string battIcon: {
                    if (root.batteryCharging) return "";
                    if (cap > 80) return "";
                    if (cap > 60) return "";
                    if (cap > 40) return "";
                    if (cap > 20) return "";
                    return "";
                }
                
                text: battIcon + " " + cap + "%"
                textColor: {
                    if (isCrit) return root.colCrit;
                    if (isWarn) return "#FFA500";
                    if (root.batteryCharging) return "#76B900";
                    return root.colFg;
                }
                bgColor: "transparent"
                customWidth: 58
                blink: isCrit
                show: !controlCenter.show && !root.showOsd
                onClicked: {
                    root.closeAllPopupsExcept("control");
                    controlCenter.show = true;
                }
            }

            Mod {
                text: "󰍬"
                textColor: "#FF6B6B"
                bgColor: "transparent"
                customWidth: 18
                show: root.micInUse && !controlCenter.show && !root.showOsd && !root.isAnyPopupOpen
            }

            Mod {
                text: "󰄀"
                textColor: "#6BB5FF"
                bgColor: "transparent"
                customWidth: 18
                show: root.cameraInUse && !controlCenter.show && !root.showOsd && !root.isAnyPopupOpen
            }

            Mod {
                text: ""
                textColor: root.colFg
                bgColor: "transparent"
                customWidth: root.pendingMailCode !== "" ? 34 : 0
                show: root.pendingMailCode !== "" && !lazyHostOpen(mailHost) && !root.isAnyPopupOpen && !root.showOsd && !controlCenter.show
                onClicked: {
                    root.closeAllPopupsExcept("mail");
                    root.openLazyPopup(mailHost);
                    if (mailHost.loader.item)
                        mailHost.loader.item.show = true;
                }

                Item {
                    anchors.centerIn: parent
                    width: 30
                    height: 20
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "󰇮"
                            color: "#7CFFB2"
                            font { family: root.fontFamily; pixelSize: root.fontSize + 1 }
                        }
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: Qt.rgba(0.3, 1, 0.5, 0.25)
                            Text {
                                anchors.centerIn: parent
                                text: "•"
                                color: "#7CFFB2"
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            Mod {
                text: ""
                textColor: root.colFg
                bgColor: "transparent"
                customWidth: root.unreadNotifCount > 0 ? 34 : 0
                show: root.unreadNotifCount > 0 && !lazyHostOpen(notificationHost) && !root.isAnyPopupOpen && !root.showOsd && !controlCenter.show
                onClicked: {
                    root.closeAllPopupsExcept("notification");
                    root.openLazyPopup(notificationHost);
                    if (notificationHost.loader.item)
                        notificationHost.loader.item.show = true;
                }

                Item {
                    anchors.centerIn: parent
                    width: 30
                    height: 20
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "󰂚"
                            color: root.colFg
                            font { family: root.fontFamily; pixelSize: root.fontSize + 1 }
                        }
                        Rectangle {
                            width: Math.max(14, notifCount.implicitWidth + 8)
                            height: 14
                            radius: 7
                            color: Qt.rgba(1, 1, 1, 0.18)
                            Text {
                                id: notifCount
                                anchors.centerIn: parent
                                text: String(root.unreadNotifCount)
                                color: root.colFg
                                font { family: root.fontFamily; pixelSize: 9; bold: true }
                            }
                        }
                    }
                }
            }

            Mod {
                property bool isActive: root.stopwatchRunning || root.stopwatchSeconds > 0
                text: "󱎫 " + root.stopwatchText
                textColor: root.stopwatchRunning ? "#FFA500" : root.colFg
                bgColor: "transparent"
                show: isActive && !controlCenter.show && !root.showOsd
                onClicked: {
                    root.closeAllPopupsExcept("control");
                    controlCenter.show = true;
                }
            }
            
            Mod {
                property bool isActive: root.timerRunning || (root.timerSeconds > 0 && root.timerSeconds < root.timerTotal)
                text: "󰔛 " + root.timerText
                textColor: root.timerRunning ? "#FFA500" : root.colFg
                bgColor: "transparent"
                show: isActive && !controlCenter.show && !root.showOsd
                onClicked: {
                    root.closeAllPopupsExcept("control");
                    controlCenter.show = true;
                }
            }
            
            Mod {
                text: root.batteryMode ? "  Power Saver" : "  Performance"
                textColor: root.batteryMode ? "#FFCC00" : "#76B900"
                bgColor: "transparent"
                show: root.showBatteryModeIndicator && !controlCenter.show && !root.showOsd
            }

            Mod {
                text: ""
                textColor: root.colFg
                bgColor: "transparent"
                show: root.showOsd
                customWidth: 140
                
                Item {
                    anchors.centerIn: parent
                    width: 140
                    height: 16
                    RowLayout {
                        anchors.fill: parent
                        spacing: 8
                        Text {
                            text: root.osdIcon
                            color: root.colFg
                            font { family: root.fontFamily; pixelSize: root.fontSize + 2 }
                        }
                        Text {
                            visible: root.osdText !== "" && root.osdText !== "0%"
                            text: root.osdText
                            color: root.colFg
                            font { family: root.fontFamily; pixelSize: root.fontSize }
                        }
                        Item {
                            visible: root.osdText === "" || root.osdText === "0%" || root.osdText.endsWith("%")
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 4
                                radius: 2
                                color: root.colMuted
                                Rectangle {
                                    height: parent.height
                                    width: parent.width * (root.osdValue / 100)
                                    radius: 2
                                    color: root.colFg
                                }
                            }
                        }
                    }
                }
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 16
            opacity: controlCenter.show ? 1.0 : 0.0
            enabled: controlCenter.show
            visible: opacity > 0.01
            Behavior on opacity { 
                NumberAnimation { 
                    duration: root.batteryMode ? 0 : controlCenter.show ? 300 : 100
                    easing.type: Easing.InOutQuad 
                } 
            }
            clip: true

            ColumnLayout {
                id: mainLayout
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8
                    
            // Header: Clock & Date & Battery
            RowLayout {
                Layout.fillWidth: true
                        
                ColumnLayout {
                    spacing: 4
                    Text {
                        id: clockText
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: 24
                        font.bold: true
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                        }
                    }
                    Text {
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                    }
                }
                        
                Item { Layout.fillWidth: true }
                        
                // Battery Close Button
                MouseArea {
                    property int cap: parseInt(root.batteryCap)
                    property bool isCrit: cap <= 15 && !root.batteryCharging
                    property bool isWarn: cap <= 30 && cap > 15 && !root.batteryCharging
                            
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: battLayout.implicitWidth + 24
                    hoverEnabled: true
                    onClicked: { controlCenter.show = false }
                            
                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: parent.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.1)
                        Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 150 } }
                    }
                            
                    RowLayout {
                        id: battLayout
                        anchors.centerIn: parent
                        spacing: 10
                        Text { 
                            text: {
                                let cap = parseInt(root.batteryCap);
                                if (root.batteryCharging) return "";
                                if (cap > 80) return "";
                                if (cap > 60) return "";
                                if (cap > 40) return "";
                                if (cap > 20) return "";
                                return "";
                            }
                            color: {
                                let cap = parseInt(root.batteryCap);
                                let isCrit = cap <= 15 && !root.batteryCharging;
                                let isWarn = cap <= 30 && cap > 15 && !root.batteryCharging;
                                return isCrit ? root.colCrit : (isWarn ? "#FFA500" : (root.batteryCharging ? "#76B900" : root.colFg));
                            }
                            font.family: root.fontFamily
                            font.pixelSize: 18 
                        }
                        Text { 
                            text: root.batteryCap + "%"
                            color: root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.bold: true 
                        }
                        Text {
                            visible: root.micInUse
                            text: "󰍬"
                            color: "#FF6B6B"
                            font.family: root.fontFamily
                            font.pixelSize: 14
                        }
                        Text {
                            visible: root.cameraInUse
                            text: "󰄀"
                            color: "#6BB5FF"
                            font.family: root.fontFamily
                            font.pixelSize: 14
                        }
                    }
                            
                    scale: containsPress ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150; easing.type: Easing.OutBack } }
                }
            }
                    
            // System Stats (Moved under clock)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                        
                Text { text: "󱐋 " + root.powerDraw + "W"; color: root.colMuted; font.family: root.fontFamily; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                Text { text: " " + root.temperature + "°"; color: parseInt(root.temperature) >= 80 ? root.colCrit : root.colMuted; font.family: root.fontFamily; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                Text { text: "󰮯 " + root.updates; color: root.colMuted; font.family: root.fontFamily; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter; visible: parseInt(root.updates) > 0 }
            }
                    
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1,1,1,0.1) }
                    
            // Spotify Media Player
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: root.spotifyActive
                        
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 6
                        color: "#141414"
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: root.spotifyArtUrl
                            fillMode: Image.PreserveAspectCrop
                            visible: root.spotifyArtUrl !== ""
                            asynchronous: true
                        }
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            visible: root.spotifyArtUrl === ""
                            color: "#1DB954"
                            font.family: root.fontFamily
                            font.pixelSize: 20
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.spotifyTitle || root.spotifyText
                            color: root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: root.spotifyArtist
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: root.spotifyArtist !== ""
                        }
                        Text {
                            property int _tick: root.spotifyTick
                            text: root.spotifyElapsedLabel() + (root.spotifyDurationMs > 0 ? (" / " + root.formatMs(root.spotifyDurationMs)) : "")
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }
                        
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Item { Layout.fillWidth: true }
                    ModernButton { Layout.preferredWidth: 48; Layout.preferredHeight: 40; iconText: "󰒮"; onClicked: root.runSpotifyCtl("previous") }
                    ModernButton { Layout.preferredWidth: 64; Layout.preferredHeight: 40; iconText: root.spotifyStatus === "Playing" ? "󰏤" : "󰐊"; isActive: root.spotifyStatus === "Playing"; accent: "#1DB954"; onClicked: root.runSpotifyCtl("play-pause") }
                    ModernButton { Layout.preferredWidth: 48; Layout.preferredHeight: 40; iconText: "󰒭"; onClicked: root.runSpotifyCtl("next") }
                    Item { Layout.fillWidth: true }
                }
            }
                    
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1,1,1,0.1); visible: root.spotifyActive }

            // Sliders
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                        
                // Volume
                RowLayout {
                    spacing: 8
                    MouseArea {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        hoverEnabled: true
                        onClicked: pVolMute.running = true
                        scale: containsPress ? 0.9 : (containsMouse ? 1.1 : 1.0)
                        Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.volumeMuted ? "󰝟" : ""
                            color: root.volumeMuted ? root.colMuted : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: 18 
                        }
                    }
                    ModernSlider {
                        value: parseInt(root.volumeOut) / 100.0
                        onMoved: {
                            root.volumeOut = Math.round(value * 100) + "%"
                            pVolSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)]
                            pVolSet.running = true
                        }
                    }
                            
                }
                        
                // Mic
                RowLayout {
                    spacing: 8
                    MouseArea {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        hoverEnabled: true
                        onClicked: pMicMute.running = true
                        scale: containsPress ? 0.9 : (containsMouse ? 1.1 : 1.0)
                        Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.micMuted ? "" : ""
                            color: root.micMuted ? root.colMuted : root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: 18 
                        }
                    }
                    ModernSlider {
                        value: parseInt(root.volumeMic) / 100.0
                        onMoved: {
                            root.volumeMic = Math.round(value * 100) + "%"
                            pVolSet.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", value.toFixed(2)]
                            pVolSet.running = true
                        }
                    }
                            
                }
                // Brightness
                RowLayout {
                    spacing: 8
                    Text { text: "󰃠"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 18 }
                    ModernSlider {
                        value: parseInt(root.brightnessLevel) / 100.0
                        onMoved: {
                            root.brightnessLevel = Math.round(value * 100) + "%"
                            pBrightSet.command = ["brightnessctl", "s", Math.round(value * 100) + "%"]
                            pBrightSet.running = true
                        }
                    }
                            
                }

                // Keyboard Brightness
               // RowLayout {
               //     spacing: 8
               //     Text { text: "󰌌"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 18 }
               //     ModernSlider {
               //         value: parseInt(root.kbdBrightnessLevel) / 3.0
               //         stepSize: 1.0 / 3.0
               //         snapMode: Slider.SnapAlways
               //         onMoved: {
               //             var levels = ["off", "low", "med", "high"];
               //             var idx = Math.round(value * 3);
               //             root.kbdBrightnessLevel = idx.toString();
               //             pKbdBrightSet.command = ["asusctl", "leds", "set", levels[idx]];
               //             pKbdBrightSet.running = true;
               //         }
               //     }
               // }

                // Wattage
                //RowLayout {
                //    spacing: 8
                //    Text { text: "󱐋"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 18 }
                //    ModernSlider {
                //        value: (root.cpuWattage - 3) / 42.0
                //        onMoved: {
                //            var watts = Math.round(3 + value * 42)
                //            root.cpuWattage = watts
                //            pWattSet.command = ["setwatt", watts.toString()]
                //            pWattSet.running = true
                //        }
                //    }
                //    Text { 
                //        text: root.cpuWattage + "W"
                //        color: root.colFg
                //        font.family: root.fontFamily
                //        font.pixelSize: 12
                //        Layout.minimumWidth: 24
                //        horizontalAlignment: Text.AlignRight
                //    }
                //}

                // Battery Limit
                //RowLayout {
                //    spacing: 8
                //    Text { text: "󰁹"; color: root.colFg; font.family: root.fontFamily; font.pixelSize: 18 }
                //    ModernSlider {
                //        value: (root.batLimit - 20) / 80.0
                //        onMoved: {
                //            var limit = Math.round(20 + value * 80)
                //            root.batLimit = limit
                //            pBatLimitSet.command = ["asusctl", "battery", "limit", limit.toString()]
                //            pBatLimitSet.running = true
                //        }
                //    }
                //    Text { 
                //        text: root.batLimit + "%"
                //        color: root.colFg
                //        font.family: root.fontFamily
                //        font.pixelSize: 12
                //        Layout.minimumWidth: 24
                //        horizontalAlignment: Text.AlignRight
                //    }
                //}

            }
                    
            // Toggles Row 1
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                        
                ModernSplitButton {
                    text: "Bluetooth"
                    iconText: root.bluetoothStatus === "on" ? "" : "󰂲"
                    isActive: root.bluetoothStatus === "on"
                    accent: "#007AFF"
                    onMainClicked: { root.closeAllPopupsExcept("bluetooth"); root.openLazyPopup(bluetoothHost); controlCenter.show = false }
                    onRightIconClicked: { root.closeAllPopupsExcept("bluetooth"); root.openLazyPopup(bluetoothHost); controlCenter.show = false }
                    onIconClicked: { 
                        root.bluetoothStatus = (root.bluetoothStatus === "on") ? "off" : "on"
                        pBtToggle.running = true 
                    }
                }
                        
                ModernSplitButton {
                    text: root.wifiText === "Disconnected" ? "Wi-Fi" : root.wifiText
                    iconText: root.wifiIcon
                    isActive: root.wifiText !== "Disconnected"
                    accent: "#007AFF"
                    onMainClicked: { root.closeAllPopupsExcept("wifi"); root.openLazyPopup(wifiHost); controlCenter.show = false }
                    onRightIconClicked: { root.closeAllPopupsExcept("wifi"); root.openLazyPopup(wifiHost); controlCenter.show = false }
                    onIconClicked: { pWifiToggle.running = true }
                }
            }
                    
            // Toggles Row 3 (Timer and Stopwatch)
            RowLayout {
                spacing: 8
                Layout.fillWidth: true
                        
                ModernSplitButton {
                    text: root.stopwatchText
                    iconText: "󱎫"
                    isActive: root.stopwatchRunning || root.stopwatchSeconds > 0
                    accent: "#FFA500"
                    onMainClicked: {
                        if (root.stopwatchRunning) {
                            root.stopwatchRunning = false;
                        } else {
                            root.stopwatchRunning = true;
                        }
                    }
                    onRightIconClicked: {
                        if (root.stopwatchRunning) {
                            root.stopwatchRunning = false;
                        } else {
                            root.stopwatchRunning = true;
                        }
                    }
                    onIconClicked: { 
                        root.stopwatchRunning = false;
                        root.stopwatchSeconds = 0;
                        root.stopwatchText = "00:00";
                    }
                }
                        
                ModernSplitButton {
                    id: btnTimer
                    text: root.timerText
                    iconText: "󰔛"
                    isActive: root.timerRunning || (root.timerSeconds > 0 && root.timerSeconds < root.timerTotal)
                    accent: "#FFA500"
                    onMainClicked: {
                        root.pomodoroState = 0;
                        if (root.timerRunning) {
                            root.timerRunning = false;
                        } else if (root.timerSeconds > 0) {
                            root.timerRunning = true;
                        } else {
                            root.timerSeconds = root.timerTotal;
                            root.timerText = root.formatTime(root.timerTotal);
                            root.timerRunning = true;
                        }
                    }
                    onIconClicked: { 
                        root.pomodoroState = 0;
                        root.timerRunning = false;
                        root.timerSeconds = 0;
                        root.timerText = root.formatTime(root.timerTotal);
                    }
                    onRightIconClicked: {
                        timerPopup.show = !timerPopup.show;
                    }
                    onScrolled: angle => {
                        root.pomodoroState = 0;
                        if (angle > 0) {
                            root.timerTotal += 60;
                        } else if (angle < 0 && root.timerTotal >= 120) {
                            root.timerTotal -= 60;
                        }
                        root.timerRunning = false;
                        root.timerSeconds = 0;
                        root.timerText = root.formatTime(root.timerTotal);
                    }
                }


            }

            // Toggles Row 2 (GPU, Configs, Power Saver)
            //RowLayout {
            //    spacing: 8
            //    Layout.fillWidth: true
            //    
            //    ModernButton {
            //        id: btnGpu
            //        text: root.gpuMode.charAt(0)
            //        iconText: "󰢮"
            //        isActive: root.gpuMode === "Hybrid" || root.gpuMode === "Nvidia"
            //        accent: "#76B900"
            //        onClicked: { gpuPopup.show = !gpuPopup.show; notesPopup.show = false; timerPopup.show = false }
            //    }
            //    ModernButton {
            //        id: btnNotes
            //        text: ""
            //        iconText: ""
            //        onClicked: { notesPopup.show = !notesPopup.show; gpuPopup.show = false; timerPopup.show = false }
            //    }
            //    ModernButton {
            //        id: btnBatteryMode
            //        text: ""
            //        iconText: root.batteryMode ? "" : ""
            //        isActive: root.batteryMode
            //        accent: "#FFCC00"
            //        onClicked: pToggleBatteryMode.running = true
            //    }
            //    ModernButton {
            //        id: btnPomodoro
            //        text: ""
            //        iconText: "󰄉"
            //        isActive: root.pomodoroState > 0
            //        accent: root.pomodoroState === 1 ? "#FF4500" : "#00FA9A"
            //        onClicked: {
            //            if (root.pomodoroState === 0) {
            //                root.pomodoroState = 1; // Start work
            //                root.timerTotal = root.pomodoroWorkTotal;
            //                root.timerSeconds = root.timerTotal;
            //                root.timerText = root.formatTime(root.timerTotal);
            //                root.timerRunning = true;
            //            } else {
            //                root.pomodoroState = 0; // Turn off
            //                root.timerRunning = false;
            //                root.timerSeconds = 0;
            //                root.timerTotal = 300; // Reset to 5m
            //                root.timerText = root.formatTime(root.timerTotal);
            //            }
            //        }
            //    }
            //}

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1,1,1,0.1) }

            RowLayout {
                spacing: 8
                Layout.fillWidth: true

                ModernButton {
                    Layout.fillWidth: true
                    text: "Suspend"
                    iconText: "⏾"
                    onClicked: { controlCenter.show = false; pCcSuspend.running = true }
                }
                ModernButton {
                    Layout.fillWidth: true
                    text: "Lock"
                    iconText: ""
                    onClicked: { controlCenter.show = false; pCcLock.running = true }
                }
                ModernButton {
                    Layout.fillWidth: true
                    text: "Off"
                    iconText: "⏻"
                    onClicked: { controlCenter.show = false; pCcShutdown.running = true }
                }
                ModernButton {
                    Layout.fillWidth: true
                    text: "Reboot"
                    iconText: ""
                    onClicked: { controlCenter.show = false; pCcReboot.running = true }
                }
            }

            }
        }
    }

    component ModernBatteryIcon: Item {
        id: battIcon
        property real level: 1.0
        property bool charging: false
        property color colFg: root.colFg
        
        implicitWidth: 32
        implicitHeight: 14
        
        Rectangle {
            id: outline
            width: 26
            height: 12
            anchors.verticalCenter: parent.verticalCenter
            color: "transparent"
            border.color: battIcon.colFg
            border.width: 1.5
            radius: 4
            opacity: 0.7
            
            Rectangle {
                id: fill
                x: 2
                y: 2
                width: Math.max(0, (parent.width - 4) * battIcon.level)
                height: parent.height - 4
                radius: 2
                color: {
                    if (battIcon.charging) return "#76B900";
                    if (battIcon.level <= 0.2) return "#FF3B30";
                    return battIcon.colFg;
                }
                Behavior on width { NumberAnimation { duration: root.batteryMode ? 0 : 300; easing.type: Easing.OutCubic } }
            }
        }
        
        Rectangle {
            width: 3
            height: 6
            anchors.left: outline.right
            anchors.leftMargin: 1
            anchors.verticalCenter: parent.verticalCenter
            color: battIcon.colFg
            opacity: 0.7
            radius: 1.5
        }
        
        Text {
            visible: battIcon.charging
            text: ""
            font.pixelSize: 9
            color: "#ffffff"
            anchors.centerIn: outline
        }
    }


    component ModernSplitButton: Item {
        id: mbtn
        property string text
        property string iconText
        property bool isActive: false
        property color accent: root.colFg
        
        signal mainClicked()
        signal iconClicked()
        signal rightIconClicked()
        signal scrolled(int angle)
        
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        
        Rectangle {
            anchors.fill: parent
            radius: 12
            color: mainMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.1)
            border.color: "transparent"
            Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 150 } }
        }
        
        MouseArea {
            id: mainMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: mbtn.mainClicked()
            onWheel: wheel => mbtn.scrolled(wheel.angleDelta.y)
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 12
            spacing: 8
            
            // Icon Circle Box
            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: mbtn.isActive ? mbtn.accent : Qt.rgba(1, 1, 1, 0.15)
                
                Text {
                    anchors.centerIn: parent
                    text: mbtn.iconText
                    color: mbtn.isActive ? "#ffffff" : root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 16
                }
                
                MouseArea {
                    id: iconMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: mbtn.iconClicked()
                }
                
                scale: iconMouse.containsPress ? 0.9 : (iconMouse.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150 } }
                Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 150 } }
            }
            
            Text { 
                text: mbtn.text
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: 14
                font.bold: true
                Layout.fillWidth: true
            }
            
            Item {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                
                Text {
                    anchors.centerIn: parent
                    text: ""
                    color: rightIconMouse.containsMouse ? root.colFg : Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.3)
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 150 } }
                }
                
                MouseArea {
                    id: rightIconMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: mbtn.rightIconClicked()
                }
            }
        }
        
        scale: mainMouse.containsPress ? 0.98 : 1.0
        Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150; easing.type: Easing.OutBack } }
    }

    component ModernButton: MouseArea {
        id: mbtn
        property string text
        property string iconText
        property bool isActive: false
        property color accent: root.colFg
        
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        hoverEnabled: true
        
        Rectangle {
            anchors.fill: parent
            radius: 12
            color: mbtn.isActive ? Qt.rgba(mbtn.accent.r, mbtn.accent.g, mbtn.accent.b, 0.15) 
                                 : (mbtn.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.1))
            border.color: mbtn.isActive ? Qt.rgba(mbtn.accent.r, mbtn.accent.g, mbtn.accent.b, 0.3) : "transparent"
            border.width: 1
            Behavior on color { ColorAnimation { duration: root.batteryMode ? 0 : 150 } }
        }
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 4
            Text { text: mbtn.iconText; color: mbtn.isActive ? mbtn.accent : root.colFg; font.family: root.fontFamily; font.pixelSize: 14 }
            Text { text: mbtn.text; color: mbtn.isActive ? mbtn.accent : root.colFg; font.family: root.fontFamily; font.pixelSize: 11; font.bold: true }
        }
        
        scale: containsPress ? 0.95 : 1.0
        Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 150; easing.type: Easing.OutBack } }
    }

    component ModernSlider: Slider {
        id: mSlider
        Layout.fillWidth: true
        from: 0; to: 1.0
        
        background: Rectangle {
            x: mSlider.leftPadding
            y: mSlider.topPadding + mSlider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 8
            width: mSlider.availableWidth
            height: implicitHeight
            radius: 4
            color: Qt.rgba(1, 1, 1, 0.1)
            Rectangle {
                width: mSlider.visualPosition * parent.width
                height: parent.height
                color: root.colFg
                radius: 4
            }
        }
        
        handle: Rectangle {
            x: mSlider.leftPadding + mSlider.visualPosition * (mSlider.availableWidth - width)
            y: mSlider.topPadding + mSlider.availableHeight / 2 - height / 2
            implicitWidth: 16
            implicitHeight: 16
            radius: 8
            color: mSlider.pressed ? Qt.rgba(0.8, 0.8, 0.8, 1) : "#ffffff"
            scale: mSlider.pressed || mSlider.hovered ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 100 } }
            
        }
    }


    Item {
        id: powerHost
        property bool pendingOpen: false
        property alias loader: powerLazy
        LazyLoader {
            id: powerLazy
            active: powerHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && powerHost.pendingOpen && item) item.show = true }
            PowerMenu {
                shellRoot: root
                onShowChanged: if (!show) powerHost.pendingOpen = false
            }
        }
    }

    Item {
        id: appLauncherHost
        property bool pendingOpen: false
        property alias loader: appLauncherLazy
        LazyLoader {
            id: appLauncherLazy
            active: appLauncherHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && appLauncherHost.pendingOpen && item) item.show = true }
            AppLauncher {
                shellRoot: root
                onShowChanged: if (!show) appLauncherHost.pendingOpen = false
            }
        }
    }

    Item {
        id: clipboardHost
        property bool pendingOpen: false
        property alias loader: clipboardLazy
        LazyLoader {
            id: clipboardLazy
            active: clipboardHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && clipboardHost.pendingOpen && item) item.show = true }
            ClipboardManager {
                shellRoot: root
                onShowChanged: if (!show) clipboardHost.pendingOpen = false
            }
        }
    }

    Item {
        id: themeHost
        property bool pendingOpen: false
        property alias loader: themeLazy
        LazyLoader {
            id: themeLazy
            active: themeHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && themeHost.pendingOpen && item) item.show = true }
            ThemeSwitcher {
                shellRoot: root
                onShowChanged: if (!show) themeHost.pendingOpen = false
            }
        }
    }

    Item {
        id: wallpaperHost
        property bool pendingOpen: false
        property alias loader: wallpaperLazy
        LazyLoader {
            id: wallpaperLazy
            active: wallpaperHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && wallpaperHost.pendingOpen && item) item.show = true }
            WallpaperSwitcher {
                shellRoot: root
                onShowChanged: if (!show) wallpaperHost.pendingOpen = false
            }
        }
    }

    Item {
        id: wifiHost
        property bool pendingOpen: false
        property alias loader: wifiLazy
        LazyLoader {
            id: wifiLazy
            active: wifiHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && wifiHost.pendingOpen && item) item.show = true }
            WifiMenu {
                shellRoot: root
                onShowChanged: if (!show) wifiHost.pendingOpen = false
            }
        }
    }

    Item {
        id: bluetoothHost
        property bool pendingOpen: false
        property alias loader: bluetoothLazy
        LazyLoader {
            id: bluetoothLazy
            active: bluetoothHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && bluetoothHost.pendingOpen && item) item.show = true }
            BluetoothMenu {
                shellRoot: root
                onShowChanged: if (!show) bluetoothHost.pendingOpen = false
            }
        }
    }

    Item {
        id: mailHost
        property bool pendingOpen: false
        property alias loader: mailLazy
        LazyLoader {
            id: mailLazy
            active: mailHost.pendingOpen || (item && (item.show || item.animHeight > 36))
            onActiveChanged: { if (active && mailHost.pendingOpen && item) item.show = true }
            MailManager {
                shellRoot: root
                onShowChanged: if (!show) mailHost.pendingOpen = false
            }
        }
    }

    Item {
        id: notificationHost
        property bool pendingOpen: false
        property alias loader: notificationLazy
        LazyLoader {
            id: notificationLazy
            active: notificationHost.pendingOpen || root.pendingNotifications.length > 0
                || root.unreadNotifCount > 0
                || (item && (item.show || item.animHeight > 36))
            onActiveChanged: {
                if (active && notificationHost.pendingOpen && item)
                    item.show = true;
                if (active && item)
                    root.flushPendingNotifications();
            }
            NotificationIsland {
                shellRoot: root
                onShowChanged: {
                    if (!show) notificationHost.pendingOpen = false;
                    root.syncUnreadFromIsland();
                }
            }
        }
    }

    NotificationServer {
        id: notificationServer
        bodySupported: true
        bodyImagesSupported: false
        imageSupported: false
        actionsSupported: true
        keepOnReload: false

        onNotification: (notification) => {
            root.deliverNotification(notification);
        }
    }
    
    IpcHandler {
        id: qsIpc
        target: "qsIpc"
        function showOsd(type: string, val: string) {
            root.applyOsd(type, val);
        }
        function openAppLauncher() {
            root.dispatchQsCommand("openAppLauncher");
        }
        function toggleAppLauncher() {
            if (lazyHostOpen(appLauncherHost)) {
                closeLazyPopup(appLauncherHost);
            } else {
                openAppLauncher();
            }
        }
        function togglePowerMenu() {
            if (lazyHostOpen(powerHost)) {
                closeLazyPopup(powerHost);
            } else {
                root.closeAllPopupsExcept("power");
                openLazyPopup(powerHost);
            }
        }
        function toggleClipboard() {
            if (lazyHostOpen(clipboardHost)) {
                closeLazyPopup(clipboardHost);
            } else {
                root.closeAllPopupsExcept("clipboard");
                openLazyPopup(clipboardHost);
            }
        }
        function toggleThemeSwitcher() {
            if (lazyHostOpen(themeHost)) {
                closeLazyPopup(themeHost);
            } else {
                root.closeAllPopupsExcept("theme");
                openLazyPopup(themeHost);
            }
        }
        function toggleWifiMenu() {
            if (lazyHostOpen(wifiHost)) {
                closeLazyPopup(wifiHost);
            } else {
                root.closeAllPopupsExcept("wifi");
                openLazyPopup(wifiHost);
            }
        }
        function toggleBluetoothMenu() {
            if (lazyHostOpen(bluetoothHost)) {
                closeLazyPopup(bluetoothHost);
            } else {
                root.closeAllPopupsExcept("bluetooth");
                openLazyPopup(bluetoothHost);
            }
        }
        function toggleControlCenter() {
            root.closeAllPopupsExcept("control");
            controlCenter.show = !controlCenter.show;
        }
        function openControlCenter() {
            root.closeAllPopupsExcept("control");
            controlCenter.show = true;
        }
        function openClipboard() {
            root.dispatchQsCommand("openClipboard");
        }
        function openPowerMenu() {
            root.closeAllPopupsExcept("power");
            openLazyPopup(powerHost);
        }
        function openThemeSwitcher() {
            root.dispatchQsCommand("openThemeSwitcher");
        }
        function openWallpaperPicker() {
            root.dispatchQsCommand("openWallpaperPicker");
        }
        function openAppLauncherForce() {
            openAppLauncher();
        }
        function toggleNotifications() {
            if (lazyHostOpen(notificationHost)) {
                closeLazyPopup(notificationHost);
            } else {
                root.closeAllPopupsExcept("notification");
                openLazyPopup(notificationHost);
                if (notificationHost.loader.item)
                    notificationHost.loader.item.show = true;
            }
        }
        function openMail() {
            root.dispatchQsCommand("openMail");
        }
        function refreshBatteryMode() {
            pBatteryModeCheck.running = true;
        }
    }

    }

PopupWindow {
    id: timerPopup
    visible: controlCenter.show && (show || animRectTimer.opacity > 0)
    grabFocus: show
    anchor {
        window: root
        rect: Qt.rect(btnTimer.mapToItem(null, 0, 0).x, btnTimer.mapToItem(null, 0, 0).y, btnTimer.width, btnTimer.height)
        edges: Edges.Left | Edges.Top
        gravity: Edges.Left | Edges.Bottom
    }
        
    property bool show: false
    onShowChanged: {
        if (show) {
            timerInput.text = "";
            timerInput.forceActiveFocus();
        }
    }
    property real animHeight: animRectTimer.height
        
    implicitWidth: 200
    implicitHeight: layoutTimer.implicitHeight + 32
    color: "transparent"
        
    Item {
        anchors.fill: parent
            
        Rectangle {
            id: animRectTimer
            anchors.fill: parent
                
            anchors.rightMargin: 12
                
            color: Qt.rgba(0.08, 0.08, 0.08, 0.95)
            radius: 16
            border.color: Qt.rgba(1, 1, 1, 0.1)
            border.width: 1
                
            opacity: timerPopup.show ? 1.0 : 0.0
            scale: timerPopup.show ? 1.0 : 0.95
            x: timerPopup.show ? 0 : 20
            Behavior on opacity { NumberAnimation { duration: root.batteryMode ? 0 : 200 } }
            Behavior on scale { NumberAnimation { duration: root.batteryMode ? 0 : 350; easing.type: Easing.OutBack } }
            Behavior on x { NumberAnimation { duration: root.batteryMode ? 0 : 350; easing.type: Easing.OutBack } }
                
            ColumnLayout {
                id: layoutTimer
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 16
                spacing: 8
                Text { text: "Timer Minutes"; color: Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.5); font.family: root.fontFamily; font.pixelSize: 12 }
                    
                TextField {
                    id: timerInput
                    Layout.fillWidth: true
                    placeholderText: "e.g. 5"
                    color: root.colFg
                    background: Rectangle {
                        color: Qt.rgba(1, 1, 1, 0.1)
                        radius: 8
                        border.color: timerInput.activeFocus ? Qt.rgba(1, 1, 1, 0.3) : "transparent"
                    }
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    onAccepted: {
                        let val = parseInt(text);
                        if (!isNaN(val) && val > 0) {
                            root.pomodoroState = 0;
                            root.timerTotal = val * 60;
                            root.timerSeconds = 0;
                            root.timerText = root.formatTime(root.timerTotal);
                            root.timerRunning = false;
                        }
                        timerPopup.show = false;
                    }
                }
            }
        }
    }
}

}