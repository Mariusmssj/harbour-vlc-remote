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
import "../pages"

CoverBackground {

    Image{
        source: "vlc_cover.svg"
        sourceSize.width: parent.width
//        anchors {
//            top: parent.top
//            topMargin: Theme.paddingSmall
//        }
        y: coverActionArea.y / 2 - height / 2
    }

    Item {
        height: lblTitle.y + lblTitle.height
        width: parent.width
        y: lblSeek.y / 2 - height / 2

        property int lineCount: lblArtist.lineCount + lblTitle.lineCount

        Label {
            id: lblArtist
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: Theme.paddingSmall
                right: parent.right
                rightMargin: Theme.paddingSmall
            }
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: lblTitle.text === "" ? 6 : 3 - Math.min((lblTitle.lineCount - 3), 0)
            text: (getSync() !== 0) ? getArtist() : ""
        }

        Label {
            id: lblTitle
            anchors {
                top: lblArtist.text === "" ? parent.top : lblArtist.bottom
                topMargin: lblArtist.text === "" ? 0 : Theme.paddingMedium
                left: parent.left
                leftMargin: Theme.paddingSmall
                right: parent.right
                rightMargin: Theme.paddingSmall
            }
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount:lblArtist.text === "" ? 6 : 3 - Math.min((lblArtist.lineCount - 3), 0)
            text: (getSync() !== 0) ? getTitle() : ""
        }
    }

    Label {
        id: lblSeek
        anchors{
            bottom: coverActionArea.top
            horizontalCenter: parent.horizontalCenter
        }
        truncationMode: TruncationMode.Fade
        color: Theme.highlightColor
        scale: lblArtist.width < width ? lblArtist.width / width : 1
        text: (getSync() !== 0) ? getSeek() : ""
    }

    Timer {
        id: upTimer
        interval: getSync(); running: true; repeat: true
        onTriggered: {
            lblTitle.text = getTitle();
            lblSeek.text = getSeek();
        }
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            id: caNext
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                passCommands("pl_next");
                //callUpdate();
                //lblTitle.text = getTitle();
                //lblSeek.text = getSeek();
            }
        }

        CoverAction {
            iconSource: "play-pause.png"
            onTriggered: {
                passCommands("pl_pause");
                //callUpdate();
                //lblTitle.text = getTitle();
                //lblSeek.text = getSeek();
            }
        }
    }

}

