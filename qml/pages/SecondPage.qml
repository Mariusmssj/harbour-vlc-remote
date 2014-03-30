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
import "checkConnection.js" as Connection


Dialog {
    id: page
    canAccept: (tfIP.text!==""&&tfPORT.text!==""&&tfPASS.text!=="")
    onAccepted: {
        saveSettings()
        DB.deleteTable()
        saveSettings()
        connect()
    }

    property var http: null;

    function checkConnection()
    {
        var fixedIP = tfIP.text
        while(fixedIP.indexOf(",")!== -1)
        {
            fixedIP = fixedIP.replace(",",".")
        }

        var url = "http://" + fixedIP + ":" + tfPORT.text + "/requests/status.xml"
        http = new XMLHttpRequest();
        http.open("POST", url, true);

        // Send the proper header information along with the request
        http.setRequestHeader("Authorization", "Basic " + Qt.btoa(tfUSR.text + ":" + tfPASS.text));
        http.onreadystatechange = function() { // Call a function when the state changes.
            timerHTTP.stop();
            if (http.readyState === 4) {
                if (http.status === 200) {
                    recCon.color = "green"
                    stat.text = "VLC is Conneced"
                    recCon.opacity = 0.5
                    closeTimer.start()
                }
                else if(http.status === 401)
                {
                    recCon.color = "orange"
                    stat.text = "Wrong Username or Password"
                    recCon.opacity = 0.5
                    closeTimer.start()
                }
                else
                {
                    recCon.color = "red"
                    stat.text = "Could not connect to VLC"
                    recCon.opacity = 0.5
                    closeTimer.start()
                }
            }
        }
        http.send();
        timerHTTP.start();
    }

    function httpConnectionCheck()
    {
        if (http.readyState !== 4)
        {
            recCon.color = "red"
            stat.text = "Could not connect to VLC!"
            recCon.opacity = 0.5
            closeTimer.start()
        }
    }

    function connect()
    {
        var fixedIP = tfIP.text
        while(fixedIP.indexOf(",")!== -1)
        {
            fixedIP = fixedIP.replace(",",".")
        }

        if(tfIP.text!==""&&tfPORT.text!==""&&tfPASS.text!=="")
        {
            pageStack.previousPage().updateSettings()
        }
        passSettings(fixedIP, tfPORT.text, tfUSR.text, tfPASS.text)
    }

    function updateSettings()
    {
        var db = DB.getSettings();

        db.transaction(function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM Settings1');
            var dbItem = rs.rows.item(0);
            tfIP.text    = dbItem.IP
            tfPORT.text  = dbItem.Port
            tfUSR.text   = dbItem.Username
            tfPASS.text  = dbItem.Password
            cmbSync.currentIndex = dbItem.Sync
            passSettings(dbItem.IP, dbItem.Port, dbItem.Username, dbItem.Password)
        });

    }

    function saveSettings()
    {
        var fixedIP = tfIP.text
        while(fixedIP.indexOf(",")!== -1)
        {
            fixedIP = fixedIP.replace(",",".")
        }

        var db = DB.getSettings();

        db.transaction(function(tx)
        {
            var rs = tx.executeSql("INSERT OR REPLACE INTO Settings1 VALUES (?,?,?,?,?)", [fixedIP, tfPORT.text, tfUSR.text, tfPASS.text, cmbSync.currentIndex]);
        });
    }

    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {

            MenuItem {
                text: "Load Previous Settings"
                onClicked: updateSettings()

            }
            MenuItem {
                text: "Check Connection"
                onClicked: checkConnection()

            }
        }
        // Tell SilicaFlickable the height of its content.
        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            Component.onCompleted: updateSettings()
            DialogHeader{
                title: "Connect & Save"
            }

            Rectangle{
                id: recCon
                anchors.horizontalCenter: parent.horizontalCenter
                width: 400
                height: 45
                opacity: 0.0

                Label{
                    id: stat
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            ComboBox{
                id: cmbSync
                width: page.width
                label: "Sync UI with VLC every: "
                menu: ContextMenu{
                    MenuItem { text: "never" }
                    MenuItem { text: "1 second" }
                    MenuItem { text: "2 seconds"}
                    MenuItem { text: "5 seconds"}
                    MenuItem { text: "10 seconds"}
                }
            }

            TextField {
                id: tfIP
                width: page.width
                //text: dbItem.IP
                label: "Enter your Ip address: , will auto change to ."
                placeholderText: "Enter your IP address"
                validator: RegExpValidator { regExp: /^[0-9]{1,3}[\.|,][0-9]{1,3}[\.|,][0-9]{1,3}[\.|,][0-9]{1,3}$/}
                color: errorHighlight? "red" : Theme.primaryColor
                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tfPORT.focus = true
            }

            TextField {
                id: tfPORT
                width: page.width
                //text: dbItem.Port
                label: "Enter your port number"
                placeholderText: "Enter your port number default: 8080"
                validator: RegExpValidator { regExp: /^[0-9]{4,4}$/ }
                color: errorHighlight? "red" : Theme.primaryColor
                inputMethodHints: Qt.ImhDigitsOnly
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tfUSR.focus = true
            }

            TextField {
                id: tfUSR
                width: page.width
                //text: dbItem.Username
                label: "Enter your VLC username"
                placeholderText: "Enter your VLC username"
                color: errorHighlight? "red" : Theme.primaryColor
                inputMethodHints: Qt.ImhNoPredictiveText
                EnterKey.enabled: text.length >= 0
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: tfPASS.focus = true
            }

            TextField {
                id: tfPASS
                width: page.width
                //text: dbItem.Password
                label: "Enter your VLC password"
                placeholderText: "Enter your VLC password"
                color: errorHighlight? "red" : Theme.primaryColor
                inputMethodHints: Qt.ImhNoPredictiveText
                echoMode: TextInput.Password
                EnterKey.enabled: text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: {
                    if(tfIP.text!==""&&tfPORT.text!==""&&tfPASS.text!=="")
                        tfPASS.focus = false
                        page.accept()
                }
            }

            Timer {
                id: closeTimer;       
                interval: 2500; running: false; repeat: false;
                onTriggered: recCon.opacity = 0.0;
            }

            Timer {
                id: timerHTTP;
                interval: 500; running: false; repeat: false;
                onTriggered: httpConnectionCheck();
            }
        }
    }
}





