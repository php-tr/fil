#ifndef MAGAZINEMODEL_H
#define MAGAZINEMODEL_H

#include <QObject>
#include <QtQml/qqml.h>
#include <QtCore/QModelIndex>
#include <QtCore/QDateTime>

class MagazineModel : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int id READ getId CONSTANT)
    Q_PROPERTY(bool isPdfDownloaded READ getIsPdfDownloaded NOTIFY isPdfDownloadedChanged)

public:
    struct MagazineDataStructure
    {
        int id;
        QString name;
        QString imageUrl;
        QString pdfUrl;
        qulonglong fileSize;
        QDateTime releaseDate;
        bool isPdfDownloaded;
        bool isNew;
        QString pdfPath;
    };

    enum
    {
        IdRole = Qt::UserRole + 1,
        NameRole = Qt::UserRole + 2,
        ImageUrlRole = Qt::UserRole + 3,
        PdfUrlRole = Qt::UserRole + 4,
        ReleaseDateRole = Qt::UserRole + 5,
        FileSizeRole = Qt::UserRole + 6,
        NewRole = Qt::UserRole + 7,
        PdfPath = Qt::UserRole + 8
    };

    explicit MagazineModel(QObject *parent = 0);

    // QVariant data(const QModelIndex &index, int role = Qt::DisplayRole);
    // QHash<int, QByteArray> roleNames() const;

    void setData(int id, QString name, QString imageUrl, QString pdfUrl, qulonglong fileSize, QDateTime releaseDate, bool isNew, QString pdfPath = QString());
    void setPdfPath(QString pdfPath);
    QVariant getData(QString prop);
    bool getIsPdfDownloaded();
    int getId();

Q_SIGNALS:
    void isPdfDownloadedChanged();

public Q_SLOTS:


private:
    MagazineDataStructure _data;
};

QML_DECLARE_TYPE(MagazineModel);

#endif // MAGAZINEMODEL_H
