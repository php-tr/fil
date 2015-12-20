import QtQuick 2.0

Item {
    property alias circle: circle
    property alias innerCircle: innerCircle
    property real maxOpacity: .1
    property bool circlar: true

    id: touchIneraction

    width: dp(48)
    height: dp(48)
    visible: false
    anchors.centerIn: parent

    function press() {
        visible = true;
        circle.opacity = maxOpacity;
        circleAnimation.start();
    }

    function release() {
        innerCircleAnimation.start();
    }

    function complete() {
        circle.opacity = 0;
        visible = false;
    }

    Rectangle {
        id: circle

        width: parent.width
        height: parent.height
        radius: height / 2
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        visible: opacity > 0
        color: '#000'
        anchors.centerIn: parent

        ParallelAnimation {
            id: circleAnimation

            PropertyAnimation {
                target: circle
                property: 'width'
                from: touchIneraction.width / 2
                to: touchIneraction.width
                duration: 200
            }

            PropertyAnimation {
                target: circle
                property: 'radius'
                from: target.height / 2
                to: circlar ? target.height / 2 : 0
                duration: 200
            }
        }
    }

    Rectangle {
        id: innerCircle

        width: 0
        height: circlar ? width : touchIneraction.height
        radius: height / 2

        anchors.centerIn: parent
        opacity: .1
        color: '#fff'

        ParallelAnimation {
            id: innerCircleAnimation

            PropertyAnimation {
                target: innerCircle
                property: 'width'
                from: 0
                to: touchIneraction.width
                duration: 200
            }

            PropertyAnimation {
                target: innerCircle
                property: 'radius'
                from: touchIneraction.height / 2
                to: circlar ? touchIneraction.height / 2 : 0
                duration: 200
            }

            onRunningChanged: if (!running) touchIneraction.complete()
        }
    }
}
