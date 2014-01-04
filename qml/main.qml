import QtQuick 2.1
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import org.phptr.philip 1.0

ApplicationWindow
{
    id: root
    width: 1200
    height: 700

    property Component magazineListPage: MagazineList
    {
        onNextPage:
        {
            pageView.push(refreshPage);
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
