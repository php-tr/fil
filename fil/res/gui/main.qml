import QtQuick 2.5
import QtQuick.Controls 1.4
import Frame.Mobile 1.0
import Frame.Mobile.Core 1.0
import org.phptr.fil 2.0

ApplicationWindow {
    id: applicationWindow

    width: ScreenInfo.dp(320)
    height: ScreenInfo.dp(480)
    visible: true

    function imagePath(value) {
        var scaleFactor = Application.platform === 'OSX' ? 2 : Math.min(4, ScreenInfo.imageScaleFactor);
        var imgPath = 'qrc:/res/img/' + scaleFactor + 'x/' + value;

        return imgPath;
    }

    function qmlPath(value) {
        return 'qrc:/res/gui/' + value;
    }

    function fontPath(value) {
        return 'qrc:/res/font/' + value;
    }

    function dp(px) {
        return ScreenInfo.dp(px);
    }

    function sp(px) {
        return ScreenInfo.sp(px);
    }

    Item {
        anchors.fill: parent
        Loader {
            id: mainLoader

            anchors.fill: parent
            asynchronous: true
        }

        Rectangle {
            id: splashCover

            color: '#fff'
            anchors.fill: parent
            visible: mainLoader.status === Loader.Null || mainLoader.status === Loader.Loading

            Image {
                source: imagePath('bg-tiled.png')
                fillMode: Image.Tile
                anchors.fill: parent
            }

            Column {
                width: parent.width
                spacing: dp(13)
                anchors.centerIn: parent

                Image {
                    id: splash

                    source: imagePath('splash-logo.png')
                    width: dp(220)
                    height: dp(200)
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                FilText {
                    font.family: 'Open Sans'
                    font.pixelSize: sp(30)
                    text: 'PHP TR Dergi'
                    color: '#0b6bbb'
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        Timer {
            running: true
            interval: 100
            onTriggered: mainLoader.source = qmlPath('LandPage.qml')
        }
    }
}


