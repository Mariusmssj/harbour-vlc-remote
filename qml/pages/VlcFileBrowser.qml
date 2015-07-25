import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import "fileCheck.js" as VLC
import "db2.js" as DB

Page {
    id: page

    property string parentPath : "file:///"

    XmlListModel{
        id: xmlModel
        query: "/root/element"

        XmlRole{ name: "type"; query: "@type/string()"}
        XmlRole{ name: "path"; query: "@path/string()"}
        XmlRole{ name: "name"; query: "@name/string()"}
        XmlRole{ name: "mode"; query: "@mode/string()"}
        XmlRole{ name: "uri"; query: "@uri/string()"}
    }

    function getVLCMedia(uri)
    {
        var httpReq = new XMLHttpRequest()
        var url = "http://" + ip + ":" + port + "/requests/browse.xml?uri=" + uri

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
        }
    }

    function updateSettings()
    {
        var db = DB.getSettings();

        db.transaction(function(tx)
        {
            var rs = tx.executeSql('SELECT * FROM Settings2');
            var dbItem = rs.rows.item(0);
            if(typeof dbItem === "undefined")
                parentPath = "file:///"
            else
                parentPath = dbItem.HomePath;

            getVLCMedia(parentPath);
        });
    }

    function saveSettings(path)
    {
        var db = DB.getSettings();

        db.transaction(function(tx)
        {       //insert into settings1(comlumename), values foo
            var rs = tx.executeSql("INSERT OR REPLACE INTO Settings2 VALUES (?)", [path]);
        });
    }

    Timer {
        id: xmlWaitTimer
        interval: 50; running: false; repeat: true
        onTriggered: updateXML()
    }

    SilicaListView {
        id: listView
        model: xmlModel
        anchors.fill: parent
        header: PageHeader{

            title: "Media Browser"
            height: 155

            Rectangle{
                height: 40
                width: parent.width
                color: "transparent"
                y: 100
                Row{
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button{
                        text: "Parent"
                        y: -15
                        width: parent.width / 3
                        onClicked: {
                            if(parentPath.indexOf("%2F")!==-1)
                                parentPath = parentPath.substring(0,parentPath.lastIndexOf("%2F"))
                            else
                                parentPath = "file:///"
                            getVLCMedia(parentPath);
                        }
                    }
                    Button{
                        text: "Home"
                        y: -15
                        width: parent.width / 3
                        onClicked: {
                            //passCommands("addsubtitle&val=file:\\\E:\\Downloads\Movies\300.str")
                            updateSettings()
                        }

                    }
                    Button{
                        text: "Set as Home"
                        y: -15
                        width: parent.width / 3
                        onClicked: {
                            saveSettings(parentPath)
                            DB.deleteTable()
                            saveSettings(parentPath)
                        }
                    }
                }
            }
        }

        Component.onCompleted: updateSettings()

        PullDownMenu {

            MenuItem {
                text: "Jump to the end"
                onClicked: listView.scrollToBottom()
            }

            MenuItem {
                text: "Root directory"
                onClicked: {
                    parentPath = "file:///"
                    getVLCMedia("file:///")
                }
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

            Image{
                id: listIcon
                anchors.left: parent.left
                anchors.margins: Theme.paddingLarge
                anchors.verticalCenter: parent.verticalCenter
                opacity: (xmlModel.get(index).type === "dir") ? 0.8 : (VLC.checkFile(index)||VLC.checkFileSubs(index)) ? 0.8 : 0.2
                source: "icons/icon-s-" + xmlModel.get(index).type + ".png"
            }

            Label {
                text: name
                truncationMode: TruncationMode.Fade
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor

                anchors.left: listIcon.right
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: Theme.paddingMedium
            }

            onClicked: {
                if (xmlModel.get(index).type === "dir")
                {
                    getVLCMedia(xmlModel.get(index).uri);
                    parentPath = xmlModel.get(index).uri;
                }
                else if(VLC.checkFile(index) === true)
                    passCommands("in_play&input=" + xmlModel.get(index).uri )
            }

            Component {
                id: contextMenu
                ContextMenu {

                    MenuItem {
                        text: "Add to Playlist"
                        onClicked:{
                            passCommands("in_enqueue&input=" + xmlModel.get(index).uri )
                        }
                    }
                    MenuItem {
                        text: "Add as subtile"
                        onClicked:{
                            if(VLC.checkFileSubs(index) === true)
                                passCommands("addsubtitle&val=" + xmlModel.get(index).uri )
                        }
                    }
                }
            }
        }
        VerticalScrollDecorator {}
    }
}


