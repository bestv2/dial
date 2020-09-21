import 'package:dial/enum/call_type.dart';
import 'package:dial/model/dial_item.dart';

class Call {
  DialItem from;
  DialItem to;
  DateTime startAt;
  DateTime endAt;
  DateTime connectAt;
  CallType callType;
  bool connected;
}