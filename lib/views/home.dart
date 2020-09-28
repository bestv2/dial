import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dial/common/event/index.dart';
import 'package:dial/model/dial_item.dart';
import 'package:dial/provider_model/home.dart';
import 'package:dial/routers/application.dart';
import 'package:dial/utils/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  @override
  Widget build(Object context) {
    return Scaffold(
        // appBar: FlexibleBar(
        //   child: Container(
        //     height: 56,
        //     // color: AppColor.randomColor(),
        //     color: Color(AppColor.backgroundColor),
        //     child: Center(
        //       child: Text(
        //         "打电话啦",
        //         style: TextStyle(
        //             color: Color(AppColor.mainTextColor), fontSize: 20),
        //       ),
        //     ),
        //   ),
        // ),
        backgroundColor: Color(AppColor.backgroundColor),
        body: DialPage());
  }
}

class DialPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DialPageState();
  }
}

class _DialPageState extends State<DialPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> padVisible;
  bool holderVisible = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    padVisible = Tween<double>(begin: 1.0, end: 0).animate(controller);
    // controller.forward();
    eventBus.on<DataEventHome>().listen((event) {
      if (event.from.isNotEmpty && event.to.isEmpty) {
        setState(() {
          holderVisible = false;
        });
      } else if (event.from.isEmpty && event.to.isNotEmpty) {
        setState(() {
          holderVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(AppColor.bodyColor),
        child: Stack(
          children: [
            DialItemList(controller),
            DialPad(
              padVisible: padVisible,
              controller: controller,
              holderVisible: holderVisible,
            ),
            DialBottomBar(
              padVisable: padVisible,
              controller: controller,
            )
          ],
        ),
      ),
    );
  }
}

final double bottomBarHeight = 70;
final double dialButtonHeight = 70;
final double holderHeight = 70;
final double padHeight = dialButtonHeight * 4 + bottomBarHeight;
final double mainFontSize = 18.0;
final double subFontSize = 13.5;

class DialBottomBar extends AnimatedWidget {
  final AnimationController controller;
  static final centerIconColor =
      ColorTween(end: Colors.green, begin: Colors.black);
  DialBottomBar({Key key, Animation<double> padVisable, this.controller})
      : super(key: key, listenable: padVisable);

  @override
  Widget build(Object context) {
    final Animation<double> padVisible = listenable;
    return Consumer<HomeModel>(builder: (context, homeModel, child) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
            height: bottomBarHeight,
            // padding: EdgeInsets.only(bottom: 16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Expanded(
                //   flex: 1,
                //   child: ,
                // ),
                Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(
                        Icons.people,
                        size: 40,
                      ),
                      onPressed: () {
                        Application.router.navigateTo(context, '/contacts');
                      },
                    )),
                Expanded(
                    flex: 1,
                    child: FlatButton(
                      onPressed: () async {
                        if (padVisible.value == 1) {
                          // controller.reverse();
                          if (homeModel.dialed == null ||
                              homeModel.dialed.isEmpty) {
                            return;
                          }
                          homeModel.dial(homeModel.dialed);
                        } else {
                          controller.reverse();
                        }
                      },
                      child: Center(
                          child: Icon(
                        padVisible.value == 1 ? Icons.phone : Icons.list,
                        size: 40,
                        color: centerIconColor.evaluate(padVisible),
                      )),
                    )),
                Expanded(
                    flex: 1,
                    child: padVisible.value == 1
                        ? FlatButton(
                            // label: null,
                            child: Center(
                              child: Icon(
                                Icons.backspace,
                                size: 40,
                              ),
                            ),
                            onPressed: () {
                              homeModel.input('del');
                            },
                            onLongPress: () {
                              homeModel.input('reset');
                            },
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.link,
                              size: 40,
                            ),
                          ))
              ],
            )),
      );
    });
  }
}

class DialPad extends AnimatedWidget {
  final bool holderVisible;
  DialPad(
      {Key key,
      Animation<double> padVisible,
      AnimationController controller,
      this.holderVisible})
      : super(key: key, listenable: padVisible);

