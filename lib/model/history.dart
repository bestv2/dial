import 'package:dial/enum/call_type.dart';
import 'package:dial/model/contact.dart';

class History {
  History({this.phoneNumber, this.startAt, this.contact});
  String phoneNumber;
  Contact contact;
  CallType callType;
  DateTime startAt;

  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'startAt': startAt.toString(),
    };
  }
}