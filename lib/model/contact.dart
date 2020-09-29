import 'package:dial/enum/match_type.dart';
import 'package:dial/utils/style.dart';
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
  int bg;

  List<PhoneNumber> phoneNumbers;

  PhoneNumber getDefault() {
    var defaultNumbers = phoneNumbers.where((element) {
      return element.isDefault;
    });
    return defaultNumbers.isEmpty
        ? (phoneNumbers.isEmpty ? null : phoneNumbers[0])
        : defaultNumbers.first;
  }

  Contact.fromJson(Map json, {bool newColor = false}) {
    firstName = json["firstName"].toString();
    lastName = json["lastName"].toString();
    id = json["identifier"];
    bg = newColor != null && newColor ? AppColor.randomColor().value : json["bg"];
    phoneNumbers = [];
    var phoneNumbersJson = json["phoneNumbers"] is String
        ? jsonDecode(json["phoneNumbers"])
        : json["phoneNumbers"];
    for (var phoneNumber in phoneNumbersJson) {
      phoneNumbers.add(PhoneNumber(
          number: phoneNumber["value"] ?? phoneNumber["number"],
          type: phoneNumber["label"]));
    }
  }

  @override
  String toString() {
    return toMap().toString();
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
