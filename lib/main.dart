import 'dart:async';

import 'package:dial/provider_model/home.dart';
import 'package:dial/routers/application.dart';
import 'package:dial/utils/style.dart';
import 'package:dial/views/home.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routers/routes.dart';

void main() {
  runZoned(() {
    runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => HomeModel())],
      child: DialApp(),
    ));
    // runApp(MultiProvider(

    // ));
  },
   onError: (Object obj, StackTrace stack) {
    print(obj);
    print(stack);
  });
}

class DialApp extends StatelessWidget {
  DialApp() {
    final router = new Router(); 
    Routes.configureRoutes(router);
    Application.router = router;
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '拨号吧',
      theme: ThemeData(
        primaryColor: Color(AppColor.themeColor),
        backgroundColor: Color(AppColor.backgroundColor),
        accentColor: Color(AppColor.accentColor),
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Color(AppColor.mainTextColor), fontSize: 16.0)),
      ),
      home: Home(),
    );
  }
}