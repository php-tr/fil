import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.phptr.philip 1.0

Item
{
    id: page

    signal refreshList;
    signal nextPage;

    property Component pageComponent;
    property string name;
    property string title;

    property bool refreshButtonVisible: true

    onRefreshList:
    {
        console.log('Refresh list triggered');
        page.nextPage();
        ApplicationInfo.magazineListModel.retrieveDataFromApi();
    }

    Binding
    {
        target: ApplicationInfo
        property: "applicationWidth"
        value: page.width
    }

    Rectangle
    {
        id: header
        z: 2
        width: parent.width
        anchors.top: parent.top
        height: 100 * ApplicationInfo.ratio
        color: ApplicationInfo.theme.headerBackgroundColor

        RowLayout
        {
            id: headerRowLayout
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right

            Separator {}
            Image
            {
                source: ApplicationInfo.getAsset("fil-header-logo.png")
                Layout.preferredWidth: 112 * ApplicationInfo.ratio
                Layout.preferredHeight: 75 * ApplicationInfo.ratio
            }
            Item
            {
                Layout.fillWidth: true
            }

            Image
            {
                id: refreshButton
                opacity: headerMouseArea.pressed ? .5 : 1
                Behavior on opacity
                {
                    NumberAnimation{}
                }

                source: ApplicationInfo.getAsset("refresh.png")
                Layout.preferredWidth: 72 * ApplicationInfo.ratio
                Layout.preferredHeight: 85 * ApplicationInfo.ratio
                visible: page.refreshButtonVisible
            }
            Separator{}
        }

        Rectangle
        {
            width: parent.width
            height: 8 * ApplicationInfo.ratio
            anchors.top: parent.bottom
            gradient: Gradient
            {
                GradientStop
                {
                    position: 0
                    color: ApplicationInfo.theme.headerBottomLine1Color
                }
                GradientStop
                {
                    position: 1
                    color: ApplicationInfo.theme.headerBottomLine2Color
                }
            }
        }

        MouseArea
        {
            id: headerMouseArea
            z: 2
            anchors.fill: parent
            onClicked:
            {
                if (refreshButton.visible)
                {
                    page.refreshList();
                }
            }
        }
    }

    Loader
    {
        sourceComponent: pageComponent
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: parent.width

        Rectangle
        {
            z: -1
            anchors.fill: parent
            color: ApplicationInfo.theme.bodyBackgroundColor

            Image
            {
                id: tiledBgImage
                anchors.fill: parent
                fillMode: Image.Tile
                source: ApplicationInfo.getAsset("fil-bg-tiled.png")
                sourceSize.width: 226 * ApplicationInfo.ratio
                sourceSize.height: 223 * ApplicationInfo.ratio
            }
        }
    }
}
