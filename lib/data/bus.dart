import 'package:dial/data/db/contact_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class DataBus {
  static const MethodChannel _channel =
      const MethodChannel('dial.flutter.io/contacts');

  static Future<List<Contact>> getDeviceContactsFromDevice({bool first}) async {
    var status = await Permission.contacts.status;
    // print(status);
    if (status.isUndetermined) {
      // We didn't ask for permission yet.
    }
    await Permission.contacts.request().isGranted;
    final List result = await _channel.invokeMethod('getContacts');
    final List<Contact> contacts = [];
    ContactProvider cp = ContactProvider();
    // await cp.drop();
    result.forEach((element) async {
      final Contact contact = Contact.fromJson(element, newColor: first);
      cp.save(contact);
      contacts.add(contact);
    });
    return contacts;
  }

  static Future<List<Contact>> getDeviceContacts() async {
    ContactProvider cp = ContactProvider();
    // await cp.drop();
    List<Map> result = await cp.getData();
    // print(result);
    if (result.isNotEmpty) {
      var res = result
          .map((element) => Contact.fromJson(element))
          .toList();
      // 第二次加载
      getDeviceContactsFromDevice();
      return res;
    }
    return getDeviceContactsFromDevice(first: true);
    // print(DateTime.now());
  }
}

class DataBusCahce {
  static getData(Function dataFunc, String cacheKey) async {
    var data = await dataFunc();
  }
}
