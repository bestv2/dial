import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  Map<String, dynamic> params;
  ContactPage(this.params);
  @override
  Widget build(BuildContext context) {
    print(params);
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
                  children: <Widget>[
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
                            decoration: new InputDecoration(
                              hintText: '名字',
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 20),
                          child: Text('电话:'),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: params["phoneNumber"][0]),
                            decoration: new InputDecoration(
                              hintText: '电话',
                            ),
                          ),
                        )
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     Text('名字:'),
                    //     // TextField(
                    //     //   decoration: new InputDecoration(
                    //     //     hintText: '名字',
                    //     //   ),
                    //     // ),
                    //   ],
                    // ),
                    // Row(
                    //   children: [
                    //     TextField(
                    //         // decoration: new InputDecoration(
                    //         //   hintText: '姓氏',
                    //         // ),
                    //         ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
