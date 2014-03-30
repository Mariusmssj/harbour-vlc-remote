//db.js
.import QtQuick.LocalStorage 2.0 as Sql

function getSettings()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection settings", 1);

    //create table
    db.transaction(function(tx)
    {
        var query = 'CREATE TABLE IF NOT EXISTS Settings1(IP TEXT, Port TEXT, Username TEXT, Password TEXT, Sync TEXT)';
        tx.executeSql(query);
    });
    return db;
}

function cleanDb()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection Settings", 1);
    db.transaction(
                function(tx) {
                    tx.executeSql("DROP TABLE IF EXISTS Settings1");
                }
                );
}

function deleteTable()
{
    var db = Sql.LocalStorage.openDatabaseSync("UserSettings", "1.0", "Stores user conection Settings", 1);
    db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM Settings1");
                }
                );
}
