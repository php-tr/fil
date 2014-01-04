import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.phptr.philip 1.0

Item
{
    signal closed

    property int dialogHeight: 140 * ApplicationInfo.ratio
    property int rightColumnWidth: 120 * ApplicationInfo.ratio

    property Component dialogComponent

    id: dialogOverlay
    anchors.fill: parent
    z: 5
    visible: false

    function open()
    {
        visible = true;
    }

    function close()
    {
        visible = false;
    }

    Rectangle
    {
        anchors.fill: parent;
        color: ApplicationInfo.theme.modalBackgroundColor
        opacity: 0.5
    }

    Rectangle
    {
        id: dialogRect
        width: parent.width
        height: dialogOverlay.dialogHeight
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        color: ApplicationInfo.theme.headerBackgroundColor

        GridLayout
        {
            anchors.fill: parent
            columns: 2

            RowLayout
            {
                Item
                {
                    Layout.preferredWidth: dialogRect.width - dialogOverlay.rightColumnWidth;
                    Loader
                    {
                        sourceComponent: dialogComponent
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle
                {
                    Layout.fillHeight: true
                    Layout.preferredWidth: dialogOverlay.rightColumnWidth;
                    color: closeMouse.pressed ? Qt.lighter(ApplicationInfo.theme.colorAlt2, 1.3) : ApplicationInfo.theme.colorAlt2

                    Image
                    {
                        id: closeButton
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: ApplicationInfo.getAsset("close.png")
                        sourceSize.width: 48 * ApplicationInfo.ratio
                        sourceSize.height: 48 * ApplicationInfo.ratio
                        z: 7
                    }

                    MouseArea
                    {
                        id: closeMouse
                        anchors.fill: parent
                        onClicked:
                        {
                            dialogOverlay.close();
                            dialogOverlay.closed();
                        }
                    }
                }
            }
        }
    }
}
