import 'package:dial/common/event/index.dart';
import 'package:dial/data/bus.dart';
import 'package:dial/data/db/history_provider.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/dial_item.dart';
import 'package:dial/model/history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_state/flutter_phone_state.dart';
import 'dart:async';

class HomeModel with ChangeNotifier {
  HomeModel() {
    // getContacts();
    loadContacts();
  }
  List<Contact> contacts = <Contact>[];
  List<History> histories = <History>[];
  List<DialItem> dialItems = <DialItem>[];

  String dialed = "";
  DialItem addNumberToList(String phoneNumber, {String startAt}) {
    var index = dialItems
        .indexWhere(((dialItem) => dialItem.phoneNumber == phoneNumber));
    DialItem item;
    if (index != -1) {
      item = dialItems[index];
      dialItems.removeAt(index);
    } else {
      item = DialItem.fromJson({"phoneNumber": phoneNumber});
    }
    if (startAt != null && startAt != '') {
      item.time = DateTime.parse(startAt);
    }
    dialItems.insert(0, item);
    return item;
  }

  loadTestData() {
    // dialItems.add(DialItem.fromJson({"name": "秋丽飞", "phoneNumber": "13312341234"}));
    // dialItems.add(DialItem.fromJson({"name": "李茹菲", "phoneNumber": "13588994455"}));
    // dialItems.add(DialItem.fromJson({"name": "妈", "phoneNumber": "18896565456"}));
    // dialItems.add(DialItem.fromJson({"name": "姐姐", "phoneNumber": "16677221133"}));
    // dialItems.add(DialItem.fromJson({"name": "李崖城", "phoneNumber": "15566451245"}));

    // dialItems.add(DialItem.fromContact(Contact.fromJson({
    //   "firstName": "丽飞",
    //   "lastName": "秋",
    //   "phoneNumbers": [
    //     {"value": "13312341234", "label": ""}
    //   ]
    // })));
    // dialItems.add(DialItem.fromContact(Contact.fromJson({
    //   "firstName": "爸爸",
    //   "lastName": "秋",
    //   "phoneNumbers": [
    //     {"value": "13232341234", "label": ""}
    //   ]
    // })));
    // dialItems.add(DialItem.fromContact(Contact.fromJson({
    //   "firstName": "妈",
    //   "lastName": "",
    //   "phoneNumbers": [
    //     {"value": "18896565456", "label": ""}
    //   ]
    // })));
    // dialItems.add(DialItem.fromContact(Contact.fromJson({
    //   "firstName": "姐",
    //   "lastName": "姐姐",
    //   "phoneNumbers": [
    //     {"value": "16677221133", "label": ""}
    //   ]
    // })));
    dialItems.add(DialItem.fromContact(Contact.fromJson({
      "firstName": "姑妈",
      "lastName": "源心",
      "phoneNumbers": [
        {"value": "13312341234", "label": ""}
      ]
    })));
  }

  /// 获取通讯录列表
  ///
  /// return list[Contact]。
  Future<List> loadContacts() async {
    final List<Contact> result = await DataBus.getDeviceContacts();
    if (result != null) {
      result.forEach((Contact contact) {
        contacts.add(contact);
        DialItem dialItem = DialItem.fromContact(contact);
        dialItems.add(dialItem);
      });
      // loadTestData();
      dialItems.sort((left, right) => left.compareTo(right));
    }
    HistoryProvider provider = HistoryProvider();
    var historys = await provider.getData();
    if (histories != null) {
      historys.reversed.forEach((historyJson) {
        String phoneNumber = historyJson["phoneNumber"].toString();
        addNumberToList(phoneNumber, startAt: historyJson["startAt"]);
      });
    }
    notifyListeners();
    return contacts;
  }

  dial(String phoneNumber) async {
    final phoneCall = FlutterPhoneState.startPhoneCall(phoneNumber);
    await phoneCall.eventStream.forEach((PhoneCallEvent event) {
      if (event.status == PhoneCallStatus.connecting) {
        addHistory(phoneNumber);
      }
    });
    print("Call is complete");
  }

  addHistory(String phoneNumber) {
    DateTime time = DateTime.now();
    DialItem dialItem = addNumberToList(phoneNumber, startAt: time.toString());
    History history = History(phoneNumber: dialItem.phoneNumber, startAt: time);
    HistoryProvider provider = HistoryProvider();
    provider.insert(history);
    input('reset');
  }

  deleteHistory(String phoneNumber) {
    int index =
        dialItems.indexWhere((element) => element.phoneNumber == phoneNumber);
    if (index != -1) {
      dialItems.removeAt(index);
    }
    HistoryProvider provider = HistoryProvider();
    provider.delete(phoneNumber);
    notifyListeners();
  }

  input(String value) {
    var from = dialed;
    if (value == 'reset') {
      dialed = '';
    } else if (value == 'del') {
      if (dialed != '')
        dialed = dialed.substring(0, dialed.length - 1);
      else
        return;
    } else if (value != '') {
      dialed += value;
    }
    // if (old == '' && dialed != '') {
    //   eventBus.fire(new HolderEvent(true));
    // } else if (old != '' && dialed == '') {
    //   eventBus.fire(new HolderEvent(false));
    // }
    dialItems.forEach((element) {
      element.rank(dialed);
    });
    if (dialed.isEmpty) {
      dialItems.sort((left, right) => left.compareTo(right));
    } else {
      dialItems.sort((left, right) => left.compareTo(right, withScore: true));
    }
    eventBus.fire(DataEventHome(from: from, to: dialed));
    notifyListeners();
  }
}
