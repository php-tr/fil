import QtQuick 2.5
import Frame.Mobile 1.0
import Frame.Mobile.Core 1.0
import org.phptr.fil 2.0

Item {
    id: root

    readonly property string pageTAG: 'MagazineModel'
    property ListModel model: ListModel {}
    property string lastError: ''
    readonly property alias inProgress: d.inProgress

    function load() {
        if (d.inProgress)
            return;

        var firstInit = !d.inited;
        d.inProgress = true;
        d.init();
        d.inProgress = false;

        if (firstInit)
            sync();
    }

    function reset() {
        if (d.inProgress)
            return;

        d.inited = false;
        load();
    }

    function sync() {
        if (d.inProgress)
            return;

        d.inProgress = true;
        d.fetchRemote(
            function(data) {
                d.handleSuccess(data);
                d.inProgress = false;
            },
            function(error) {
                d.handleFailed(error);
                d.inProgress = false;
            });
    }

    function setPdfPath(magazineId, pdfPath) {
        try {
            Db.query("
                UPDATE fil_magazine
                SET is_downloaded = 1, pdf_path = ?
                WHERE
                    magazine_id = ?
            ", [pdfPath, magazineId]);

            var data = model.get(d.modelMap[magazineId]);
            data.is_downloaded = 1;
            data.pdf_path = pdfPath;
        } catch (e) {}
    }

    QtObject {
        id: d

        property bool inited: false

        readonly property string apiUrl: 'http://fil.php-tr.com/mobile.php?type=pdf_list&token=iyeO0/tpdSKkpelwO1l1Jd01t2Qvr4nMek3TC43xEYw='
        // readonly property string apiUrl: 'http://localhost/index.php'
        property var modelMap: ({})

        property bool dbInited: false
        property bool inProgress: false

        function init() {
            if (inited)
                return;

            if (!dbInited) {
                try {
                    Db.open({
                        dbName: 'FilDb',
                        version: ApplicationInfo.version,
                        dbVersionScriptPaths: ['qrc:/res/dbpatch']
                    });
                } catch (e) {}

                dbInited = true;
            }

            fillModelWithDb();
            inited = true;
        }

        function fillModelWithDb() {
            model.clear();

            var magazineList = [];
            try {
                magazineList = Db.fetchAll("SELECT * FROM fil_magazine ORDER BY magazine_id DESC");
            } catch (e) {}

            var i = 0;
            var len = magazineList.length;
            var current;
            for (; i < len; i++) {
                current = magazineList[i];
                model.append({
                    magazine_id:   current.magazine_id,
                    name:          current.name,
                    image_url:     current.image_url,
                    pdf_url:       current.pdf_url,
                    pdf_size:      current.pdf_size,
                    pdf_path:      current.pdf_path === null ? '' : current.pdf_path,
                    is_read:       current.is_read,
                    is_downloaded: current.is_downloaded,
                    released_at:   current.released_at,
                    created_at:    current.created_at,
                    updated_at:    current.updated_at
                });
            }

            reIndexModel();
        }

        function fetchRemote(onSuccess, onFailed) {
            var xhr = new XMLHttpRequest();

            xhr.open('GET', apiUrl, true);
            xhr.setRequestHeader('X-MobileAppVersion', ApplicationInfo.version);
            xhr.onreadystatechange = function() {
                if (XMLHttpRequest.DONE !== xhr.readyState)
                    return;

                console.log(pageTAG, 'STATUS:', xhr.status, xhr.responseText, apiUrl);

                try {
                    if (xhr.status < 200 && xhr.status >= 300)
                        throw qsTr('Invalid server response.');

                    var response = xhr.responseText;
                    try {
                        response = JSON.parse(response);
                    } catch (e) {
                        throw qsTr('JSON parse failed with following error: %1').arg(e);
                    }

                    if (!response.security)
                        throw qsTr('Authentation failed: %1').arg(response.message || qsTr('Unkown error'));

                    if (Lang.isFunction(onSuccess))
                        onSuccess(response.response);

                } catch (e) {
                    console.warn(pageTAG, e);
                    if (Lang.isFunction(onFailed))
                        onFailed(e);
                }
            };
            xhr.send();
        }

        function handleSuccess(data) {
            syncModelWithRemoteAPI(data);
        }

        function handleFailed(error) {
            lastError = error;
        }

        function syncModelWithRemoteAPI(data) {
            if (!Lang.isArray(data)) {
                console.warn(pageTAG, 'Invalid data to sync model with remote API:', JSON.stringify(data));
                return;
            }

            var len = data.length;
            var i = len - 1;
            var modelData;
            var current;
            var timestamp = (new Date()).getTime();
            var k = 0;
            var modelLen = model.count;

            for (; i >= 0; i--) {
                current = data[i];
                modelData = null;

                for (k = 0; k < model.count; k++) {
                    if (String(model.get(k).magazine_id) === current.id) {
                        modelData = model.get(k);
                        break;
                    }
                }

                if (modelData === null) {
                    modelData = {
                        magazine_id:   current.id,
                        name:          current.ad,
                        image_url:     current.image,
                        pdf_url:       current.pdf,
                        pdf_size:      current.boyut,
                        pdf_path:      '',
                        is_read:       0,
                        is_downloaded: 0,
                        released_at:   current.tarih,
                        created_at:    timestamp,
                        updated_at:    timestamp
                    };

                    model.insert(0, modelData);
                    try {
                        Db.query("
                            INSERT INTO fil_magazine (magazine_id, name, image_url, pdf_url, pdf_size, pdf_path, is_read, is_downloaded, released_at, updated_at, created_at)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        ", [modelData.magazine_id, modelData.name, modelData.image_url, modelData.pdf_url, modelData.pdf_size, modelData.pdf_path, modelData.is_read,
                            modelData.is_downloaded, modelData.released_at, modelData.updated_at, modelData.created_at]);
                    } catch (e) {}

                } else {
                    modelData = model.get(modelMap[current.id]);
                    modelData.name = current.ad;
                    modelData.is_read = modelData.pdf_url === current.pdf ? modelData.is_read : 0;
                    modelData.is_downloaded = modelData.pdf_url === current.pdf ? modelData.is_downloaded : 0;
                    modelData.pdf_path = modelData.pdf_url === current.pdf ? modelData.pdf_path : '';
                    modelData.image_url = current.image;
                    modelData.pdf_url = current.pdf;
                    modelData.pdf_size = current.boyut;
                    modelData.released_at = current.tarih;
                    modelData.updated_at = timestamp;

                    try {
                        Db.query("
                            UPDATE fil_magazine
                            SET name = ?, image_url = ?, pdf_url = ?, pdf_size = ?, pdf_path = ?, is_read = ?, is_downloaded = ?, released_at = ?, updated_at = ?
                            WHERE
                                magazine_id = ?
                        ", [modelData.name, modelData.image_url, modelData.pdf_url, modelData.pdf_size, modelData.pdf_path, modelData.is_read,
                            modelData.is_downloaded, modelData.released_at, modelData.updated_at, modelData.magazine_id]);
                    } catch (e) {}
                }
            }

            reIndexModel();
        }

        function reIndexModel() {
            modelMap = {};
            var i = 0;
            var len = model.count;
            for (; i < len; i++)
                modelMap[model.get(i).magazine_id] = i;
        }
    }
}
