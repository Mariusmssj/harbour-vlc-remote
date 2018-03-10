#ifndef XMLHANDLER_H
#define XMLHANDLER_H
#include "QtXml/QXmlDefaultHandler"
#include <QDebug>
#include "xmlitem.h"

class Handler : public QObject, public QXmlDefaultHandler
{
    Q_OBJECT

public:
    Handler();
    bool endDocument();
    bool startElement(const QString & namespaceURI, const QString & localName, const QString & qName, const QXmlAttributes & atts);
    bool error(const QXmlParseException & exception);
signals:
    void itemFound(DataItem *item);
    void mEndDocument();
};
#endif // XMLHANDLER_H
