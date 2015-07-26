import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        Column {
            id: column

            anchors{
                left: parent.left
                right: parent.right
                margins: Theme.paddingLarge
            }

            spacing: Theme.paddingLarge
            PageHeader {
                title: "About"
            }
            Label {
                x: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                text: "VLC Remote"
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
            }
            Text {
                width: parent.width
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: "VLC Remote lets you sit back enjoy your movies and music while you control everything with your Sailfish device from your sofa or anywhere in the house"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: "<a href='#'> VLC player (Web-site)</a>";
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("https://www.videolan.org/vlc/download-windows.en_GB.html")
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: "<a href='#'>Support forum (Talk Maemo Org)</a>";
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("http://talk.maemo.org/showthread.php?p=1404100#post1404100")
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: "<a href='#'>Source code (GitHub)</a>";
                linkColor: Theme.highlightColor
                onLinkActivated: Qt.openUrlExternally("https://github.com/Mariusmssj/harbour-vlc-remote")
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.primaryColor
                font.pixelSize: Theme.fontSizeMedium
                text: "Mariusmssj 2015"
            }
        }
    }
}
