import 'dart:convert';
import 'dart:developer';

import 'package:dial/common/log/logger.dart';
import 'package:dial/components/toast.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/provider_model/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      wLog(contact);
      id = contact["id"];
      firstName = contact["firstName"];
      lastName = contact["lastName"];
      phoneNumbers = jsonDecode(contact["phoneNumbers"]);
      phoneNumbers.forEach((element) {
        element["label"] = element["label"]
            .toString()
            .replaceAll(RegExp(r"(^.*<)|(>.*$)"), "");
        if (!types.contains(element["label"])) {
          types.add(element["label"]);
        }
      });
    }
    if (phoneNumbers.isEmpty) {
      wLog('empty');
      phoneNumbers = [
        {
          'value': (params['phoneNumber'][0] != 'null' &&
                  params['phoneNumber'][0] != null)
              ? params['phoneNumber'][0]
              : '',
          'label': (types[0] != 'null' && types[0] != null) ? types[0] : ''
        }
      ];
    }
    wLog(phoneNumbers);
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
                onChanged: (value) {
                  lastName = value;
                },
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
              onChanged: (value) {
                firstName = value;
              },
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
                    TextEditingController(text: phoneNumberMap["value"]),
                decoration: new InputDecoration(
                  hintText: '电话',
                ),
              ),
            )),
            DropdownButton<String>(
              value: phoneNumberMap['label'] ?? 'other',
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
          Consumer<HomeModel>(builder: (context, homeModel, child) {
            return InkWell(
              highlightColor: null,
              enableFeedback: false,
              onTap: () async {
                var phones =
                    phoneNumbers.map((e) => PhoneNumber.fromJSON(e)).toList();
                var res = await homeModel.save(Contact(
                    id: id,
                    firstName: firstName,
                    lastName: lastName,
                    phones: phones));
                id = res["identifier"];
                wLog(res);
                Toast.show('保存成功', context);
                // showDialog(context: context, child: Text('hehe'));
              },
              child: Container(
                  padding: EdgeInsets.only(right: 15, left: 15),
                  child: Center(
                    child: Text('保存'),
                  )),
            );
          }),
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
