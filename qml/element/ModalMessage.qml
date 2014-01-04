import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.phptr.philip 1.0

ModalDialog
{
    property string messageText
    id: messageOverlay

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
                text: qsTr("Information")
                font.family: ApplicationInfo.theme.primaryFont
                font.pixelSize: 30 * ApplicationInfo.ratio
                color: ApplicationInfo.theme.textColor
            }
        }

        RowLayout
        {
            Layout.alignment: Qt.AlignHCenter
            Text
            {
                text: messageOverlay.messageText
                font.family: ApplicationInfo.theme.secondaryFont
                font.pixelSize: 20 * ApplicationInfo.ratio
                color: ApplicationInfo.theme.textColor
            }
        }
    }
}
