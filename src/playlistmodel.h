#ifndef PLAYLISTMODEL_H
#define PLAYLISTMODEL_H
#include <QStringListModel>
#include "qdebug.h"
#include <QNetworkAccessManager>
#include <QUrl>
#include <QString>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QAuthenticator>
#include <QtXml/QXmlSimpleReader>
#include <QtXml/QXmlInputSource>
#include <QSortFilterProxyModel>
#include "handler.h"
class PlaylistModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum PlaylistRoles {
        NameRole = Qt::UserRole + 1,
       IdRole,
        CurrentRole
};
    Q_PROPERTY(QString search READ search WRITE setSearch NOTIFY searchChanged)
    void setSearch(const QString &s) {
          if (s != m_search) {
              m_search = s;
              emit searchChanged();
          }
      }
    Q_INVOKABLE void update();
    Q_INVOKABLE void remove(QString id);
    Q_INVOKABLE void updateCurrent(QString id);
    Q_PROPERTY(QSortFilterProxyModel* proxyModel READ proxyModel NOTIFY proxyModelChanged)
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString remoteUrl READ remoteUrl WRITE setRemoteUrl NOTIFY remoteUrlChanged)

    void setUsername(const QString &u) {
        if (u != m_username) {
            m_username = u;
            emit usernameChanged();
        }
    }
    QString username() {
        return m_username;
    }
    void setPassword(const QString &p) {

          if (p != m_password) {
              m_password = p;
              emit passwordChanged();
          }
      }
    void setRemoteUrl(const QString &u) {
        if (u != m_remoteUrl) {
            m_remoteUrl = u;
            emit remoteUrlChanged();
        }
    }
    QString search() const {
        return m_search;
    }
    QString password() const {
        return m_password;
    }
    QString remoteUrl() {
        return m_remoteUrl;
    }
    QSortFilterProxyModel* proxyModel() const {
        return m_proxyModel;
    }
    bool insertRows(int row, int count, const QModelIndex &parent);
    QHash<int, QByteArray> roleNames() const;
    PlaylistModel();
    QVariant data(const QModelIndex &index, int role) const;
    int rowCount(const QModelIndex &parent) const;
signals:
    void passwordChanged();
    void searchChanged();
    void proxyModelChanged();
    void remoteUrlChanged();
    void usernameChanged();
public slots:
    bool addXmlItem(DataItem *item);
    void requestReceived(QNetworkReply* reply);
    void authenticate(QNetworkReply*reply, QAuthenticator *authenticator);
    void fetchFromUrl();
private:
    Qt::ItemFlags flags(const QModelIndex &index) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);
    QNetworkAccessManager *m_manager;
    QList<DataItem> dataItems;
    QString m_password;
    QString m_search;
    QString m_remoteUrl;
    QString m_username;
    Handler *m_handler;

    QSortFilterProxyModel *m_proxyModel;
};

#endif // PLAYLISTMODEL_H
