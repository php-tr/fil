#ifndef CONFIRMBOX_H
#define CONFIRMBOX_H

#include <QQuickItem>

class NativeDialog : public QQuickItem
{
    Q_OBJECT
public:
    explicit NativeDialog(QQuickItem *parent = 0);

    Q_INVOKABLE void confirmDownload(int id);
    int getId();

    static NativeDialog *getInstance()
    {
        return _instance;
    }

Q_SIGNALS:
    void downloadConfirmed(int id);

public Q_SLOTS:


private:
    void *_alertViewDelegate;
    int _id;
    static NativeDialog *_instance;
};

#endif // CONFIRMBOX_H
