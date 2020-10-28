import 'package:dial/common/event/index.dart';
import 'package:dial/common/log/logger.dart';
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
    wLog('model home init');
    loadContacts();
  }
  List<Contact> contacts = <Contact>[];
  List<History> histories = <History>[];
  List<DialItem> dialItems = <DialItem>[];

  String dialed = "";
  DialItem addHistoryToList(History history) {
    var index = dialItems.indexWhere(
        ((dialItem) => dialItem.phoneNumber == history.phoneNumber));
    DialItem item;
    if (index != -1) {
      item = dialItems[index];
      dialItems.removeAt(index);
      item.time = history.startAt;
    } else {
      item = DialItem.fromHistory(history);
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
    wLog('lodaContacts');
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
        History history = History(
            bg: historyJson['bg'],
            phoneNumber: historyJson["phoneNumber"].toString(),
            startAt: DateTime.parse(historyJson["startAt"]));
        addHistoryToList(
          history,
        );
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
    // addHistory(phoneNumber);
    // print("Call is complete");
  }

  save(Contact contact) async {
   return await DataBus.addContact(contact); 
  }

  addHistory(String phoneNumber) {
    DateTime time = DateTime.now();
    History history = History(phoneNumber: phoneNumber, startAt: time);
    addHistoryToList(history);
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
