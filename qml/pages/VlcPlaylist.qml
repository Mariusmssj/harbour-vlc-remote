import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: page

    XmlListModel{
        id: xmlModel
        query: "/node/node/leaf"

        XmlRole{ name: "name"; query: "@name/string()"}
        XmlRole{ name: "id"; query: "@id/string()"}
        //XmlRole{ name: "duration"; query: "@duration/string()"}
        //XmlRole{ name: "uri"; query: "@uri/string()"}
        XmlRole{ name: "current"; query: "@current/string()"}
    }

    function getVLCMedia()
    {
        var httpReq = new XMLHttpRequest()
        var url = "http://" + ip + ":" + port + "/requests/playlist.xml"

        httpReq.open("GET", url, true);

        // Send the proper header information along with the request
        httpReq.setRequestHeader("Authorization", "Basic " + Qt.btoa(username + ":" + password));
        httpReq.setRequestHeader('Content-Type',  'text/xml');

        httpReq.onreadystatechange = function()
        {
            if(httpReq.readyState === 4 && httpReq.status == 200)
            {
                xmlModel.xml = httpReq.responseText;
                xmlWaitTimer.start();
            }
        }
        httpReq.send(null);
    }

    function updateXML()
    {
        if (xmlModel.status === XmlListModel.Ready)
        {
            xmlWaitTimer.stop();
            xmlRefresh.start()
        }
    }

    Timer {
        id: xmlWaitTimer
        interval: 50; running: false; repeat: true
        onTriggered: updateXML()
    }
    Timer {
        id: xmlRefresh
        interval: 50; running: false; repeat: false
        onTriggered: getVLCMedia()
    }

    SilicaListView {
        id: listView
        model: xmlModel
        anchors.fill: parent
        header: PageHeader {
            title: "Playlist"
        }

        Component.onCompleted: getVLCMedia()

        PullDownMenu {

            MenuItem{
                text: "Empty Playlist"
                onClicked: passCommands("pl_empty")
            }
            MenuItem {
                text: "Jump to the end"
                onClicked: listView.scrollToBottom()
            }
        }

        PushUpMenu {
            id: pushUpMenu
            spacing: Theme.paddingLarge
            MenuItem {
                text: "Return to Top"
                onClicked: listView.scrollToTop()
            }
        }

        delegate: ListItem {
            id: delegate
            menu: contextMenu
            function remove() {
                remorseAction("Deleting", function() {
                    passCommands("pl_delete&id=" + xmlModel.get(index).id )
                    getVLCMedia() })
            }

            Image{
                id: listIcon
                anchors.left: parent.left
                anchors.margins: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                opacity: 0.8
                source: xmlModel.get(index).current === "current" ? "icons/icon-cover-play.png" : "image://theme/icon-m-sound"
            }

            Label {
                text: name
                truncationMode: TruncationMode.Fade
                color: delegate.highlighted || xmlModel.get(index).current === "current" ? Theme.highlightColor : Theme.primaryColor
                anchors.left: listIcon.right
                anchors.right: parent.right
                anchors.margins: Theme.paddingMedium
                anchors.verticalCenter: parent.verticalCenter
            }

            onClicked: {
                passCommands("pl_play&id=" + xmlModel.get(index).id )
                xmlModel.get(index).current = "current"
                getVLCMedia()
            }

            Component {
                id: contextMenu
                ContextMenu {

                    MenuItem {
                        text: "Remove from Playlist"
                        onClicked: remove()
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}


