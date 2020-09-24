import 'package:dial/enum/match_type.dart';
import 'package:lpinyin/lpinyin.dart';
import 'dart:convert' show jsonDecode, jsonEncode;


class Contact {
  Contact({firstName, lastName, phoneNumber, id, bg}) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    phoneNumbers = [];
    phoneNumbers.add(PhoneNumber(number: phoneNumber));
  }
  String id;
  String firstName;
  String lastName;
  String bg;

  List<PhoneNumber> phoneNumbers;

  PhoneNumber getDefault() {
    var defaultNumbers = phoneNumbers.where((element) {
      return element.isDefault;
    });
    // print(defaultNumbers.isEmpty ? phoneNumbers[0] : defaultNumbers.first);
    return defaultNumbers.isEmpty
        ? (phoneNumbers.isEmpty ? null : phoneNumbers[0])
        : defaultNumbers.first;
  }

  Contact.fromJson(Map json) {
    firstName = json["firstName"];
    lastName = json["lastName"];
    id = json["identifier"];
    phoneNumbers = [];
    for (var phoneNumber in json["phoneNumbers"]) {
      phoneNumbers.add(PhoneNumber(
          number: phoneNumber["value"], type: phoneNumber["label"]));
    }
  }

  @override
  String toString() {
    return {firstName, lastName, phoneNumbers, id, bg}.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'id': id,
      'bg': bg,
       'phoneNumbers': jsonEncode(phoneNumbers),
    };
  }
  Map toJson() {
    print('contact to json');
    return toMap();
  }
}

class PhoneNumber {
  PhoneNumber({this.isDefault = true, this.number, this.type});
  bool isDefault;
  String number;
  String type;

  Map toJson() {
    Map map = new Map();
    map["isDefault"] = this.isDefault;
    map["number"] = this.number;
    map["type"] = this.type;
    return map;
  }
  @override
  String toString() {
    // TODO: implement toString
    return {number, type, isDefault}.toString();
  }
  PhoneNumber.fromJSON(Map map) {
    isDefault = map["isDefault"];
    number = map["number"];
    type = map["type"];
  }
}
