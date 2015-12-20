import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import org.phptr.fil 2.0

Item {
    signal closed()

    property alias loader: loader
    property bool closeOnClick: false
    property bool showSideBar: true
    property bool hasTopLoader: true

    id: dialogOverlay

    width: parent.width
    height: parent.height + (hasTopLoader ? dp(44) : 0)
    y: hasTopLoader ? -dp(44) : 0
    z: 9999
    visible: false

    function open() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onClicked: if (closeOnClick) closed()
    }

    Rectangle {
        anchors.fill: parent;
        color: '#000000'
        opacity: .7
    }

    Rectangle {
        id: dialogRect
        width: parent.width
        height: dp(140)
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        color: '#5498D0'

        RowLayout {
            anchors.fill: parent
            Item {
                Layout.fillWidth: true
                height: parent.height

                Loader {
                    id: loader

                    anchors.fill: parent
                }
            }

            Item {
                implicitWidth: dp(60)
                height: parent.height
                visible: showSideBar

                Rectangle {
                    anchors.fill: parent
                    color: '#4781b1'
                }

                Image {
                    id: closeButton
                    anchors.centerIn: parent
                    source: imagePath('close.png')
                    width: dp(19)
                    height: dp(19)
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    onClicked: { close(); closed(); }
                    onPressedChanged: pressed ? touchInteraction.press() : touchInteraction.release()
                }

                TouchInteractionButton {
                    id: touchInteraction

                    circlar: false
                    width: parent.width
                    height: parent.height
                }
            }
        }
    }
}
