import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingMedium
            PageHeader {
                title: "VLC Setup Help"
            }
            SectionHeader { text: "How to Connect" }
            Text{
                width: parent.width - 10
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: Theme.fontSizeSmall
                text: "
    1. Open the VLC settings
        VLC Menu/Tools/Preferences
    2. Enable 'All Settings'
        Click on the 'All' button at the bottom left of the screen
    3. Find the 'Main interfaces' preference page
        Expand the options for Interfaces
        Select Main interfaces
    4. Select the 'Web' checkbox.
        This should show 'http' in the text box.
    5. Click on the Lua icon on the left
        Enter a password under Lua HTTP
    6. The default password we use is 'vlcremote'
    7. Click save to save your preferences
    8. Quit VLC and reopen it.
    9. Use your PC's Ip address to connect to VLC player"
            }

            SectionHeader { text: "VLC Remote tips" }
            Text{
                width: parent.width - 10
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: Theme.fontSizeSmall
                text: "
    - On Jolla some non English keyboards don't have a dot . but only a comma , so when
entering the Ip you can just use , and it will be auto changed to .
    - To test that VLC web interface is working on your computer, open a media file with
VLC and in your web browsers URL bar type in http://localhost:8080/ if
you see VLC interface means it's configured correctly if not check VLC Settings
    - To test that VLC remote is connected from pulley menu choose Connection Settings
and then from a second pulley menu choose check connection
    - Password setup on VLC player is required, but username is optional
"
            }

            SectionHeader { text: "UI guide" }
            Text{
                width: parent.width - 10
                color: Theme.primaryColor
                wrapMode: Text.WordWrap
                anchors.left: parent.left
                anchors.leftMargin: 10
                font.pixelSize: Theme.fontSizeSmall
                text: "
    - To open Media browser just swipe to the left and to go back initial page swipe to the right
    - In Media browser clicking on a supported file will make in play in VLC player right away,
with a long press you can send it to playlist
    - To open Additional controls just swipe up and to go back to initial page swipe down
"
            }

            Text {
                id: link_Text
                anchors.horizontalCenter: parent.horizontalCenter
                text: '<html><style type="text/css"></style><a href="http://hobbyistsoftware.com/VLCSetup-win-manual">Full setup guide can be found here</a></html>'
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Text {

                anchors.horizontalCenter: parent.horizontalCenter
                text: " "
            }
        }
    }
}
