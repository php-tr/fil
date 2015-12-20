import QtQuick 2.5
import Frame.Mobile 1.0

NavigationPage {
    id: root
    color: '#fff'

    width: parent ? parent.width : dp(320)
    height: parent ? parent.height : dp(480)

    Image {
        source: imagePath('bg-tiled.png')
        fillMode: Image.Tile
        anchors.fill: parent
    }
}

