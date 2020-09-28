import 'dart:convert';

import 'package:dial/data/db/db_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/history.dart';
import 'package:dial/utils/style.dart';
import 'package:sqflite/sqflite.dart';

class ContactProvider extends DbProvider {
  ContactProvider() {
    tableName = 'contact';
    columns = [
      Column(name: 'id', type: 'string'),
      Column(name: 'avatar', type: 'string'),
      Column(name: 'firstName', type: 'string'),
      Column(name: 'lastName', type: 'string'),
      Column(name: 'phoneNumbers', type: 'string'),
      Column(name: 'bg', type: 'integer'),
    ];
  }
  Future<List<Map>> getData() async {
    Database db = await getDatabase();
    List<Map> result = await db.query(tableName);
    return result;
  }

  save(Contact contact) async {
    Database db = await getDatabase();
    // map.update(columnId, (value) => DateTime.now().millisecondsSinceEpoch);
    var exist = await db
        .rawQuery('select * from $tableName where id = ?', [contact.id]);
    // print(exist);
    // print(contact.toMap());
    if (exist == null || exist.isEmpty) {
      // print(contact.toMap());
      await db.insert(tableName, contact.toMap());
      // print('saved');
    } else {
      var existContact = exist[0];
      if (existContact["firstName"] != contact.firstName ||
          existContact["lastName"] != contact.lastName ||
          // (existContact["bg"] != contact.bg && contact.bg != null) ||
          // existContact["bg"] == null ||
          existContact["phoneNumbers"] != jsonEncode(contact.phoneNumbers)) {
        // print('save update: ${contact.firstName}');
        contact.firstName = existContact["firstName"];
        contact.lastName = existContact["lastName"];
        List numbers = jsonDecode(existContact["phoneNumbers"]);
        contact.phoneNumbers =
            numbers.map((e) => PhoneNumber.fromJSON(e)).toList();
        await db.update(tableName, contact.toMap(),
            where: 'id = ?', whereArgs: [contact.id]);
      }
    }
  }
}
