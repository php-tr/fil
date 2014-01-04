import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import org.phptr.philip 1.0

BasicPage
{
    signal refreshed
    signal refreshError(string errorString)

    id: refreshPageContainer
    property string statusText: qsTr("Loading Data")

    height: ApplicationInfo.applicationDefaultHeight
    name: "refresh"
    refreshButtonVisible: false

    Connections
    {
        target: ApplicationInfo.magazineListModel
        onRefreshError:
        {
            refreshPageContainer.refreshError(errorString);
        }

        onRefreshed:
        {
            refreshPageContainer.refreshed();
        }
    }

    Rectangle
    {
        id: mainContainer
        color: ApplicationInfo.theme.bodyBackgroundColor
        anchors.fill: parent

        Item
        {
            anchors.centerIn: parent
            Text
            {
                id: statusLabel
                anchors.centerIn: parent
                font.pointSize: 32 * ApplicationInfo.ratio
                font.family: ApplicationInfo.theme.secondaryFont
                text: refreshPageContainer.statusText
                color: ApplicationInfo.theme.magazineListBackgroundColor
            }

            Item
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: statusLabel.bottom
                anchors.topMargin: 10
                width: 64 * ApplicationInfo.ratio
                height: 64 * ApplicationInfo.ratio

                BusyIndicator
                {
                    style: Item
                    {
                        implicitWidth: 64 * ApplicationInfo.ratio
                        implicitHeight: 64 * ApplicationInfo.ratio

                        Image
                        {
                            width: Math.min(parent.width, parent.height)
                            height: width
                            source: ApplicationInfo.getAsset("spinner.png")
                            RotationAnimator on rotation
                            {
                                duration: 1200
                                loops: Animation.Infinite
                                from: 0
                                to: 360
                            }
                        }
                    }
                }
            }
        }
    }
}
