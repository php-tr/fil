import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import org.phptr.philip 1.0

ApplicationWindow
{
    signal pageLoad(string pageTitle);

    id: root
    width: 1200
    height: 700

    onPageLoad:
    {
        ApplicationInfo.analytics.sendViewEvent(pageTitle);
    }

    Connections
    {
        target: Qt.application
        onStateChanged:
        {
            if (Qt.application.state === Qt.ApplicationSuspended)
            {
                ApplicationInfo.magazineListModel.saveToDb();
            }
        }
    }

    property Component magazineListPage: MagazineList
    {
        id: magazineList
        onNextPage:
        {
            pageView.push(refreshPage);
        }

        Component.onCompleted:
        {
            root.pageLoad(magazineList.title);
        }
    }

    Timer
    {
        id: delayedPop
        running: false
        repeat: false
        onTriggered:
        {
            pageView.pop();
        }
    }

    property Component refreshPage: Refresh
    {
        id: rfrsh

        onRefreshed:
        {
            delayedPop.interval = 2000;
            delayedPop.start();
        }

        onRefreshError:
        {
            statusText = errorString;
            delayedPop.interval = 5000;
            delayedPop.start();
        }
    }

    StackView
    {
        id: pageView
        anchors.fill: parent
        initialItem: magazineListPage

        delegate: StackViewDelegate
        {
            function transitionFinished(properties)
            {
                properties.exitItem.opacity = 1
                root.pageLoad(properties.enterItem.title);
            }

            pushTransition: StackViewTransition
            {
                PropertyAnimation
                {
                    target: enterItem
                    property: "x"
                    from: target.width
                    to: 0
                    duration: 500
                    easing.type: Easing.OutCirc
                }

                PropertyAnimation
                {
                    target: exitItem
                    property: "x"
                    from: 0
                    to: -target.width
                    duration: 500
                    easing.type: Easing.OutCirc
                }
            }

            popTransition: StackViewTransition
            {
                PropertyAnimation
                {
                    target: enterItem
                    property: "x"
                    from: -target.width
                    to: 0
                    duration: 500
                    easing.type: Easing.OutCirc
                }

                PropertyAnimation
                {
                    target: exitItem
                    property: "x"
                    from: 0
                    to: target.width
                    duration: 500
                    easing.type: Easing.OutCirc
                }
            }
        }
    }
}
