import 'package:azlistview/azlistview.dart';
import 'package:dial/model/contact.dart';
import 'package:dial/model/dial_item.dart';
import 'package:dial/provider_model/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SuspensionContact extends ISuspensionBean {
  Contact contact;
  DialItem dialItem;
  SuspensionContact(this.contact) {
    dialItem = DialItem.fromContact(contact);
  }
  @override
  String getSuspensionTag() {
    return dialItem.getSuspensionTag();
  }
}

double susItemHeight = 40;

class ContactsPage extends StatelessWidget {
  Map<String, dynamic> params;
  ContactsPage(this.params);
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipOval(
              child: Image.asset(
            "./assets/images/avatar.png",
            width: 80.0,
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "远行",
              textScaleFactor: 1.2,
            ),
          ),
          Text("+86 182-286-44678"),
        ],
      ),
    );
  }

  Widget _buildListItem(
      SuspensionContact model, BuildContext context, HomeModel homeModel, int index) {
    String susTag = model.getSuspensionTag();
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundColor: model.dialItem.bg,
            child: Text(
              model.dialItem.shortName,
              style: TextStyle(color: Colors.white),
            ),
          ),
          title: Text(model.dialItem.name.isNotEmpty
              ? model.dialItem.name
              : model.dialItem.phoneNumber),
          onTap: () {
            homeModel.dial(model.dialItem.phoneNumber);
            // Navigator.pop(context, model);
          },
        )
      ],
    );
  }

  Widget _buildSusWidget(String susTag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      height: susItemHeight,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          Text(
            '$susTag',
            textScaleFactor: 1.2,
          ),
          Expanded(
              child: Divider(
            height: .0,
            indent: 10.0,
          ))
        ],
      ),
    );
  }

  Decoration getIndexBarDecoration(Color color) {
    return BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey[300], width: .5));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('通讯录'),
        ),
        body: SafeArea(
            child: Consumer<HomeModel>(builder: (context, homeModel, child) {
          List<SuspensionContact> _contacts = homeModel.contacts
              .map((contact) => SuspensionContact(contact))
              .toList();
          _contacts.sort((left, right) => left.dialItem.compareTo(right.dialItem));
          // _contacts.sort((left, right) =>
          //     left?.dialItem?.name.compareTo(right?.dialItem?.name));
          print(_contacts.length);
          return AzListView(
            data: _contacts,
            itemCount: _contacts.length,
            itemBuilder: (BuildContext context, int i) {
              // if (i.isOdd) {
              //   return Divider(
              //     height: 1,
              //   );
              // }
              // final index = i ~/ 2;
              // if (index >= _contacts.length) {
              //   return null;
              // }
              SuspensionContact model = _contacts[i];
              return _buildListItem(model, context, homeModel, i);
            },
            physics: BouncingScrollPhysics(),
            indexBarData: SuspensionUtil.getTagIndexList(_contacts),
            indexHintBuilder: (context, hint) {
              return Container(
                alignment: Alignment.center,
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.blue[700].withAlpha(200),
                  shape: BoxShape.circle,
                ),
                child: Text(hint,
                    style: TextStyle(color: Colors.white, fontSize: 30.0)),
              );
            },
            indexBarMargin: EdgeInsets.all(10),
            indexBarOptions: IndexBarOptions(
              needRebuild: true,
              decoration: getIndexBarDecoration(Colors.grey[50]),
              downDecoration: getIndexBarDecoration(Colors.grey[200]),
            ),
          );
        })));
  }
}
