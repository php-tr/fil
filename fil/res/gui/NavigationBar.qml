import QtQuick 2.5
import Frame.Mobile 1.0

NavigationBarController {
    signal refreshed()
    property bool locked: false

    color: '#5398cf'

    leftLoader.sourceComponent: Item {
        implicitWidth: dp(56)
        implicitHeight: dp(44)

        anchors.left: parent.left
        anchors.leftMargin: dp(7)

        Image {
            width: dp(56)
            height: dp(38)
            source: imagePath('title.png')

            anchors.verticalCenter: parent.verticalCenter
        }
    }

    rightLoader.sourceComponent: Item {
        implicitWidth: dp(44)
        implicitHeight: dp(44)

        NavigationBarButton {
            id: refreshButton

            interactiveBackground.visible: false

            icon.source: imagePath('refresh.png')
            icon.width: dp(38)
            icon.height: dp(38)

            opacity: locked ? .7 : 1

            mouse.onClicked: refreshed()
            mouse.onPressedChanged: mouse.pressed ? refreshIneractionLogout.press() : refreshIneractionLogout.release()
            mouse.enabled: !locked

            TouchInteractionButton {
                maxOpacity: .5
                circle.color: '#fff'
                id: refreshIneractionLogout

                anchors.centerIn: parent
            }

            PropertyAnimation {
                target: refreshButton
                properties: 'rotation'
                from: 0
                to: 360
                loops: Animation.Infinite
                running: locked
                duration: 5000
                onRunningChanged: if (!running) refreshButton.rotation = 0
            }
        }
    }
    z: 99
    height: dp(44)

    Rectangle {
        color: '#17e4f2'
        height: dp(2)
        width: parent.width
        anchors.top: parent.bottom
    }
}

