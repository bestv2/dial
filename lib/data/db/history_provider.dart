import 'package:dial/data/db/db_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/history.dart';
import 'package:sqflite/sqflite.dart';

class HistoryProvider extends DbProvider {
  HistoryProvider() {
    tableName = 'history';
    columns = [
      Column(name: 'phoneNumber', type: 'string'),
      Column(name: 'startAt', type: 'datetime'),
    ];
  }
  insert(History history) async {
    Database db = await getDatabase();
    var map = history.toMap();
    // map.update(columnId, (value) => DateTime.now().millisecondsSinceEpoch);
    return await db.insert(tableName, map);
  }

  delete(String phoneNumber) async {
    Database db = await getDatabase();
    // map.update(columnId, (value) => DateTime.now().millisecondsSinceEpoch);
    return await db.delete(tableName, where: "phoneNumber = ?", whereArgs: [phoneNumber]);
  }

  ///获取事件数据
  Future<List> getData() async {
    Database db = await getDatabase();
    List<History> list = new List();
    var res = await db.query(
      tableName,
      // distinct: true,
      columns: ['phoneNumber', 'max(startAt) as startAt'],
      orderBy: 'max(startAt) desc',
      limit: 100,
      groupBy: 'phoneNumber',
    );
    // print(res);
    return res;

    // return list;
  }
}
