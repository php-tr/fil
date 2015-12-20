import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.phptr.fil 2.0

FilModalDialog {
    property string title: ''
    property string text: ''

    id: messageOverlay

    loader.sourceComponent: Item {
        Column {
            width: parent.width
            spacing: dp(10)

            FilText {
                text: title === '' ? qsTr('Information') : title
                font.pixelSize: sp(17)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FilText {
                text: messageOverlay.text
                font.family: 'Open Sans'
                font.pixelSize: sp(15)
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
