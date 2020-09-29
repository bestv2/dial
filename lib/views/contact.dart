import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  Map<String, dynamic> params;
  ContactPage(this.params);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ContactPageState();
  }
}

class _ContactPageState extends State<ContactPage> {
  String id;
  String firstName;
  String lastName;
  List<dynamic> phoneNumbers;
  List<String> types = <String>['Other', 'Home', 'Work'];

  @override
  void initState() {
    super.initState();
    var params = this.widget.params;
    if (params['contact'] != null && params['contact'][0] != null) {
      var contact = jsonDecode(params['contact'][0]);
      firstName = contact["firstName"];
      lastName = contact["lastName"];
      phoneNumbers = jsonDecode(contact["phoneNumbers"]);
      phoneNumbers.forEach((element) { 
        element["type"] = element["type"].toString().replaceAll(RegExp(r"(^.*<)|(>.*$)"), "");
        if(!types.contains(element["type"])) {
          types.add(element["type"]);
        }
        print(element);
      });
    } else {
      phoneNumbers = [
        {'number': params['phoneNumber'], 'type': types[0]}
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    var params = (this.widget).params;
    var contact = params["contact"] != null ? params["contact"][0] : null;
    if (contact != null) {
      contact = jsonDecode(contact);
    }
    var formItems = <Widget>[
      Container(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Text('姓氏:'),
            ),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: this.lastName),
                decoration: new InputDecoration(
                  hintText: '姓氏',
                ),
              ),
            )
          ],
        ),
      ),
      Row(
        // mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: EdgeInsets.only(right: 20),
            child: Text('名字:'),
          ),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: this.firstName),
              decoration: new InputDecoration(
                hintText: '名字',
              ),
            ),
          )
        ],
      ),
    ];
    var numberRows = phoneNumbers.map((phoneNumberMap) => Row(
          // mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              child: Text('电话:'),
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(right: 12),
              child: TextField(
                controller:
                    TextEditingController(text: phoneNumberMap["number"]),
                decoration: new InputDecoration(
                  hintText: '电话',
                ),
              ),
            )),
            DropdownButton<String>(
              value: phoneNumberMap['type'] ?? 'other',
              // icon: Icon(Icons.arrow_downward),
              itemHeight: 65,
              iconSize: 32,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 1,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String newValue) {
                // setState(() {
                //   dropdownValue = newValue;
                // });
              },
              items: types.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            )
          ],
        ));
    formItems.addAll(numberRows);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('编辑联系人'),
        actions: [
          InkWell(
            highlightColor: null,
            enableFeedback: false,
            onTap: () {
              // showDialog(context: context, child: Text('hehe'));
            },
            child: Container(
                padding: EdgeInsets.only(right: 15, left: 15),
                child: Center(
                  child: Text('保存'),
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      child: Image.asset(
                        'assets/images/avatar.png',
                        width: 32,
                        height: 32,
                      ),
                    ),
                    Text('点击设置头像')
                  ],
                ),
              ),
              Divider(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: formItems,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