  static final padBottom =
      Tween<double>(end: 0, begin: 0 - padHeight - holderHeight);
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(
      builder: (context, homeModel, child) {
        List<Widget> btns = <Widget>[];
        for (int i = 1; i < 10; i++) {
          String value = i.toString();
          btns.add(DialButton(
            value: value,
            letters: DialItem.numberLetterMap[value],
          ));
        }
        btns.addAll([
          DialButton(
            value: '*',
            letters: '',
          ),
          DialButton(
            value: '0',
            tip: '+',
          ),
          DialButton(
              value: '#',
              letters: '',
              tip: '粘贴',
              onLongPress: () async {
                var text = (await Clipboard.getData(Clipboard.kTextPlain)).text;
                if (text != null && RegExp(r"^\d+$").hasMatch(text)) {
                  homeModel.input(text.toString());
                }
              }),
        ]);
        final Animation<double> padVisible = listenable;
        return new Positioned(
          left: 0.0,
          right: 0.0,
          bottom: padBottom.evaluate(padVisible),
          height: padHeight + (holderVisible ? holderHeight : 0),
          // top: 45.0,
          child: Stack(
            // overflow: Overflow.visible,
            // width: animation.value,
            // height: animation.value,
            children: [
              Holder(),
              Container(
                // color: Colors.red,
                padding:
                    EdgeInsets.only(top: (holderVisible ? holderHeight : 0)),
                child: Wrap(
                  // spacing: 8.0, // 主轴(水平)方向间距
                  // runSpacing: 4.0, // 纵轴（垂直）方向间距
                  alignment: WrapAlignment.start, //沿主轴方向居中
                  children: btns,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class Holder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HolderState();
  }
}

class _HolderState extends State<Holder> with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> holderVisible;
  @override
  void initState() {
    super.initState();
    eventBus.on<DataEventHome>().listen((event) {
      if (event.from.isNotEmpty && event.to.isEmpty) {
        controller.reverse();
      } else if (event.from.isEmpty && event.to.isNotEmpty) {
        controller.forward();
      }
    });
    controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    holderVisible = Tween<double>(begin: 0, end: 1.0).animate(controller);
    // controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return HolderWidget(
      animation: holderVisible,
    );
  }
}

class HolderWidget extends AnimatedWidget {
  HolderWidget({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);
  final bottom = Tween<double>(begin: padHeight - holderHeight, end: padHeight);
  @override
  Widget build(BuildContext context) {
    final Animation<double> holderVisible = listenable;
    return Consumer<HomeModel>(
      builder: (context, homeModel, child) {
        return Positioned(
          bottom: bottom.evaluate(holderVisible),
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(width: 1, color: Color(0xfff5f5f5)))

                ///边框颜色、宽
                ),
            height: holderHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(''),
                Expanded(
                  flex: 1,
                  child: FlatButton(
                    onPressed: () async {
                      if (homeModel.dialed == null ||
                          homeModel.dialed.isEmpty) {
                        return;
                      }
                      homeModel.dial(homeModel.dialed);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(homeModel.dialed,
                            overflow: TextOverflow.ellipsis,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(fontSize: 28)),
                        Text('点击此处拨打此号码',
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(AppColor.subTextColor)))
                      ],
                    ),
                  ),
                ),
                Text(''),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DialButton extends StatelessWidget {
  final Key key;
  final String value;
  final String letters;
  final String tip;
  final VoidCallback onLongPress;
  DialButton({this.key, this.value, this.letters, this.tip, this.onLongPress});
  @override
  Widget build(BuildContext context) {
    double numberWidth =
        window.physicalSize.width / window.devicePixelRatio / 3;
    return Consumer<HomeModel>(builder: (context, homeModel, child) {
      return Container(
        // alignment: Alignment.bottomCenter,
        // color: Colors.white,
        color: Colors.white,
        width: numberWidth,
        height: dialButtonHeight,
        child: FlatButton(
          onPressed: () {
            homeModel.input(value);
          },
          onLongPress: tip != null && tip.isNotEmpty
              ? () {
                  if (onLongPress != null) {
                    onLongPress.call();
                  } else {
                    homeModel.input(tip);
                  }
                  // if (tip == '粘贴') {}
                }
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 24),
              ),
              tip == null || tip.isEmpty
                  ? Text(letters)
                  : Text(
                      tip,
                      style: TextStyle(
                          fontSize: 12.0, color: Color(AppColor.subTextColor)),
                    )
            ],
          ),
        ),
      );
    });
  }
}

class DialItemList extends StatefulWidget {
  DialItemList(this._animationController);
  final AnimationController _animationController;
  @override
  State<StatefulWidget> createState() {
    return _DialItemListState();
  }
}

class _DialItemListState extends State<DialItemList> {
  ScrollController _controller = new ScrollController();
  @override
  void initState() {
    super.initState();
    eventBus.on<DataEventHome>().listen((event) {
      _controller.animateTo(0,
          duration: Duration(microseconds: 100), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeModel>(
      builder: (context, homeModel, child) {
        return GestureDetector(
            onPanDown: (DragDownDetails e) {
              widget._animationController.forward();
            },
            child: ListView.builder(
                controller: _controller,
                padding: EdgeInsets.only(bottom: 100),
                // padding: EdgeInsets.only(bottom: bottomBarHeight),
                itemCount: homeModel.dialItems.length > 0
                    ? homeModel.dialItems.length * 2 - 1
                    : 0,
                itemBuilder: (context, i) {
                  if (i.isOdd) {
                    return Divider(
                      height: 1,
                    );
                  }
                  final index = i ~/ 2;
                  if (index >= homeModel.dialItems.length) {
                    return null;
                  }
                  DialItem dialItem = homeModel.dialItems[index];
                  String phoneNumber =
                      dialItem.hitedNumber ?? dialItem.phoneNumber;
                  // String name = dialItem.name;
                  List<Widget> nameW = [];
                  List<Widget> numberW = [];
                  if (dialItem.nameHited.isNotEmpty) {
                    var index = 0;
                    dialItem.nameArr.forEach((element) {
                      if (dialItem.nameHited.indexOf(index) > -1) {
                        nameW.add(
                          Text("$element${dialItem.isEn ? ' ' : ''}",
                              style: TextStyle(
                                  color: Color(AppColor.hightlight),
                                  fontSize: mainFontSize)),
                        );
                      } else {
                        nameW.add(
                          Text("$element${dialItem.isEn ? ' ' : ''}",
                              style: TextStyle(
                                  color: Color(AppColor.mainTextColor),
                                  fontSize: mainFontSize)),
                        );
                      }
                      index++;
                    });
                  } else {
                    nameW.add(
                      Text(dialItem.name,
                          style: TextStyle(
                              color: Color(AppColor.mainTextColor),
                              fontSize: mainFontSize)),
                    );
                  }
                  // nameW.add(
                  //   Text(
                  //     // dialItem.score.toString(),
                  //     dialItem.time.toString(),
                  //       style: TextStyle(
                  //           color: Color(AppColor.mainTextColor),
                  //           fontSize: mainFontSize)),
                  // );
                  bool noName = RegExp(r"^\s*$").hasMatch(dialItem.name);
                  double numberSize = noName ? mainFontSize : subFontSize;
                  if (dialItem.numberHited.isNotEmpty) {
                    var index = 0;
                    phoneNumber.split('').forEach((element) {
                      if (dialItem.numberHited.indexOf(index) > -1) {
                        numberW.add(
                          Text(element,
                              style: TextStyle(
                                  color: Color(AppColor.hightlight),
                                  fontSize: numberSize)),
                        );
                      } else {
                        numberW.add(
                          Text(element,
                              style: TextStyle(
                                  color: Color(AppColor.mainTextColor),
                                  fontSize: numberSize)),
                        );
                      }
                      index++;
                    });
                  } else {
                    numberW.add(
                      Text(phoneNumber,
                          style: TextStyle(
                              color: Color(AppColor.mainTextColor),
                              fontSize: numberSize)),
                    );
                  }

                  return FlatButton(
                    onPressed: () async {
                      homeModel.dial(phoneNumber);
                    },
                    onLongPress: () {
                      // if (!dialItem.isSaved()) {
                      showCupertinoModalPopup(
                          context: context,
                          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                          builder: (BuildContext context) {
                            List<Widget> widgets = [
                              CupertinoActionSheetAction(
                                child: Text('复制号码'),
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: phoneNumber));
                                  Navigator.pop(context);
                                },
                                // isDestructiveAction: true,
                              ),
                              CupertinoActionSheetAction(
                                child: Text(
                                    dialItem.isSaved() ? '编辑联系人' : '创建联系人'),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Application.router.navigateTo(context,
                                      "/contact?phoneNumber=$phoneNumber${dialItem.isSaved() ? "&contact=${jsonEncode(dialItem.contact)}" : ""}");
                                },
                                // isDefaultAction: true,
                              ),
                              CupertinoActionSheetAction(
                                child: Text('删除通话记录'),
                                onPressed: () {
                                  homeModel.deleteHistory(phoneNumber);
                                  Navigator.pop(context);
                                },
                                // isDestructiveAction: true,
                              ),
                            ];
                            return CupertinoActionSheet(
                                // title: Text('提示'),
                                // message: Text('是否要删除当前项？'),
                                actions: widgets);
                          });
                      // }
                    },
                    child: Container(
                        // color: Colors.red,
                        padding: EdgeInsets.only(
                            top: 18, bottom: 18, left: 6, right: 6),
                        child: Row(
                          children: <Widget>[
                            Container(
                                margin: EdgeInsets.only(left: 0, right: 16),
                                child: CircleAvatar(
                                  // backgroundColor: AppColor.randomColor(),
                                  backgroundColor: dialItem.bg ?? Colors.purple,
                                  child: Image.asset(
                                    'assets/images/avatar.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                )),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: noName ? numberW : nameW,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: noName ? [] : numberW,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // homeModel.loadContacts();
                              },
                              icon: new Icon(
                                dialItem.isSaved()
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: dialItem.isSaved()
                                    ? Color(AppColor.hightlight)
                                    : Color.fromRGBO(200, 200, 200, .5),
                              ),
                            ),
                          ],
                        )),
                  );
                }));
      },
    );
  }
}
