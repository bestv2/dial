import 'package:dial/data/bus.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/dial_item.dart';
import 'package:dial/model/history.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class DialItems with ChangeNotifier {
  DialItems() {
    // getContacts();
    loadContacts();
  }
  List<Contact> contacts = <Contact>[];
  List<History> histories = <History>[];
  List<DialItem> dialItems = <DialItem>[];

  String dialed = "";

  /// 获取通讯录列表
  ///
  /// return list[Contact]。
  Future<List> loadContacts() async {
    // Map<Permission, PermissionStatus> statuses = await [
    //   Permission.contacts,
    // ].request();
    // print(statuses[Permission.contacts]);
    // var status = await Permission.contacts.status;
    // print(status);
    // if (status.isUndetermined) {
    //   // We didn't ask for permission yet.
    // }
    // await Permission.contacts.request().isGranted;
    // final List result = await _channel.invokeMethod('getContacts');
    final List result = await DataBus.getDeviceContacts();
    if (result != null) {
      result.forEach((element) {
        Contact contact = Contact.fromJson(element);
        contacts.add(contact);
        DialItem dialItem = DialItem.fromContact(contact);
        dialItems.add(dialItem);
        // contacts.add(LinkMan.fromJson(element));
      });
      notifyListeners();
    }
    return contacts;
  }

  load() {}

  input(String value) {
    if (value == 'del') {
      dialed = dialed.substring(0, dialed.length - 2);
    } else if (value != '') {
      dialed += value;
    }
  }
}
