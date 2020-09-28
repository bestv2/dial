import 'dart:io';

import 'package:sqflite/sqflite.dart';

class DbManager {
  static const _VERSION = 1;
  static const _NAME = 'dial_app.db';
  static Database _database;

  // 初始化数据库
  static init() async {
    var databasesPath = await getDatabasesPath();
    String databaseName = _NAME;

    String path = '$databasesPath${Platform.isIOS ? "/" : ""}$databaseName';
    _database = await openDatabase(path, version: _VERSION);
  }

  static isTableExists(String tableName) async{
    await getCurrentDatabase();
    var res = await _database.rawQuery("select * from Sqlite_master where type = 'table' and name='$tableName'");
    return res != null && res.length > 0;
  }
  static getColumns(String tableName) async{
    await getCurrentDatabase();
    List res = await _database.query("pragma_table_info('$tableName')");
    return res;
  }

  static getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  static close() async {
    _database?.close();
    _database = null;
  }
}
