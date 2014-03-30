//db.js
.import QtQuick.LocalStorage 2.0 as Sql

function getSettings()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection settings", 1);

    //create table
    db.transaction(function(tx)
    {
        var query = "CREATE TABLE IF NOT EXISTS Settings2(HomePath varchar(255) DEFAULT 'file:///')";
        tx.executeSql(query);
    });
    return db;
}

function cleanDb()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection Settings", 1);
    db.transaction(
                function(tx) {
                    tx.executeSql("DROP TABLE IF EXISTS Settings2");
                }
                );
}

function deleteTable()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection Settings", 1);
    db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM Settings2");
                }
                );
}
