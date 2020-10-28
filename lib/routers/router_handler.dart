import 'package:dial/views/home.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart' as route;
// app的首页
var homeHandler = new route.Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new Home();
  },
);

// var learnLayoutHandler = new Handler(
//   handlerFunc: (BuildContext context, Map<String, List<String>> params) {
//     return new LearnLayout();
//   },
// );