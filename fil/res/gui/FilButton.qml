import QtQuick 2.5
import Frame.Mobile 1.0
import Frame.Mobile.Core 1.0

TouchButton {
    label.font.family: 'TR Blue Highway'
    label.font.pixelSize: sp(19)
    label.color: '#fff'
    padding: dp(15)
    mouse.onPressedChanged: mouse.pressed ? touchInteraction.press() : touchInteraction.release()

    Rectangle {
        anchors.fill: parent
        radius: dp(4)
        color: '#36BCE1'
    }

    TouchInteractionButton {
        id: touchInteraction

        circlar: false
        width: parent.width
        height: parent.height
    }
}
