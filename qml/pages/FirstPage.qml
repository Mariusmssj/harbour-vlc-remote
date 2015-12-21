/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "db.js" as DB
import QtQuick.XmlListModel 2.0
import org.nemomobile.mpris 1.0

Page {
    id: page

    onStatusChanged: {
        if (status === PageStatus.Active) {
            pageStack.pushAttached("VlcFileBrowser.qml", {});
        }
    }

    function scaleVolumeToPercent(value) {
        return (0 + (value-0)*(200-0)/(512-0));
    }

    function setVolume(volume) {
        sendCommand("volume&val=" + volume)
    }

    function pause() {
        sendCommand("pl_pause")
        iconButtons.playing = false
    }

    function play() {
        sendCommand("pl_play")
        iconButtons.playing = true
    }

    function next() {
        sendCommand("pl_next")
    }

    function prev() {
        sendCommand("pl_previous")
    }

    function stop() {
        sendCommand("pl_stop")
    }

    function seekRelative(amount) {
        if (amount > 0) {
            sendCommand("seek&val=%2B" + amount)
        } else {
            // amount already has the - sign
            sendCommand("seek&val=" + amount)
        }
    }

    function seekAbsolute(at) {
        sendCommand("seek&val=" + amount)
    }

    property string ip : ""
    property string port : ""
    property string username : ""
    property string password : ""
    property string command: ""
    property string aspectRatio: "default"
    property string seekTotal: "0:00:00"

    property int time: 0
    property int seekH : 0
    property int seekM : 0
    property int seekS : 0
    property int time2: 0
    property int seekH2 : 0
    property int seekM2 : 0
    property int seekS2 : 0

    property int audioIndex: 1
    property int subtitleIndex: 0

    property int syncTime : 1000
    property real delayAudio: 0.0
    property real delaySubtl: 0.0
    property double playbackRate: 0.0

    property var audioTracks : []
    property var subtitleTracks : []

    XmlListModel{
        id: xmlModel
        query: "/root"
        XmlRole{ name: "fullscreen"; query: "fullscreen/string()"}
        XmlRole{ name: "aspectratio"; query: "aspectratio/string()"}
        XmlRole{ name: "audiodelay"; query: "audiodelay/string()"}
        XmlRole{ name: "currentplid"; query: "currentplid/string()"}
        XmlRole{ name: "time"; query: "time/string()"}
        XmlRole{ name: "volume"; query: "volume/string()"}
        XmlRole{ name: "length"; query: "length/string()"}
        XmlRole{ name: "random"; query: "random/string()"}
        XmlRole{ name: "rate"; query: "rate/string()"}
        XmlRole{ name: "state"; query: "state/string()"}
        XmlRole{ name: "loop"; query: "loop/string()"}
        XmlRole{ name: "repeat"; query: "repeat/string()"}
        XmlRole{ name: "subtitledelay"; query: "subtitledelay/string()"}
        XmlRole{ name: "artist"; query: "information/category/info[@name='artist']/string()"}
        XmlRole{ name: "album"; query: "information/category/info[@name='album']/string()"}
        XmlRole{ name: "filename"; query: "information/category/info[@name='filename']/string()"}
    }

    XmlListModel{
        id: xmlModel2
        query: "/root/information/category"

        XmlRole{ name: "category"; query: "@name/string()"}
        XmlRole{ name: "type"; query: "info[@name='Type']/string()"}
    }

    function sendCommand(command)
    {
        var isRunning = upTimer.running;
        upTimer.stop();
        xmlWaitTimer.stop();
        xmlModel.xml = "";
        passCommands(command);
        if (command === "pl_stop")
        {
            sliderSeek.enabled = false;
            sliderSeek.valueText = " ";
            sliderSeek.value = 0;
            iconButtons.playing = false;
        }
        if (isRunning)
            upTimer.start();
    }

    function updateXML()
    {
        var tempAudioTracks = []
        var tempSubtitleTracks = []

        if (xmlModel2.status === XmlListModel.Ready)
        {
            for(var i = 1; i < xmlModel2.count; i++)
            {
                if(xmlModel2.get(i).type === "Audio")
                {
                    tempAudioTracks.push(xmlModel2.get(i).category.slice(-1))
                }
                else if(xmlModel2.get(i).type === "Subtitle")
                {
                    tempSubtitleTracks.push(xmlModel2.get(i).category.slice(-1))
                }
            }
        }

        audioTracks = tempAudioTracks.sort();
        subtitleTracks = tempSubtitleTracks.sort();
        subtitleTracks.push(-1)

        if (xmlModel.status === XmlListModel.Ready)
        {
            var index =  0;
            if (xmlModel.count > 0)
                index = xmlModel.count - 1;

            var element = xmlModel.get(index);

            if(element.fullscreen === "true")
                tsFull.checked  = true;
            else
                tsFull.checked  = false;

            if(element.random === "true")
                tsRand.checked = true;
            else
                tsRand.checked = false;

            if(element.loop === "true")
                tsLoop.checked = true;
            else
                tsLoop.checked = false;

            if(element.repeat === "true")
                tsRepeat.checked = true;
            else
                tsRepeat.checked = false;

            if(element.state === "paused")
                iconButtons.playing = false;
            else if(element.state === "stopped")
                iconButtons.playing = false;
            else
                iconButtons.playing = true;

            labelFileName.text = element.filename
            setTitle(element.filename)
            labelAlbum.text = element.album
            labelArtist.text = element.artist
            setArtist(element.artist)

            delayAudio = element.audiodelay
            delaySubtl = element.subtitledelay
            playbackRate = element.rate

            checkAspect(element.aspectratio)

            slVol.value = element.volume;
            seekTotal = getTotalSeek(element.length)

            if(element.currentplid !== -1)
            {
                art.source = "http://" + username + ":" + password + "@" + ip + ":" + port + "/art?item=" + element.currentplid;
                art.opacity = 0.85
            }

            xmlWaitTimer.stop();

            upTimer.start();
            if (element.state !== "stopped")
            {
                sliderSeek.enabled = true;
                sliderSeek.maximumValue = element.length;
                updateSeek(element.time);
            }
            else
            {
                sliderSeek.enabled = false;
                sliderSeek.valueText = " ";
                sliderSeek.value = 0;
            }
        }
    }

    function checkPlaybackRate(rate)
    {
        if(playbackRate > 0.2 && playbackRate < 5.0)
        {
            playbackRate = playbackRate + rate
            sendCommand("rate&val=" + playbackRate)
        }
    }

    function checkAudioDelay(delay)
    {
        delayAudio = delayAudio + delay
        sendCommand("audiodelay&val=" + delayAudio)
    }

    function checkSubtitleDelay(delay)
    {
        delaySubtl = delaySubtl + delay
        sendCommand("subdelay&val=" + delaySubtl)
    }

    function checkAspect(ratio)
    {
        switch(ratio)
        {
        case "default":
            cmbAspect.currentIndex = 0
            break
        case "1:1":
            cmbAspect.currentIndex = 1
            break
        case "4:3":
            cmbAspect.currentIndex = 2
            break
        case "5:4":
            cmbAspect.currentIndex = 3
            break
        case "16:9":
            cmbAspect.currentIndex = 4
            break
        case "16:10":
            cmbAspect.currentIndex = 5
            break
        }
    }

    function getTotalSeek(seconds)
    {
        time2 = seconds;
        seekH2 = (time2 / 3600) % 24;
        seekM2 = (time2 / 60) % 60;
        seekS2 = time2 % 60;
        var stringTime = seekH2 + ":" + ("0" + seekM2).slice(-2) + ":" + ("0" + seekS2).slice(-2);
        return(stringTime);
    }

    function updateSeek(seconds)
    {
        time = seconds;
        seekH = (time / 3600) % 24;
        seekM = (time / 60) % 60;
        seekS = time % 60;
        sliderSeek.value = seconds;
        var stringTime = seekH + ":" + ("0" + seekM).slice(-2) + ":" + ("0" + seekS).slice(-2) + " / " + seekTotal;
        sliderSeek.valueText = stringTime;
        setSeek(stringTime);
    }

    function getVLCstatus()
    {
        var httpReq = new XMLHttpRequest()
        var url = "http://" + ip + ":" + port + "/requests/status.xml";

        httpReq.open("GET", url, true);

        // Send the proper header information along with the request
        httpReq.setRequestHeader("Authorization", "Basic " + Qt.btoa(username + ":" + password));
        httpReq.setRequestHeader('Content-Type',  'text/xml');

        httpReq.onreadystatechange = function()
        {
            if(httpReq.readyState === 4 && httpReq.status == 200)
            {
                xmlModel2.xml = httpReq.responseText;
                xmlModel.xml = httpReq.responseText;
                xmlWaitTimer.start();
            }
        }
        httpReq.send(null);
    }

    function setSyncTime(option)
    {
        switch(option)
        {
        case "0":
            syncTime = 0
            break
        case "1":
            syncTime = 1000
            break
        case "2":
            syncTime = 2000
            break
        case "3":
            syncTime = 5000
            break
        case "4":
            syncTime = 10000
            break
        }
        setSync(syncTime)
    }

    function updateSettings()
    {
        var db = DB.getSettings();

        db.transaction(function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM Settings1');
            var dbItem = rs.rows.item(0);
            ip         = dbItem.IP;
            port       = dbItem.Port;
            username   = dbItem.Username;
            password   = dbItem.Password;
            setSyncTime(dbItem.Sync)
        });
        passSettings(ip, port, username, password);
    }


    // To enable PullDownMenu, place our content in a SilicaFlickable
    VisualItemModel {
        id: model
        Rectangle {
            id: rect1
            width: page.width
            height: page.height
            color: "transparent"

            GlassItem {
                anchors.bottom: rect1.bottom
                anchors.bottomMargin: -11
                id: effect
                objectName: "menuitem"
                height: Theme.paddingLarge
                width: page.width
                falloffRadius: Math.exp(Math.log(0.15))
                radius: Math.exp(Math.log(0.15))
                color: Theme.highlightColor
                cache: false
            }

            GlassItem {
                anchors.verticalCenter: rect1.verticalCenter
                anchors.horizontalCenter: rect1.horizontalCenter
                anchors.horizontalCenterOffset: rect1.width/2
                transform: Rotation { origin.x: page.width/2; origin.y: Theme.paddingLarge/2; axis { x: 0; y: 0; z: 1 } angle: 90 }
                id: effect2
                objectName: "menuitem"
                height: Theme.paddingLarge
                width: page.width
                falloffRadius: Math.exp(Math.log(0.15))
                radius: Math.exp(Math.log(0.15))
                color: Theme.highlightColor
                cache: false
            }
            Item {
                width: rect1.width
                height: 270
                Rectangle{
                    id: artP
                    radius: 10
                    color: Theme.secondaryHighlightColor
                    width: parent.width
                    height: parent.height

                    Image{
                        id: art
                        fillMode: Image.Tile
                        smooth: true
                        width: parent.width
                        height: parent.height
                        opacity: 0.0
                    }
                }
                OpacityRampEffect {
                    id: oPeffect
                    slope: 3.5
                    offset: 0.5
                    direction: OpacityRamp.TopToBottom
                    sourceItem: artP
                }
            }

            // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
            PullDownMenu {
                z: 1000
                MenuItem{
                    text: "About"
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
                MenuItem{
                    text: "VLC Setup Help"
                    onClicked: pageStack.push(Qt.resolvedUrl("VlcHelp.qml"))
                }
                MenuItem {
                    text: "Connection Settings"
                    onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
                }
                MenuItem {
                    text: "Playlist"
                    onClicked: pageStack.push(Qt.resolvedUrl("VlcPlaylist.qml"))
                }
            }

            // Tell SilicaFlickable the height of its content.
            //contentHeight: column.height + Theme.paddingLarge

            // Place our content in a Column.  The PageHeader is always placed at the top
            // of the page, followed by our content.
            Column {
                id: column
                width: page.width
                spacing: Theme.paddingMedium
                Component.onCompleted: {

                    updateSettings()
                    getVLCstatus()
                }

                Timer {
                    id: upTimer
                    interval: syncTime; running: true; repeat: true
                    onTriggered: getVLCstatus()
                }

                Timer {
                    id: xmlWaitTimer
                    interval: 50; running: false; repeat: true
                    onTriggered: updateXML()
                }

                PageHeader {
                    id: header
                    title: "VLC Remote"
                }

                Label {
                    id: showL
                    text: " "
                    font.pixelSize: Theme.fontSizeExtraLarge
                }
                Rectangle{
                    width: parent.width
                    height: 2
                    color: "transparent"
                }
                Column{
                    width: page.width
                    height: page.height / 7
                    spacing: Theme.paddingSmall - 30
                    Row{

                        Image{
                            source: "image://theme/icon-m-document"
                            scale: 0.55
                            opacity: 0.8
                            y: -11.0
                        }

                        Label{
                            id: labelFileName
                            font.pixelSize: Theme.fontSizeMedium
                            width: page.width - 2*Theme.paddingLarge
                            x: Theme.paddingLarge
                            horizontalAlignment: Text.AlignLeft
                            truncationMode: TruncationMode.Elide
                            color: Theme.secondaryHighlightColor
                            wrapMode: Text.WordWrap
                        }
                    }
                    Row{
                        Image{
                            source: "image://theme/icon-m-music"
                            scale: 0.55
                            opacity: 0.8
                            y: -11.0
                        }
                        Label{
                            id: labelArtist
                            font.pixelSize: Theme.fontSizeMedium
                            width: page.width - 2*Theme.paddingLarge
                            x: Theme.paddingLarge
                            horizontalAlignment: Text.AlignLeft
                            truncationMode: TruncationMode.Elide
                            color: Theme.secondaryHighlightColor
                        }
                    }
                    Row{
                        Image{
                            source: "image://theme/icon-m-sounds"
                            scale: 0.55
                            opacity: 0.8
                            y: -11.0
                        }
                        Label{
                            id: labelAlbum
                            font.pixelSize: Theme.fontSizeMedium
                            width: page.width - 2*Theme.paddingLarge
                            x: Theme.paddingLarge
                            horizontalAlignment: Text.AlignLeft
                            truncationMode: TruncationMode.Elide
                            color: Theme.secondaryHighlightColor
                        }
                    }
                }
                Column{
                    width: page.width
                    spacing: Theme.paddingMedium
                    Row {
                        Slider {
                            id: slVol
                            width: page.width
                            minimumValue: 0
                            maximumValue: 512
                            value: 100
                            valueText: "Volume: " + scaleVolumeToPercent(value).toFixed(0)
                            onValueChanged: page.setVolume(value.toFixed(0))
                        }
                    }
                    Row{
                        anchors.horizontalCenter: parent.horizontalCenter

                        Column{
                            spacing: Theme.paddingMedium
                            Row {
                                id: iconButtons
                                spacing: Theme.paddingLarge +10.0
                                anchors.horizontalCenter: parent.horizontalCenter
                                property bool playing

                                IconButton{
                                    id: btnPrev
                                    icon.source: "image://theme/icon-m-previous"
                                    onClicked: page.prev()
                                }

                                IconButton {
                                    id: pause
                                    icon.source: "image://theme/icon-l-pause"
                                    onClicked: page.pause()
                                    enabled: iconButtons.playing
                                }

                                IconButton {
                                    id: play
                                    icon.source: "image://theme/icon-l-play"
                                    onClicked: page.play()
                                    enabled: !iconButtons.playing
                                }
                                IconButton{
                                    id: btnNext
                                    icon.source: "image://theme/icon-m-next"
                                    onClicked: page.next()
                                }
                            }

                            Row {
                                spacing: Theme.paddingLarge +10.0
                                anchors.horizontalCenter: parent.horizontalCenter

                                IconButton{
                                    id: btnRwn
                                    icon.source: "icon-m-previous-song.png"
                                    onClicked: page.seekRelative(-30)
                                }

                                IconButton{
                                    id: btnStop
                                    icon.source: "icon-camera-stop.png"
                                    //onClicked: getVLCArt()
                                    onClicked: page.sendCommand("pl_stop")
                                }

                                IconButton{
                                    id: btnFrw
                                    icon.source: "icon-m-next-song.png"
                                    onClicked: page.seekRelative(30)
                                }
                            }
                        }
                    }
                    Row {
                        id: rowInfo
                        spacing: Theme.paddingLarge
                        anchors.horizontalCenter: parent.horizontalCenter

                        Switch {
                            id: tsRand
                            icon.source: "image://theme/icon-l-shuffle"
                            onClicked: sendCommand("pl_random")
                        }

                        Switch {
                            id: tsLoop
                            icon.source: "image://theme/icon-m-backup"
                            onClicked: sendCommand("pl_loop")
                        }

                        Switch {
                            id: tsRepeat
                            icon.source: "image://theme/icon-l-repeat"
                            onClicked: sendCommand("pl_repeat")
                        }

                        Switch {
                            id: tsFull
                            icon.source: "icon-l-fullscreen.png"
                            onClicked: sendCommand("fullscreen")
                        }
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    Slider {
                        id: sliderSeek
                        width: page.width
                        minimumValue: 0
                        maximumValue: 1
                        onClicked: {
                            seekAbsolute(value.toFixed(0))
                            updateSeek(value.toFixed(0))
                        }
                        onMouseXChanged:  {
                            seekAbsolute(value.toFixed(0))
                            updateSeek(value.toFixed(0))
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rect2
            width: view.width
            height: view.height
            color: "transparent"

            GlassItem {
                anchors.verticalCenter: rect2.verticalCenter
                anchors.horizontalCenter: rect2.horizontalCenter
                anchors.horizontalCenterOffset: rect2.width/2
                transform: Rotation { origin.x: page.width/2; origin.y: Theme.paddingLarge/2; axis { x: 0; y: 0; z: 1 } angle: 90 }
                id: effect3
                objectName: "menuitem"
                height: Theme.paddingLarge
                width: page.width
                falloffRadius: Math.exp(Math.log(0.15))
                radius: Math.exp(Math.log(0.15))
                color: Theme.highlightColor
                cache: false
            }

            Column {
                id: column2
                width: page.width
                spacing: Theme.paddingMedium
                PageHeader {
                    id: header2
                    title: " "
                }
                Label {
                    id: lblAditional
                    text: "Additional Controls"
                    x: 10
                    color: Theme.secondaryHighlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }

                SectionHeader { text: "Video & Playlist" }
                Row{
                    ComboBox {
                        id: cmbAspect
                        width: page.width / 2 +50
                        label: "Aspect Ratio:"

                        menu: ContextMenu {
                            MenuItem { text: "default" }
                            MenuItem { text: "1:1" }
                            MenuItem { text: "4:3" }
                            MenuItem { text: "5:4" }
                            MenuItem { text: "16:9" }
                            MenuItem { text: "16:10" }
                        }
                        onCurrentIndexChanged: passCommands("aspectratio&val=" + value)
                    }

                    Button{
                        id: btnClearPl
                        width: page.width / 2 -60
                        text: "Clear Playlist"
                        onClicked: passCommands("pl_empty")
                    }
                }

                SectionHeader { text: "Playback" }
                Row{
                    Column
                    {
                        width: rect2.width/2
                        Label{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Playback Speed"
                        }
                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            IconButton{
                                icon.source: "image://theme/icon-m-remove"
                                onClicked: (playbackRate > 0.4) ? checkPlaybackRate(-0.10000000) : checkPlaybackRate(0.0)
                            }

                            Label{
                                y: 19
                                text: playbackRate.toFixed(3)
                            }

                            IconButton{
                                icon.source: "image://theme/icon-m-add"
                                onClicked: (playbackRate < 4.8) ? checkPlaybackRate(0.10000000) : checkPlaybackRate(0.0)
                            }
                        }
                    }
                    Column
                    {
                        width: rect2.width/2

                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Button{
                                text: "Normal speed"
                                onClicked: {sendCommand("rate&val=1.0"); playbackRate = 1.0}
                            }
                        }
                    }
                }

                SectionHeader { text: "Synchronization" }
                Row{

                    Column
                    {
                        width: rect2.width/2
                        Label{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Audio delay"
                        }
                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            IconButton{
                                icon.source: "image://theme/icon-m-remove"
                                onClicked: checkAudioDelay(-0.1)
                            }

                            Label{
                                y: 19
                                text: delayAudio.toFixed(3)
                            }

                            IconButton{
                                icon.source: "image://theme/icon-m-add"
                                onClicked: checkAudioDelay(0.1)
                            }
                        }
                    }
                    Column
                    {
                        width: rect2.width/2
                        Label{
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Subtitle delay"
                        }
                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            IconButton{
                                icon.source: "image://theme/icon-m-remove"
                                onClicked: checkSubtitleDelay(-0.1)
                            }
                            Label{
                                y: 19
                                text: delaySubtl.toFixed(3)
                            }

                            IconButton{
                                icon.source: "image://theme/icon-m-add"
                                onClicked: checkSubtitleDelay(0.1)
                            }
                        }
                    }
                }
                SectionHeader { text: "Audio & Subtitle tracks" }
                Row{
                    Column
                    {
                        width: rect2.width/2

                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Button{
                                text: "Change audio"
                                onClicked: {
                                    if(audioIndex < audioTracks.length)
                                    {
                                        passCommands("audio_track&val=" + audioTracks[audioIndex++])
                                        if(audioIndex >= audioTracks.length)
                                            audioIndex = 0
                                    }
                                }
                            }
                        }
                    }
                    Column
                    {
                        width: rect2.width/2

                        Row
                        {
                            anchors.horizontalCenter: parent.horizontalCenter
                            Button{
                                text: "Change subtitle"
                                onClicked: {
                                    if(subtitleIndex < subtitleTracks.length)
                                    {
                                        passCommands("subtitle_track&val=" + subtitleTracks[subtitleIndex++])
                                        if(subtitleIndex >= subtitleTracks.length)
                                            subtitleIndex = 0
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    SilicaListView {
        id: view
        anchors.fill: parent
        model: model
        snapMode: ListView.SnapOneItem

    }

    MprisPlayer {
        id: mprisPlayer

        serviceName: "qtmpris"

        // Mpris2 Root Interface
        identity: "VLC Remote"
        supportedUriSchemes: []
        supportedMimeTypes: []

        // Mpris2 Player Interface
        canControl: true

        canGoNext: true
        canGoPrevious: true
        canPause: iconButtons.playing
        canPlay: !iconButtons.playing
        canSeek: true
        hasTrackList: false

        playbackStatus: iconButtons.playing ? Mpris.Playing : Mpris.Stopped
        loopStatus: Mpris.None
        shuffle: false
        volume: slVol.value / 512.0 * 10

        onVolumeRequested: {
            console.log("Set volume", volume, "requested");
            volume /= 10.0;
            page.setVolume((volume * 512.0).toFixed(0));
            slVol.value = volume * 512.0;
        }

        onPauseRequested: {
            page.pause();
        }

        onPlayRequested: {
            console.log("Play requested")
            page.play();
        }
        onPlayPauseRequested: {
            console.log("Play pause requested")
            if (iconButtons.playing) {
                page.pause();
            } else {
                page.play();
            }
        }
        onStopRequested: {
            page.stop();
        }
        onNextRequested: {
            page.next();
        }
        onPreviousRequested: {
            page.prev();
        }
        onSeekRequested: {
            page.seekRelative(offset / 1000000.0)
            emitSeeked()
        }
        onSetPositionRequested: {
            page.seekAbsolute(offset / 1000000.0)
            emitSeeked()
        }
        onOpenUriRequested: lastMessage = "Requested to open uri \"" + url + "\""

        onLoopStatusRequested: {
            if (loopStatus == Mpris.None) {
                repeatSwitch.checked = false
            } else if (loopStatus == Mpris.Playlist) {
                repeatSwitch.checked = true
            }
        }
        onShuffleRequested: shuffleSwitch.checked = shuffle

    }
}



