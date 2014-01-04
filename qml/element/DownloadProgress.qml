import QtQuick 2.2
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import org.phptr.philip 1.0

ModalDialog
{
    property int progress: 0
    property int byteLoaded: 0
    property int byteTotal: 0

    id: downloadProgressOverlay
    dialogHeight: 250 * ApplicationInfo.ratio

    function open()
    {
        byteLoaded = 0;
        byteTotal = 0;
        progress = 0;
        visible = true;
    }

    dialogComponent: GridLayout
    {
        anchors.verticalCenter: parent.verticalCenter
        flow: Qt.LeftToRight
        columns: 1
        rowSpacing: 20 * ApplicationInfo.ratio

        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Text
            {
                text: qsTr("Download in progres please be patient.")
                font.family: ApplicationInfo.theme.primaryFont
                font.pixelSize: 34 * ApplicationInfo.ratio
                color: ApplicationInfo.theme.textColor
            }
        }

        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Text
            {
                text: qsTr("Downloading: %1% (%2 Mb Loaded / %3 Total Mb)")
                    .arg(downloadProgressOverlay.progress)
                    .arg((downloadProgressOverlay.byteLoaded / (1024 * 1024)).toFixed(2))
                    .arg((downloadProgressOverlay.byteTotal / (1024 * 1024)).toFixed(2));
                font.family: "Open Sans"
                font.pixelSize: 20 * ApplicationInfo.ratio
                color: ApplicationInfo.theme.textColor
            }
        }

        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            ProgressBar
            {
                maximumValue: 100
                minimumValue: 0
                value: downloadProgressOverlay.progress
                Layout.preferredWidth: Layout.width * 0.8;
                style: ProgressBarStyle
                {
                    background: Rectangle
                    {
                        color: "#FFFFFF"
                        border.color: "#FFFFFF"
                        border.width: 1
                        implicitWidth: 200
                        implicitHeight: 20
                    }

                    progress: Rectangle
                    {
                        color: "#00FFFF"
                    }
                }
            }
        }
    }
}
