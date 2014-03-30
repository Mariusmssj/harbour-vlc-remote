import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0

Page {
    id: page

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
            var index =  0;
            if (xmlModel.count > 0)
                index = xmlModel.count - 1;
            for (var i = 0; i < xmlModel.count; i++)
            {
                var element = xmlModel.get(i);
                list_model.append({name: element.name})

                //console.log(element.type);
                //console.log(element.path);
                //console.log(element.name);
                //console.log(element.mode);
                //console.log(element.uri);

            }
            xmlWaitTimer.stop();
        }
    }



    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium
            Component.onCompleted: getVLCMedia("file://~")
            PageHeader {
                title: "Media Browser"
            }

            Timer {
                id: xmlWaitTimer
                interval: 50; running: false; repeat: true
                onTriggered: updateXML()
            }


            Button{
                text: "GetPath"
                onClicked: getVLCMedia("file://~")
            }

            ListModel {
                id: list_model
            }

            Label{
                text: list_model.get(0).name
            }

        }
    }
}

