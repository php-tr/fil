#include "ImageProvider.h"
#include <QDebug>

ImageProvider::ImageProvider() : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage ImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QImage image;
    image.load(id);

    if (requestedSize.width() > 0)
    {
        if (requestedSize.height() > 0)
        {
            image = image.scaled(requestedSize, Qt::KeepAspectRatio);
        }
        else
        {
            image = image.scaledToWidth(requestedSize.width());
        }
    }
    else if (requestedSize.height() > 0)
    {
        image = image.scaledToHeight(requestedSize.height());
    }

    if (size)
    {
        *size = QSize(image.width(), image.height());
    }

    return image;
}
