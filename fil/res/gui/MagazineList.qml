import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2
import Frame.Mobile 1.0
import Frame.Mobile.Core 1.0
import org.phptr.fil 2.0

FilPage {
    property string pageTAG: '[MagazineList]'
    property alias magazineModel: magazineModel

    id: root

    onAfterOpen: d.render()

    QtObject {
        id: d

        property bool rendered: false
        property bool busy: false
        property int pendingDownloadModelIndex: -1
        property int inProgressDownloadIndex: -1

        function handleSyncStarted() {
            Util.setTimeout(function() {
                d.update();
            }, 100);
        }

        function render() {
            if (rendered)
                return;

            magazineModel.load();
            rendered = true;
        }

        function update() {
            if (d.busy)
                return;
        }

        function lock(value) {
            d.busy = value;
            if (scene)
                scene.locked = value;
        }

        function handleMagazineClick(index) {
            var data = magazineModel.model.get(index);
            if (!data.is_downloaded) {
                pendingDownloadModelIndex = index;
                dialogConfirm.open();
            } else {
                pdfReader.openPdf(data.pdf_path);
                globalAnalytics.sendEvent("UX", "Acilis", "Dergi (Sayi: " + data.magazine_id + ")", data.magazine_id);
            }
        }

        function confirmDownload() {
            if (pendingDownloadModelIndex === -1)
                return;

            var data = magazineModel.model.get(pendingDownloadModelIndex);

            downloadProgress.open();
            inProgressDownloadIndex = resourceDownloader.nextIndex();
            resourceDownloader.download(data.pdf_url, data.magazine_id + '.pdf');

            globalAnalytics.sendEvent("UX", "Indirme", "Onaylandi (Sayi: " + data.magazine_id + ")", data.magazine_id);
        }

        function cancelDownload() {
            var data = magazineModel.model.get(pendingDownloadModelIndex);
            globalAnalytics.sendEvent("UX", "Indirme", "Iptal Edildi (Sayi: " + data.magazine_id + ")", data.magazine_id);
        }

        function handleDownloadProgress(index, url, bytesReceived, bytesTotal) {
            if (inProgressDownloadIndex !== index)
                return;

            downloadProgress.byteLoaded = bytesReceived;
            downloadProgress.byteTotal = bytesTotal;
        }

        function handleDownloadFinished(index, url, fullPath) {
            if (inProgressDownloadIndex !== index)
                return;

            var data = magazineModel.model.get(pendingDownloadModelIndex);

            downloadProgress.close();
            magazineModel.setPdfPath(data.magazine_id, fullPath);

            globalAnalytics.sendEvent("UX", "Indirme", "Tamamlandi (Sayi: " + data.magazine_id + ")", data.magazine_id);
        }

        function handleDownloadCancel() {
            resourceDownloader.abort(inProgressDownloadIndex);
            var data = magazineModel.model.get(pendingDownloadModelIndex);
            globalAnalytics.sendEvent("UX", "Indirme", "Iptal Edildi (Sayi: " + data.magazine_id + ")", data.magazine_id);
        }
    }

    MagazineModel {
        id: magazineModel

        onInProgressChanged: d.lock(inProgress)
    }

    FilModalConfirm {
        id: dialogConfirm
        title: qsTr('Download Confirmation')
        text: qsTr('Are you sure to download magazine?')

        onConfirmed: d.confirmDownload()
        onCancelled: d.cancelDownload()
    }

    FilDownloadProgress {
        id: downloadProgress

        onClosed: d.handleDownloadCancel()
    }

    PdfReader {
        id: pdfReader
    }

    ListView {
        anchors.fill: parent
        anchors.topMargin: dp(2)
        clip: true
        spacing: dp(7)
        model: magazineModel.model
        header: Item {
            implicitHeight: dp(7)
        }

        delegate: Rectangle {
            property bool is_pdf_downloaded: magazineModel.model.get(index).is_downloaded ? true : false

            width: parent.width
            height: dp(60)
            color: '#5398cf'

            RowLayout {
                anchors.fill: parent

                Item {
                    implicitWidth: dp(50)
                    implicitHeight: parent.height

                    Image {
                        id: magazineImage

                        width: dp(36)
                        height: dp(52)
                        source: resourceDownloader.getCachedUrl(image_url)
                        asynchronous: true
                        anchors.centerIn: parent
                        visible: status === Image.Ready
                    }

                    Image {
                        width: dp(36)
                        height: dp(36)
                        source: imagePath('holder.png')
                        anchors.centerIn: parent
                        visible: magazineImage.status !== Image.Ready
                    }
                }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: parent.height

                    FilText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                        font.pixelSize: sp(23)
                    }
                }

                Item {
                    implicitWidth: dp(52)
                    implicitHeight: parent.height

                    Image {
                        width: dp(31)
                        height: dp(31)
                        source: imagePath('download.png')
                        anchors.centerIn: parent
                        visible: !is_pdf_downloaded
                    }

                    Image {
                        width: dp(31)
                        height: dp(31)
                        source: imagePath('view.png')
                        anchors.centerIn: parent
                        visible: is_pdf_downloaded
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onPressedChanged: pressed ? touchInteraction.press() : touchInteraction.release()
                onClicked: d.handleMagazineClick(index)
            }

            TouchInteractionButton {
                id: touchInteraction

                circlar: false
                width: parent.width
                height: parent.height
            }
        }
    }

    Connections {
        target: resourceDownloader
        onDownloadProgress: d.handleDownloadProgress(index, url, bytesReceived, bytesTotal)
        onDownloadFinished: d.handleDownloadFinished(index, url, fullPath)
    }
}

