import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import org.phptr.fil 2.0

FilModalDialog {
    property int byteLoaded: 0
    property int byteTotal: 0

    id: downloadProgressOverlay

    function open() {
        byteLoaded = 0;
        byteTotal = 0;
        visible = true;
    }

    loader.sourceComponent: Item {
        property int progress: byteTotal === 0 ? 0 : (byteLoaded / byteTotal) * 100

        anchors.fill: parent
        anchors.margins: dp(10)

        Column {
            id: column

            width: parent.width
            spacing: dp(10)
            anchors.centerIn: parent

            FilText {
                text: qsTr('Download in progress...')
                font.pixelSize: sp(21)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            FilText {
                text: qsTr("%1% (%2/%3 MB)")
                    .arg(progress)
                    .arg((byteLoaded / (1024 * 1024)).toFixed(2))
                    .arg((byteTotal / (1024 * 1024)).toFixed(2));
                font.family: 'Open Sans'
                font.pixelSize: sp(13)
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ProgressBar {
                maximumValue: 100
                minimumValue: 0
                value: progress
                anchors.horizontalCenter: parent.horizontalCenter

                style: ProgressBarStyle {
                    background: Rectangle {
                        color: "#FFFFFF"
                        border.color: "#FFFFFF"
                        border.width: dp(1)
                        implicitWidth: column.width * .8
                        implicitHeight: dp(20)
                    }

                    progress: Rectangle {
                        color: "#00FFFF"
                    }
                }
            }
        }
    }
}
