import QtQuick 2.5
import QtQuick.Layouts 1.1
import org.phptr.fil 2.0

FilModalDialog {
    signal confirmed()
    signal cancelled()

    property string title: ''
    property string text: ''

    id: messageOverlay

    showSideBar: false

    loader.sourceComponent: Item {
        anchors.fill: parent
        anchors.margins: dp(10)

        Column {
            width: parent.width
            spacing: dp(10)
            anchors.centerIn: parent

            FilText {
                text: title === '' ? qsTr('Confirmation') : title
                font.pixelSize: sp(21)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FilText {
                text: messageOverlay.text
                font.family: 'Open Sans'
                font.pixelSize: sp(14)
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                height: dp(32)
                spacing: dp(13)

                anchors.horizontalCenter: parent.horizontalCenter

                FilButton {
                    label.text: qsTr('Confirm')
                    mouse.onClicked: { confirmed(); close(); }
                }

                FilButton {
                    label.text: qsTr('Cancel')
                    mouse.onClicked: { cancelled(); close(); }
                }
            }
        }
    }
}
