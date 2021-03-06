import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.phptr.philip 1.0

BasicPage
{
    height: ApplicationInfo.applicationDefaultHeight
    name: "magazineList"
    title: "Dergi Listesi"

    DownloadProgress
    {
        id: downloadProgressDialog
        onClosed:
        {
            var id = ApplicationInfo.magazineListModel.cancelDownload();
            ApplicationInfo.analytics.sendEvent("UX", "Indirme", "Iptal Edildi (Sayi: " + id + ")", id);
        }
    }

    ModalMessage
    {
        id: modalMessageOverlay
    }

    NativeDialog
    {
        id: dialog
        onDownloadConfirmed:
        {
            ApplicationInfo.analytics.sendEvent("UX", "Indirme", "Onaylandi (Sayi: " + id + ")", id);
            downloadProgressDialog.open()
            ApplicationInfo.magazineListModel.downloadById(id);
        }

        onDownloadCanceled:
        {
            ApplicationInfo.analytics.sendEvent("UX", "Indirme", "Iptal Edildi (Sayi: " + id + ")", id);
        }
    }

    Connections
    {
        target: ApplicationInfo.magazineListModel
        onDownloadCompleted:
        {
            downloadProgressDialog.close();
            ApplicationInfo.analytics.sendEvent("UX", "Indirme", "Tamamlandi (Sayi: " + id + ")", id);
        }

        onDownloadProgress:
        {
            console.log("Progress: " + readed + " / " + total)
            if (!downloadProgressDialog.visible)
            {
                downloadProgressDialog.open();
            }

            downloadProgressDialog.byteLoaded = readed;
            downloadProgressDialog.byteTotal = total;
            downloadProgressDialog.progress = (readed / total) * 100;
        }

        onDownloadError:
        {
            downloadProgressDialog.close();
            modalMessageOverlay.messageText = qsTr("Error occured while downloading file");
            modalMessageOverlay.open();

            ApplicationInfo.analytics.sendEvent("Hata", "Indirme", "Indirme Hatayla Sonuclandi. (" + errorString + ")");
        }
    }

    pageComponent: ScrollView
    {
        y: 4 * ApplicationInfo.ratio

        // frameVisible: false
        flickableItem.interactive: true
        flickableItem.flickableDirection: Flickable.VerticalFlick

        ListView
        {
            id: listview
            model: ApplicationInfo.magazineListModel
            interactive: true
            flickableDirection: Flickable.VerticalFlick

            delegate: Rectangle
            {
                id: listView
                height: 122 * ApplicationInfo.ratio
                width: parent.width
                color: ApplicationInfo.theme.magazineListBackgroundColor
                opacity: mouseArea.pressed ? .8 : 1
                Behavior on opacity { NumberAnimation {} }

                MouseArea
                {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked:
                    {
                        if (!row.hasPdf)
                        {
                            dialog.confirmDownload(magazineId);
                            ApplicationInfo.analytics.sendEvent("UX", "Indirme", "Onay Istemi (Sayi: " + magazineId + ")", magazineId);
                        }
                        else
                        {
                            ApplicationInfo.magazineListModel.open(magazineId);
                            ApplicationInfo.analytics.sendEvent("UX", "Acilis", "Dergi (Sayi: " + magazineId + ")", magazineId);
                        }
                    }
                }

                Rectangle
                {
                    id: rectSpacer
                    width: parent.width
                    height: 4 * ApplicationInfo.ratio
                    color: ApplicationInfo.theme.bodyBackgroundColor
                }

                GridLayout
                {
                    anchors.fill: parent
                    flow: Qt.LeftToRight
                    columnSpacing: 0
                    rowSpacing: 0
                    columns: 1
                    // anchors.topMargin: rectSpacer.height * 2
                    RowLayout
                    {
                        id: row
                        property bool hasPdf: ApplicationInfo.magazineListModel.getMagazineModelById(magazineId).isPdfDownloaded

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 0

                        Item
                        {
                            implicitWidth: 12 * ApplicationInfo.ratio
                            Layout.minimumWidth: implicitWidth
                        }

                        Image
                        {
                            width: 62 * ApplicationInfo.ratio
                            height: 88 * ApplicationInfo.ratio
                            sourceSize.width: 62 * ApplicationInfo.ratio
                            sourceSize.height: 88  * ApplicationInfo.ratio
                            source: ApplicationInfo.magazineListModel.getCachedImageUrl(imageUrl)
                        }

                        Item
                        {
                            implicitWidth: ApplicationInfo.hMargin
                            Layout.minimumWidth: implicitWidth
                        }

                        Label
                        {
                            text: magazine
                            font.family: ApplicationInfo.theme.primaryFont
                            font.pixelSize: 42 * ApplicationInfo.ratio
                            Layout.alignment: Qt.AlignBaseline
                            color: ApplicationInfo.theme.bodyBackgroundColor
                        }

                        Item
                        {
                            Layout.fillWidth: true
                        }

                        Image
                        {
                            id: viewButton
                            source: ApplicationInfo.getAsset("view.png")
                            Layout.preferredWidth: 120 * ApplicationInfo.ratio
                            Layout.preferredHeight: 120 * ApplicationInfo.ratio
                            visible: row.hasPdf
                        }

                        Image
                        {
                            id: downloadButton
                            source: ApplicationInfo.getAsset("download.png")
                            Layout.preferredWidth: 120 * ApplicationInfo.ratio
                            Layout.preferredHeight: 120 * ApplicationInfo.ratio
                            visible: !row.hasPdf
                        }

                        Item
                        {
                            implicitWidth: 12 * ApplicationInfo.ratio
                            Layout.minimumWidth: implicitWidth
                        }
                    }
                }
            }
        }
    }
}
