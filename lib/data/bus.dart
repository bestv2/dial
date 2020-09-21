import 'package:dial/data/db/contact_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class DataBus {
  static const MethodChannel _channel =
      const MethodChannel('dial.flutter.io/contacts');

  static Contact _toContact(element) {
    Contact contact = Contact.fromJson(element);
    ContactProvider cp = ContactProvider();
    cp.save(contact);
    return contact;
  }

  static Future<List<Contact>> getDeviceContacts() async {
    // print(DateTime.now());
    var status = await Permission.contacts.status;
    // print(status);
    if (status.isUndetermined) {
      // We didn't ask for permission yet.
    }
    await Permission.contacts.request().isGranted;
    final List result = await _channel.invokeMethod('getContacts');
    return result.map((element) => _toContact(element)).toList();
  }
}

class DataBusCahce {
  static getData(Function dataFunc, String cacheKey) async {
    var data = await dataFunc();
  }
}
