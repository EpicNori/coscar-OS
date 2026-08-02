import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Basic 2.15
import Qt5Compat.GraphicalEffects
import QtQuick.Effects
import "." as App
import "./gauges"

Item {
    // Local dp/dpMin wrappers — work around Qt Android singleton-function bug.
    function dp(size) { return Math.round(size * (App.Spacing.effectiveScale || 1.0)) }
    function dpMin(size, floor) { return Math.max(floor, Math.round(size * (App.Spacing.effectiveScale || 1.0))) }

    id: mainMenu
    property StackView stackView
    property ApplicationWindow mainWindow
    property real windowWidth
    property real windowHeight
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    // Global font binding for all text in this component
    // fontFamily always returns a valid font (systemDefaultFont or custom font)
    property string globalFont: App.Style.fontFamily

    // Media source property - determines if Spotify is active
    property bool useSpotify: settingsManager && settingsManager.mediaSource === "spotify" &&
                              spotifyManager && spotifyManager.is_connected()

    // Spotify track info cache (updated from signals)
    property string spotifyTrackName: ""
    property string spotifyArtist: ""
    property string spotifyAlbum: ""
    property string spotifyAlbumArt: ""

    // Media content properties - unified for both local and Spotify
    property string currentFile: ""
    property string currentArt: {
        if (useSpotify && spotifyAlbumArt) {
            return spotifyAlbumArt
        }
        return _localArt || "./assets/missing_art.png"
    }
    property string currentTitle: {
        if (useSpotify && spotifyTrackName) {
            return spotifyTrackName
        }
        return _localTitle || ""
    }
    property string currentArtist: {
        if (useSpotify && spotifyArtist) {
            return spotifyArtist
        }
        return _localArtist || ""
    }
    property string currentAlbum: {
        if (useSpotify && spotifyAlbum) {
            return spotifyAlbum
        }
        return _localAlbum || ""
    }

    // Internal properties for local media (to avoid binding loops)
    property string _localArt: ""
    property string _localTitle: ""
    property string _localArtist: ""
    property string _localAlbum: ""

    function formatTime(ms) {
        var minutes = Math.floor(ms / 60000)
        var seconds = Math.floor((ms % 60000) / 1000)
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    // Glass dashboard canvas: the background and panels stay calm so the
    // driver can read the music and vehicle state at a glance.
    Image {
        id: dashboardBackground
        anchors.fill: parent
        source: App.Style.glassBackgroundImage
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#87061B2A"
    }

    Rectangle {
        anchors.fill: parent
        color: "#2200D7E8"
        opacity: dashboardBackground.status === Image.Ready ? 0.18 : 0
    }

    property bool compactLayout: width < dp(980)
    property var dashboardParameters: App.OBDParameterModel.parameterInfo

    function obdValue(paramId) {
        return App.OBDParameterModel.paramValues[paramId] || 0
    }

    function openMedia() {
        var defaultPage = settingsManager ? settingsManager.musicButtonDefaultPage : "mediaRoom"
        var targetPage = defaultPage === "mediaPlayer" ? "MediaPlayer.qml" : "MediaRoom.qml"
        var props = { stackView: mainMenu.stackView }
        if (defaultPage === "mediaPlayer") props.mainWindow = mainWindow
        stackView.push(targetPage, props)
    }

    function openObd() {
        stackView.push("OBDMenu.qml", { stackView: stackView, mainWindow: mainWindow })
    }

    function openSettings() {
        stackView.push("SettingsMenu.qml", {
            stackView: stackView,
            mainWindow: mainWindow,
            initialSection: "displaySettings"
        })
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: dp(18)
        spacing: dp(16)

        // The reference direction uses a left rail. The existing bottom bar
        // remains available for transport controls and legacy navigation.
        Rectangle {
            id: dashboardRail
            visible: !mainMenu.compactLayout
            Layout.preferredWidth: dp(92)
            Layout.fillHeight: true
            radius: App.Style.glassRadius
            color: App.Style.glassPanel
            border.color: App.Style.glassBorder
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: dp(10)
                spacing: dp(12)

                Text {
                    text: "coscar-OS"
                    color: App.Style.glassText
                    font.family: mainMenu.globalFont
                    font.pixelSize: dp(13)
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: App.Style.glassDivider }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: dp(72)
                    radius: App.Style.glassSmallRadius
                    color: App.Style.glassPanelStrong
                    border.color: App.Style.glassAccent
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: dp(5)
                        Image {
                            id: railHomeIcon
                            source: "./assets/home_button.svg"
                            width: dp(25); height: dp(25)
                            anchors.horizontalCenter: parent.horizontalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                        Text { text: "Home"; color: App.Style.glassText; font.pixelSize: dp(11); anchors.horizontalCenter: parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill: parent; onClicked: mainWindow.navigateHome() }
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "EDIT\nDASHBOARD"
                    color: App.Style.glassMutedText
                    font.family: mainMenu.globalFont
                    font.pixelSize: dp(9)
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }
        }

        ColumnLayout {
            id: dashboardContent
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: dp(14)

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: dp(42)

                Column {
                    spacing: dp(2)
                    Text { text: "HOME"; color: App.Style.glassAccent; font.pixelSize: dp(12); font.bold: true; font.family: mainMenu.globalFont }
                    Text { text: "Your drive, at a glance"; color: App.Style.glassMutedText; font.pixelSize: dp(11); font.family: mainMenu.globalFont }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: dp(150)
                    Layout.preferredHeight: dp(34)
                    radius: height / 2
                    color: App.Style.glassPanelSoft
                    border.color: App.Style.glassBorder
                    border.width: 1
                    Row {
                        anchors.centerIn: parent
                        spacing: dp(7)
                        Rectangle { width: dp(8); height: width; radius: width / 2; color: App.Style.glassSuccess; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "SYSTEM READY"; color: App.Style.glassText; font.pixelSize: dp(10); font.bold: true; font.family: mainMenu.globalFont }
                    }
                }

                Text {
                    id: dashboardClock
                    text: Qt.formatTime(new Date(), "hh:mm")
                    color: App.Style.glassText
                    font.family: mainMenu.globalFont
                    font.pixelSize: dp(21)
                    font.bold: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: dp(14)

                Rectangle {
                    id: glassMediaPanel
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: dp(430)
                    radius: App.Style.glassRadius
                    color: App.Style.glassPanel
                    border.color: App.Style.glassBorder
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: mainMenu.currentArt || "./assets/missing_art.png"
                        fillMode: Image.PreserveAspectCrop
                        opacity: 0.16
                        asynchronous: true
                        layer.enabled: status === Image.Ready
                        layer.effect: MultiEffect { blurEnabled: true; blurMax: 64; blur: 0.75 }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: dp(28)
                        spacing: dp(14)

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "NOW PLAYING"; color: App.Style.glassAccent; font.pixelSize: dp(12); font.bold: true; font.family: mainMenu.globalFont }
                            Item { Layout.fillWidth: true }
                            Text { text: mainMenu.currentFile ? "LOCAL MEDIA" : "READY"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: dp(24)

                            Rectangle {
                                Layout.preferredWidth: Math.min(dp(250), parent.height * 0.58)
                                Layout.preferredHeight: Layout.preferredWidth
                                radius: dp(18)
                                color: App.Style.glassPanelSoft
                                border.color: App.Style.glassBorder
                                border.width: 1
                                clip: true
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: dp(8)
                                    source: mainMenu.currentArt || "./assets/missing_art.png"
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: dp(8)

                                Text {
                                    text: mainMenu.currentTitle || "No track playing"
                                    color: App.Style.glassText
                                    font.pixelSize: dp(27)
                                    font.bold: true
                                    font.family: mainMenu.globalFont
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: mainMenu.currentFile ? mainMenu.currentArtist : "Select a song from Media"
                                    color: App.Style.glassMutedText
                                    font.pixelSize: dp(15)
                                    font.family: mainMenu.globalFont
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: mainMenu.currentFile ? mainMenu.currentAlbum : ""
                                    color: App.Style.glassMutedText
                                    opacity: 0.8
                                    font.pixelSize: dp(12)
                                    font.family: mainMenu.globalFont
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Item { Layout.preferredHeight: dp(10) }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text { id: positionText; text: "0:00"; color: App.Style.glassMutedText; font.pixelSize: dp(11); font.family: mainMenu.globalFont }
                                    Slider {
                                        id: progressSlider
                                        Layout.fillWidth: true
                                        from: 0; to: 1; value: 0
                                        enabled: mediaManager && mediaManager.get_duration() > 0
                                        property bool userSeeking: false
                                        background: Rectangle {
                                            x: progressSlider.leftPadding
                                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                            width: progressSlider.availableWidth
                                            height: dp(5)
                                            radius: height / 2
                                            color: "#55FFFFFF"
                                            Rectangle { width: progressSlider.visualPosition * parent.width; height: parent.height; radius: height / 2; color: App.Style.glassAccent }
                                        }
                                        handle: Rectangle {
                                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                                            width: dp(12); height: width; radius: width / 2
                                            color: App.Style.glassText
                                        }
                                        onPressedChanged: {
                                            userSeeking = pressed
                                            if (!pressed && mediaManager) mediaManager.set_position(value)
                                        }
                                    }
                                    Text { id: durationText; text: "0:00"; color: App.Style.glassMutedText; font.pixelSize: dp(11); font.family: mainMenu.globalFont }
                                }

                                Row {
                                    Layout.alignment: Qt.AlignHCenter
                                    spacing: dp(16)

                                    Repeater {
                                        model: [
                                            { icon: "./assets/previous_button.svg", action: function() { if (useSpotify) spotifyManager.previous_track(); else if (mediaManager) mediaManager.previous_track() } },
                                            { icon: "./assets/play_button.svg", action: function() { if (useSpotify) spotifyManager.toggle_play(); else if (mediaManager) mediaManager.toggle_play() } },
                                            { icon: "./assets/next_button.svg", action: function() { if (useSpotify) spotifyManager.next_track(); else if (mediaManager) mediaManager.next_track() } }
                                        ]
                                        delegate: Rectangle {
                                            width: index === 1 ? dp(62) : dp(48)
                                            height: width
                                            radius: width / 2
                                            color: index === 1 ? App.Style.glassAccent : App.Style.glassPanelSoft
                                            border.color: App.Style.glassBorder
                                            border.width: 1
                                            Image { id: controlIcon; anchors.centerIn: parent; width: parent.width * 0.42; height: width; source: modelData.icon; fillMode: Image.PreserveAspectFit; visible: false }
                                            ColorOverlay { anchors.fill: controlIcon; source: controlIcon; color: index === 1 ? "#09202B" : App.Style.glassText }
                                            MouseArea { anchors.fill: parent; onClicked: modelData.action() }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    TapHandler { onTapped: mainMenu.openMedia() }
                }

                Rectangle {
                    id: glassVehiclePanel
                    Layout.preferredWidth: mainMenu.compactLayout ? parent.width * 0.42 : dp(390)
                    Layout.fillHeight: true
                    radius: App.Style.glassRadius
                    color: App.Style.glassPanel
                    border.color: App.Style.glassBorder
                    border.width: 1
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: dp(22)
                        spacing: dp(10)

                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "VEHICLE STATUS"; color: App.Style.glassAccent; font.pixelSize: dp(12); font.bold: true; font.family: mainMenu.globalFont }
                            Item { Layout.fillWidth: true }
                            Text { text: "ECU"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
                        }

                        CircularGauge {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: dp(160)
                            paramId: "SPEED"
                            showNeedle: false
                            showTicks: true
                            showCenterReadout: true
                            fillColor: App.Style.glassAccent
                            trackColor: "#45D6EEF5"
                            labelColor: App.Style.glassMutedText
                            valueColor: App.Style.glassText
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: dp(8)

                            Repeater {
                                model: ["RPM", "THROTTLE", "ENGINE_LOAD"]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: dp(72)
                                    radius: App.Style.glassSmallRadius
                                    color: App.Style.glassPanelSoft
                                    border.color: App.Style.glassDivider
                                    border.width: 1
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: dp(3)
                                        Text { text: modelData.replace("_", " "); color: App.Style.glassMutedText; font.pixelSize: dp(9); font.family: mainMenu.globalFont; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: mainMenu.obdValue(modelData).toFixed(0); color: App.Style.glassText; font.pixelSize: dp(22); font.bold: true; font.family: mainMenu.globalFont; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: dp(38)
                            radius: height / 2
                            color: "#2F9BE878"
                            Row {
                                anchors.centerIn: parent
                                spacing: dp(8)
                                Rectangle { width: dp(8); height: width; radius: width / 2; color: App.Style.glassSuccess; anchors.verticalCenter: parent.verticalCenter }
                                Text { text: "All systems normal"; color: App.Style.glassText; font.pixelSize: dp(11); font.family: mainMenu.globalFont }
                            }
                        }
                    }

                    MouseArea { anchors.fill: parent; onClicked: mainMenu.openObd() }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: dp(42)
                spacing: dp(10)

                Text { text: "coscar-OS"; color: App.Style.glassText; font.pixelSize: dp(12); font.bold: true; font.family: mainMenu.globalFont }
                Text { text: "•"; color: App.Style.glassAccent; font.pixelSize: dp(12) }
                Text { text: "Open-source vehicle experience"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
                Item { Layout.fillWidth: true }
                Text { text: "MEDIA"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
                Text { text: "OBD"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
                Text { text: "SETTINGS"; color: App.Style.glassMutedText; font.pixelSize: dp(10); font.family: mainMenu.globalFont }
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: dashboardClock.text = Qt.formatTime(new Date(), "hh:mm")
    }

    // Timer for initial delayed loading of media data
    Timer {
        id: initialLoadTimer
        interval: 0
        repeat: false
        running: false
        onTriggered: {
            updateMedia()
        }
    }

    // Function to update media information from local media manager
    function updateLocalMedia() {
        if (mediaManager) {
            var filename = mediaManager.get_current_file()
            if (filename) {
                mainMenu.currentFile = filename
                mainMenu._localTitle = mediaManager.get_display_name(filename)
                mainMenu._localArtist = mediaManager.get_band(filename)
                mainMenu._localAlbum = mediaManager.get_album(filename)
                mainMenu._localArt = mediaManager.get_album_art(filename)
            }
        }
    }

    // Function to update media information from Spotify
    function updateSpotifyMedia() {
        if (spotifyManager) {
            mainMenu.spotifyTrackName = spotifyManager.get_current_track_name() || ""
            mainMenu.spotifyArtist = spotifyManager.get_current_artist() || ""
            mainMenu.spotifyAlbum = spotifyManager.get_current_album() || ""
            mainMenu.spotifyAlbumArt = spotifyManager.get_current_album_art() || ""
        }
    }

    // Function to update media based on current source
    function updateMedia() {
        if (useSpotify) {
            updateSpotifyMedia()
        } else {
            updateLocalMedia()
        }
    }

    Component.onCompleted: {
        initialLoadTimer.start()
        if (obdManager && obdManager.refresh_values) {
            obdManager.refresh_values()
        }
    }

    // Local Media Connections (only apply when not using Spotify)
    Connections {
        target: mediaManager

        function onMetadataChanged(title, artist, album) {
            if (!useSpotify) {
                mainMenu._localTitle = title
                mainMenu._localArtist = artist
                mainMenu._localAlbum = album
                updateLocalMedia()
            }
        }

        function onPositionChanged(position) {
            if (!useSpotify && !progressSlider.userSeeking) {
                progressSlider.value = position
                positionText.text = formatTime(position)
            }
        }

        function onDurationChanged(duration) {
            if (!useSpotify) {
                progressSlider.to = duration > 0 ? duration : 1
                durationText.text = formatTime(duration)
            }
        }

        function onCurrentMediaChanged(filename) {
            if (!useSpotify && mediaManager) {
                var duration = mediaManager.get_duration()
                durationText.text = formatTime(duration)
                positionText.text = "0:00"
                updateLocalMedia()
            }
        }
    }

    // Spotify Connections
    Connections {
        target: spotifyManager

        function onCurrentTrackChanged(title, artist, album, artUrl) {
            // Always update the cached Spotify track info
            mainMenu.spotifyTrackName = title
            mainMenu.spotifyArtist = artist
            mainMenu.spotifyAlbum = album
            mainMenu.spotifyAlbumArt = artUrl

            // Only update progress UI if we're in Spotify mode
            if (useSpotify) {
                progressSlider.value = 0
                positionText.text = "0:00"
                if (spotifyManager) {
                    var duration = spotifyManager.get_duration()
                    progressSlider.to = duration > 0 ? duration : 1
                    durationText.text = formatTime(duration)
                }
            }
        }

        function onPositionChanged(position) {
            if (useSpotify && !progressSlider.userSeeking) {
                progressSlider.value = position
                positionText.text = formatTime(position)
            }
        }

        function onDurationChanged(duration) {
            if (useSpotify) {
                progressSlider.to = duration > 0 ? duration : 1
                durationText.text = formatTime(duration)
            }
        }
    }

    // Handle media source changes
    Connections {
        target: settingsManager
        function onMediaSourceChanged(source) {
            // When source changes, update media display accordingly
            updateMedia()
        }
        function onHomeOBDParametersChanged() {
            if (obdManager && obdManager.refresh_values) {
                obdManager.refresh_values()
            }
        }
    }
}
