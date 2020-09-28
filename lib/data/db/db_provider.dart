import 'package:dial/data/db/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  bool isTabaleExist = false;
  String tableName = 'base';
  String columnId = '_id';
  List<Column> columns = [];
  Future<Database> getDatabase() async {
    Database db = await DbManager.getCurrentDatabase();
    List dbColumns = await DbManager.getColumns(tableName);
    if (!await DbManager.isTableExists(tableName)) {
      await db.execute(tableCreateSql());
    }
    // print(dbColumns);
    bool allField = true;
    columns.forEach((column) {
      if (allField)
        allField = dbColumns.any((dbColumn) => dbColumn['name'] == column.name);
    });
    if (!allField) {
      await db.execute("DROP TABLE IF EXISTS $tableName");
      await db.execute(tableCreateSql());
    }
    return db;
  }

  String tableCreateSql() {
    String columnsSql = columns.fold('', (previousValue, element) {
      return '''
        $previousValue
        ${element.name} ${element.type},
      ''';
    });
    return '''
      create table $tableName (
        $columnsSql
        $columnId integer primary key autoincrement
      )
    ''';
  }
}

class Column {
  String name;
  String type;
  Column({this.name, this.type});
}
