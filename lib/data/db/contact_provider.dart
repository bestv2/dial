import 'dart:convert';

import 'package:dial/data/db/db_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/history.dart';
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
      Column(name: 'bg', type: 'string'),
    ];
  }
  save(Contact contact) async {
    Database db = await getDatabase();
    // map.update(columnId, (value) => DateTime.now().millisecondsSinceEpoch);
    var exist =
        await db.rawQuery('select * from contact where id = ?', [contact.id]);
    // print(exist);
    if (exist.isEmpty) {
      await db.insert(tableName, contact.toMap());
    } else {
      var existContact = exist[0];
      if (existContact["firstName"] != contact.firstName ||
          existContact["lastName"] != contact.lastName ||
          existContact["phoneNumbers"] != jsonEncode(contact.phoneNumbers)) {
            contact.firstName = existContact["firstName"];
            contact.lastName = existContact["lastName"];
            List numbers = jsonDecode(existContact["phoneNumbers"]);
            contact.phoneNumbers = numbers.map((e) => PhoneNumber.fromJSON(e));
            db.update(tableName, contact.toMap());
          }
    }
  }
}
