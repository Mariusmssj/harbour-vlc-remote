#include "playlistmodel.h"

PlaylistModel::PlaylistModel():QAbstractListModel()
{
m_manager = new QNetworkAccessManager();
m_handler = new Handler();
connect(m_handler,&Handler::itemFound,this,&PlaylistModel::addXmlItem);
connect(m_handler,&Handler::mEndDocument,[this] {
    QModelIndex m = QModelIndex();
    dataItems.count();
    insertRows(0,dataItems.count(),m);
});
connect(m_manager,&QNetworkAccessManager::finished,this,&PlaylistModel::requestReceived);
connect(m_manager,&QNetworkAccessManager::authenticationRequired,this,&PlaylistModel::authenticate);
connect(this,&PlaylistModel::searchChanged,[this]() {


    m_proxyModel->setFilterRegExp(QRegExp(search(), Qt::CaseInsensitive));

;

});
        m_proxyModel = new QSortFilterProxyModel(this);
        m_proxyModel->setFilterRole(NameRole);
        m_proxyModel->setSourceModel(this);
        connect(this,&PlaylistModel::remoteUrlChanged,this,&PlaylistModel::fetchFromUrl);


}
void PlaylistModel::update() {
    beginRemoveRows(QModelIndex(),0,dataItems.count());
    dataItems.clear();
    endRemoveRows();
    fetchFromUrl();
}
void PlaylistModel::fetchFromUrl()
{
    m_manager->get(QNetworkRequest(QUrl("http://"+m_remoteUrl+"/requests/playlist.xml").toString()));
}
bool PlaylistModel::insertRows(int row, int count, const QModelIndex &parent)
{
    beginInsertRows(parent, row, row + count - 1);
    endInsertRows();
    return true;
}
void PlaylistModel::updateCurrent(QString id)
{
    QModelIndexList prev = match(index(0,0),CurrentRole,QVariant::fromValue(QStringLiteral("current")),1,Qt::MatchFlags(Qt::MatchFixedString));

    if(prev.count()>0) {
        if(setData(prev[0],QVariant::fromValue(QStringLiteral("")),CurrentRole)) {
            emit dataChanged(prev[0],prev[0],QVector<int> { CurrentRole});
        }
    }
    QModelIndexList idx = match(index(0,0),IdRole,QVariant::fromValue(id),1,Qt::MatchFlags(Qt::MatchFixedString));
    if(setData(idx[0],QVariant::fromValue(QStringLiteral("current")),CurrentRole)) {
        emit dataChanged(idx[0],idx[0],QVector<int> { CurrentRole});

    }

}
Qt::ItemFlags PlaylistModel::flags(const QModelIndex &index) const {
    return QAbstractListModel::flags(index) | Qt::ItemIsEditable;
}
bool PlaylistModel::setData(const QModelIndex &index, const QVariant &value, int role) {
    bool ret = false;
    switch(role) {
        case CurrentRole:  {
            dataItems[index.row()].current=QString(value.toString());
            ret = true;
            break;
        }
    default:
        qDebug() << "Cannot set data for role: " << role;
    }
    return ret;
}
void PlaylistModel::remove(QString id)
{
    QModelIndexList idx = match(index(0,0),IdRole,QVariant::fromValue(id),1,Qt::MatchFlags(Qt::MatchFixedString));

    beginRemoveRows(QModelIndex(),idx[0].row(),idx[0].row());
    dataItems.removeAt(idx[0].row());
    endRemoveRows();

}
bool PlaylistModel::addXmlItem(DataItem *item)
{
dataItems.append(*item);
return true;
}
QHash<int,QByteArray> PlaylistModel::roleNames() const {
    QHash<int, QByteArray> roles;
        roles[NameRole] = "name";
        roles[IdRole] = "id";
        roles[CurrentRole] = "current";
    return roles;
}
void PlaylistModel::authenticate(QNetworkReply* reply,QAuthenticator* authenticator) {
    Q_UNUSED(reply);
    authenticator->setUser(username());
    authenticator->setPassword(password());
    //Only try one time since settings does not change
    disconnect(m_manager,&QNetworkAccessManager::authenticationRequired,this,&PlaylistModel::authenticate);
}
void PlaylistModel::requestReceived(QNetworkReply*reply) {
    if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt()==401) {
        DataItem *item = new DataItem;
        item->name="Authentication error, check settings";
        item->id="-1";
        dataItems.append(*item);
        insertRows(0,1,QModelIndex());
        return;
    }
    QXmlInputSource *xInSrc = new QXmlInputSource();
    xInSrc->setData(reply->readAll());
    QXmlSimpleReader *reader = new QXmlSimpleReader();

    reader->setContentHandler(m_handler);
    reader->setErrorHandler(m_handler);
    reader->parse(xInSrc);
}
QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    QString ret = "";
    switch(role) {
        case NameRole:{
            ret = dataItems.at(index.row()).name;
            break;
        }
    case IdRole:{
        ret = dataItems.at(index.row()).id;
        break;
    }
    case CurrentRole:{
        ret = dataItems.at(index.row()).current;
        break;
    }
    }
    return ret;
}
int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return dataItems.size();

}
