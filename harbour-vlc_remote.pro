# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-vlc_remote

CONFIG += sailfishapp

SOURCES += src/harbour-vlc_remote.cpp \
    src/playlistmodel.cpp \
    src/handler.cpp
QT+=xml
OTHER_FILES += qml/harbour-vlc_remote.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/SecondPage.qml \
    rpm/harbour-vlc_remote.spec \
    rpm/harbour-vlc_remote.yaml \
    harbour-vlc_remote.desktop \
    qml/pages/VlcHelp.qml \
    qml/pages/VlcFileBrowser.qml \
    qml/pages/db.js \
    qml/pages/fileCheck.js \
    qml/pages/VlcPlaylist.qml \
    qml/pages/db2.js \
    qml/pages/AboutPage.qml

HEADERS += \
    src/playlistmodel.h \
    src/xmlitem.h \
    src/handler.h

