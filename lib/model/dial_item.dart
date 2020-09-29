import 'dart:developer';
import 'dart:math';
import 'dart:ui';

import 'package:dial/model/history.dart';
import 'package:dial/utils/style.dart';
import 'package:lpinyin/lpinyin.dart';

import 'contact.dart';

class Scores {
  static final double headLetter = 5;
  static final double tailLetter = 4;
  static final double letter = 3;
  static final double comboWord = 3;
  static final double comboLetter = 3;
  static final double baseRank = 0;
}

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
    if (bg == null && contact != null && contact.bg != null) {
      bg = Color(contact.bg);
    } else if (bg == null) {
      bg = AppColor.randomColor();
    }
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
  }

  bool isSaved() {
    return this.contact != null;
  }

  double rankName(String numbers, {headLetter = false}) {
    headLetter = headLetter == null ? false : headLetter;
    // 姓名匹配
    int numberIndex = 0;
    int nameIndex = 0;
    int letterIndex = 0;
    int lastNameIndex = -1, lastLetterIndex = -1;
    // bool first = false; // 匹配首字母

    // 相邻规则
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
              // 单次首次匹配
              nameHited.add(nameIndex);
              score += Scores.headLetter;
            } else if (letterIndex == name.length - 1) {
              // 尾字母
              score += Scores.tailLetter;
            } else {
              // 普通匹配
              score += Scores.letter;
            }
            if (nameIndex == 0) {
              score += Scores.comboWord;
            } else if (nameIndex == lastNameIndex + 1) {
              score += Scores.comboWord;
            } else if (nameIndex == lastNameIndex &&
                letterIndex == lastLetterIndex + 1) {
              score += Scores.comboLetter;
            }
            // if (this.name == 'xxx') {
            //   print('$name,$lastLetterIndex,l,$letter,$score');
            // }
            lastNameIndex = nameIndex;
            lastLetterIndex = letterIndex;
            numberFound = true;
          }
        }
        // jump
        // 首字母模式直接跳到下个单词
        if (letterIndex < name.length - 1 && numberFound && !headLetter) {
          letterIndex++;
        } else {
          nameIndex++;
          letterIndex = 0;
        }
      }
      if (!numberFound) {
        // name遍历结束未找到
        score = Scores.baseRank; // 未找到得分清零
        numberHited = [];
        nameHited = [];
        return score;
      }
    }
    // 最终找到
    // score += nameHited.length / nameArr.length * 5;
    score += Scores.baseRank;
    return score;
  }

  double rank(String numbers) {
    score = 0;
    numberHited = [];
    nameHited = [];
    if (numbers == null || numbers.isEmpty) return score;

    if (contact == null) {
      //  无通讯录，历史号码匹配
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        var hitedNumberIndex = phoneNumber.indexOf(numbers);
        if (hitedNumberIndex > -1) {
          // 命中
          hitedNumber = phoneNumber;
          score = Scores.baseRank;
          score += numbers.length / phoneNumber.length * 10;
          var endIndex = hitedNumberIndex + numbers.length;
          for (; hitedNumberIndex < endIndex; hitedNumberIndex++) {
            numberHited.add(hitedNumberIndex);
          }
          return score;
        }
      }
    } else {
      // 有通讯录优先匹配名字
      // 首字母模式和非首字母模式
      var headScore = rankName(numbers, headLetter: true);
      var score = headScore > Scores.baseRank
          ? headScore
          : rankName(numbers, headLetter: false);
      if (score > Scores.baseRank) return score;

      // 名字未匹配，检查号码时候匹配
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
        score = Scores.baseRank + 10; // 通讯录优先级？
        var endIndex = hitedNumberIndex + numbers.length;
        for (; hitedNumberIndex < endIndex; hitedNumberIndex++) {
          numberHited.add(hitedNumberIndex);
        }
        return score;
      }
    }
    return Scores.baseRank;
  }

  String getSuspensionTag() {
    if (namePinyinArr.isNotEmpty && namePinyinArr[0].isNotEmpty) {
      var leteter = namePinyinArr[0][0].toString().toUpperCase();
      return RegExp(r"^[A-Z]$").hasMatch(leteter) ? leteter : '#';
    }
    return '#';
  }

  int compareTo(DialItem right, {bool withScore = false}) {
    DialItem left = this;
    // 分数降序
    if (withScore != null &&
        withScore &&
        right.score.compareTo(left.score) != 0)
      return right.score.compareTo(left.score);
    if (left.time != null && right.time == null) {
      // 有时间的在前
      return -1;
    } else if (left.time == null && right.time != null) {
      return 1;
    }
    if (left.time != null &&
        right.time != null &&
        left.time.compareTo(right.time) != 0) {
      // 时间降序
      return right.time.compareTo(left.time);
    }
    return getSuspensionTag() == '#'
        ? 1
        : (right.getSuspensionTag() == '#'
            ? -1
            : getSuspensionTag().compareTo(right.getSuspensionTag()));
  }

  @override
  String toString() {
    return {phoneNumber, name, contact, history}.toString();
  }

  DialItem.fromHistory(History history) {
    name = '';
    phoneNumber = history.phoneNumber;
    time = history.startAt;
    if (history.bg != null) bg = Color(history.bg);
    format();
  }

  DialItem.fromContact(Contact con) {
    contact = con;
    format();
  }

  // double rankNameBak(String numbers, {bool combo = true}) {
  //   double baseRankScore = 0.0;
  //   // 姓名匹配
  //   int numberIndex = 0;
  //   int nameIndex = 0;
  //   int letterIndex = 0;
  //   int lastNameIndex = -1, lastLetterIndex = -1;
  //   bool first = false; // 匹配首字母

  //   // 相邻规则
  //   // numbers游标递进不相邻算法
  //   for (; numberIndex < numbers.length; numberIndex++) {
  //     String number = numbers[numberIndex];
  //     bool numberFound = false;
  //     while (!numberFound && nameIndex < namePinyinArr.length) {
  //       String name =
  //           namePinyinArr[nameIndex] != null ? namePinyinArr[nameIndex] : '';
  //       if (name != null && name.isNotEmpty) {
  //         String letter = name[letterIndex];
  //         if (numberLetterMap[number] != null &&
  //             numberLetterMap[number].indexOf(letter.toUpperCase()) > -1) {
  //           // 当前位置匹配
  //           if (nameHited.indexOf(nameIndex) == -1) {
  //             nameHited.add(nameIndex);
  //           }
  //           // 每次命中基础增加10分， 同单词同时命中 - 0， 夸词汇 - d,如果跨的是首字 - d / 2
  //           score += 10 + (combo ? 2: 1);
  //           // 首字母模式直接跳到下个单
  //           if (nameHited.length == 2 &&
  //               lastLetterIndex == 0 &&
  //               letterIndex == 0) {
  //             first = true;
  //           }
  //           lastNameIndex = nameIndex;
  //           lastLetterIndex = letterIndex;
  //           numberFound = true;
  //         }
  //       }
  //       // jump
  //       // 首字母模式直接跳到下个单词
  //       if (letterIndex < name.length - 1 && numberFound && !first) {
  //         letterIndex++;
  //       } else {
  //         if (combo && nameHited.isNotEmpty && nameHited.last != nameIndex) {
  //           nameIndex = nameHited.first + 1;
  //           nameHited = [];
  //           score = 0;
  //           letterIndex = 0;
  //           numberIndex = 0;
  //           first = false;
  //           numberFound = false;
  //         } else {
  //           nameIndex++;
  //           letterIndex = 0;
  //         }
  //       }
  //     }
  //     // print("nameIndex:$nameIndex,letterIndex:$letterIndex,numberFound:$numberFound");
  //     if (!numberFound) {
  //       // name遍历结束未找到
  //       // print("not found ,${numberIndex.toDouble()} $phoneNumbers");
  //       score = baseRankScore; // 未找到得分清零
  //       numberHited = [];
  //       nameHited = [];
  //       return score;
  //     }
  //   }
  //   // 最终找到
  //   score += nameHited.length / nameArr.length * 5;
  //   score += baseRankScore;
  //   return score;
  // }
}
