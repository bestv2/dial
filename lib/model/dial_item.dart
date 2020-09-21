import 'dart:ui';

import 'package:dial/model/history.dart';
import 'package:dial/utils/style.dart';
import 'package:lpinyin/lpinyin.dart';

import 'contact.dart';

class DialItem {
  String phoneNumber;
  String name;
  String shortName;
  Contact contact;
  History history;
  List<String> nameArr = [];
  List<String> namePinyinArr = [];
  bool isEn = true;
  // rank时候初始化属性 begin
  String hitedNumber;
  List<int> nameHited = [];
  List<int> numberHited = [];
  // rank时候初始化属性 end
  Color bg;
  double score = 0;
  DateTime time;

  static var numberLetterMap = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ'
  };

  DialItem({
    this.phoneNumber,
    this.name,
    this.contact,
    this.history,
  });

  void format() {
    bg = AppColor.randomColor();
    var enReg = RegExp(r"[A-Za-z]");
    var cnReg = RegExp(r"[^\x00-\xff]");
    String firstName = contact?.firstName;
    String lastName = contact?.lastName;
    phoneNumber = contact?.getDefault()?.number ?? (phoneNumber ?? '无号码');
    isEn = !cnReg.hasMatch("${firstName ?? ''}${lastName ?? ''}");
    if (isEn) {
      if (contact != null) {
        name = "${firstName ?? ''} ${lastName ?? ''}";
        if (RegExp(r"^\s*$").hasMatch(name)) name = '';
      }
      // if (cnReg.hasMatch(firstName)) {
      //   firstName.replaceAllMapped(
      //       cnReg, (Match match) => PinyinHelper.getPinyin(match.toString()));
      // }
      // if (cnReg.hasMatch(lastName)) {
      //   lastName.replaceAllMapped(
      //       cnReg, (Match match) => PinyinHelper.getPinyin(match.toString()));
      // }
      namePinyinArr.add(firstName);
      namePinyinArr.add(lastName);
      nameArr.add(firstName);
      nameArr.add(lastName);
      shortName = firstName != null ? firstName.replaceAll(cnReg, '') : '';
      if (shortName.length > 4) {
        shortName = shortName.substring(0, 4);
      }
    } else {
      if (contact != null) {
        name = "${lastName ?? ''}${firstName ?? ''}";
      }
      for (var nameIndex = 0; nameIndex < name.length; nameIndex++) {
        namePinyinArr.add(PinyinHelper.getPinyin(name[nameIndex]));
        nameArr.add(name[nameIndex]);
      }
      shortName =
          name.length > 2 ? name.substring(name.length - 2, name.length) : name;
    }
    if (name == null) {
      name = '';
    }
    if (shortName == null || shortName.isEmpty) {
      shortName = '-';
    }
    // print(namePinyinArr);
  }

  bool isSaved() {
    return this.contact != null;
  }

  double rankName(String numbers, {bool combo = true}) {
    double baseRankScore = 0.0;
    // 姓名匹配
    int numberIndex = 0;
    int nameIndex = 0;
    int letterIndex = 0;
    int lastNameIndex = -1, lastLetterIndex = -1;
    // 相邻算法
    // numbers游标递进不相邻算法
    for (; numberIndex < numbers.length; numberIndex++) {
      String number = numbers[numberIndex];
      bool numberFound = false;
      while (!numberFound && nameIndex < namePinyinArr.length) {
        String name =
            namePinyinArr[nameIndex] != null ? namePinyinArr[nameIndex] : '';
        if (name != null && name.isNotEmpty) {
          String letter = name[letterIndex];
          if (numberLetterMap[number] != null &&
              numberLetterMap[number].indexOf(letter.toUpperCase()) > -1) {
            // 当前位置匹配
            if (nameHited.indexOf(nameIndex) == -1) {
              nameHited.add(nameIndex);
            }
            // 每次命中基础增加10分， 同单词同时命中 - 0， 夸词汇 - d,如果跨的是首字 - d / 2
            score += 10 +
                (lastNameIndex - nameIndex) * (lastNameIndex == -1 ? .5 : 1);
            lastNameIndex = nameIndex;
            lastLetterIndex = letterIndex;
            numberFound = true;
          }
        }
        // jump
        if (letterIndex < name.length - 1 && numberFound) {
          letterIndex++;
        } else {
          if (combo && nameHited.isNotEmpty && nameHited.last != nameIndex) {
            nameIndex = nameHited.first + 1;
            nameHited = [];
            letterIndex = 0;
            numberFound = false;
          } else {
            nameIndex++;
            letterIndex = 0;
          }
        }
      }
      // print("nameIndex:$nameIndex,letterIndex:$letterIndex,numberFound:$numberFound");
      if (!numberFound) {
        // name遍历结束未找到
        // print("not found ,${numberIndex.toDouble()} $phoneNumbers");
        score = baseRankScore; // 未找到得分清零
        numberHited = [];
        nameHited = [];
        return score;
      }
    }
    // 最终找到
    score += nameHited.length / nameArr.length * 5;
    score += baseRankScore;
    return score;
  }

  double rank(String numbers) {
    score = 0;
    numberHited = [];
    nameHited = [];
    if (numbers == null || numbers.isEmpty) return score;
    double baseRankScore = 0.0;

    if (contact == null) {
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        var hitedNumberIndex = phoneNumber.indexOf(numbers);
        if (hitedNumberIndex > -1) {
          // 命中
          hitedNumber = phoneNumber;
          score = baseRankScore;
          score += numbers.length / phoneNumber.length * 10;
          var endIndex = hitedNumberIndex + numbers.length;
          for (; hitedNumberIndex < endIndex; hitedNumberIndex++) {
            numberHited.add(hitedNumberIndex);
          }
          // print(numberHited);
          return score;
        }
      }
    } else {
      var phoneNumbers = contact?.phoneNumbers;

      var matched =
          phoneNumbers?.any((element) => element.number.indexOf(numbers) > -1);

      if (matched) {
        var matchedPhoneNumber = phoneNumbers
            ?.firstWhere((element) => element.number.indexOf(numbers) > -1);
        // 命中
        var hitedNumberIndex = matchedPhoneNumber.number.indexOf(numbers);
        hitedNumber = matchedPhoneNumber.number;
        phoneNumber = hitedNumber;
        score = baseRankScore + 10; // 通讯录优先级？
        var endIndex = hitedNumberIndex + numbers.length;
        for (; hitedNumberIndex < endIndex; hitedNumberIndex++) {
          numberHited.add(hitedNumberIndex);
        }
        // print(numberHited);
        return score;
      }
    }
    var score1 = rankName(numbers);
    return score1 > baseRankScore ? score1 : rankName(numbers, combo: false);
  }

  DialItem.fromJson(Map json) {
    name = json['name']?.toString() ?? '';
    phoneNumber = json['phoneNumber'].toString();
    if (json['startAt'] != null && json['startAt'] != '') {
      time = DateTime.parse(json['startAt']);
    }
    format();
  }

  DialItem.fromContact(Contact con) {
    contact = con;
    format();
  }
  @override
  String toString() {
    return {phoneNumber, name, contact, history}.toString();
  }
}
