import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

BusyIndicator {
    style: BusyIndicatorStyle {
        indicator: Item {
            id: indicatorItem

            implicitWidth: dp(32)
            implicitHeight: dp(32)

            opacity: control.running ? 1 : 0
            Behavior on opacity { OpacityAnimator { duration: 250 } }

            Image {
                anchors.centerIn: parent
                anchors.alignWhenCentered: true
                width: Math.min(parent.width, parent.height)
                height: width
                source: imagePath('spinner.png')
                RotationAnimator on rotation {
                    duration: 800
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    running: indicatorItem.visible && (control.running || indicatorItem.opacity > 0);
                }
            }
        }

        panel: Item {
            anchors.fill: parent
            implicitWidth: indicatorLoader.implicitWidth
            implicitHeight: indicatorLoader.implicitHeight

            Loader {
                id: indicatorLoader
                sourceComponent: indicator
                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height)
                height: width
            }
        }
    }
}

