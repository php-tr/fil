import QtQuick 2.5
import Frame.Mobile 1.0
import Frame.Mobile.Core 1.0
import org.phptr.fil 2.0

Scene {
    property bool locked: false

    id: scene

    width: parent.width
    height: parent.height

    navigation.initialPageId: 'magazineList'
    navigation.pages: [
        NavigationPageInfo {
            pageId: 'magazineList'
            pageType: NavigationInfo.Standard
            sourcePage: MagazineList {}
        }
    ]

    topLoader.height: dp(44)
    topLoader.sourceComponent: NavigationBar {
        label.text: ''
        locked: scene.locked
        onRefreshed: d.syncIfNecessary()
    }

    QtObject {
        id: d

        property int appState: 0

        onAppStateChanged: applyState(appState)

        function applyState(state) {
            switch (state) {
            case Qt.ApplicationActive:
                console.log('[System]', 'Application is active now. Checking sync status.');
                syncIfNecessary();
                break;
            }
        }

        function init() {
            globalAnalytics.init();
            globalAnalytics.setConfig({
                ga_trackingId: ApplicationInfo.platform === 'Android' ? 'UA-47068869-1' : 'UA-47064847-1',
                ga_appVersion: ApplicationInfo.version,
                ga_appName: 'Fil',
                ga_dispatchPeriod: 300
            });
        }

        function handleApplicationStateChange(state) {
            appState = state;
        }

        function syncIfNecessary() {
            navigation.currentPage.magazineModel.sync();
        }
    }

    Analytics {
        id: globalAnalytics
    }

    ResourceDownloader {
        id: resourceDownloader
    }

    Connections {
        target: Qt.application
        onStateChanged: d.handleApplicationStateChange(Qt.application.state)
    }

    Component.onCompleted: d.init()
}

