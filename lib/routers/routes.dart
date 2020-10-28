import 'package:dial/routers/router_handler.dart';
import 'package:dial/views/contact.dart';
import 'package:dial/views/contacts.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart' as route;

class PageRouteConfig {
  int id;
  String routePath;
  String name;
  String title;
  String desc;
  String cover;
  Function buildRouter;

  PageRouteConfig(
      {this.id,
      this.routePath,
      this.name,
      this.title,
      this.desc,
      this.cover,
      this.buildRouter});
  PageRouteConfig.fromJSON(Map json)
      : id = json['id'],
        routePath = json['routePath'],
        name = json['name'],
        title = json['title'],
        desc = json['desc'],
        cover = json['cover'],
        buildRouter = json['buildRouter'];
}

class Routes {
  static String root = '/';
  static String home = '/home';
  static final List<PageRouteConfig> commons = [
    new PageRouteConfig(
      routePath: '/contacts',
      buildRouter: (BuildContext context, Map<String, dynamic> params) =>
          new ContactsPage(params),
    ),
    new PageRouteConfig(
      routePath: '/contact',
      buildRouter: (BuildContext context, Map<String, dynamic> params) =>
          new ContactPage(params),
    ),
  ];
  // static String learn_layout = '/learn_layout';

  static generateBuildFun(String title, Widget child) {
    return (BuildContext context, Map<String, dynamic> params) => Scaffold(
          appBar: AppBar(
            title: Text(title ?? 'lession'),
          ),
          body: child,
        );
  }

  static void configureRoutes(route.Router router) {
    router.define(home, handler: homeHandler);
    commons.forEach((config) {
      router.define(config.routePath, handler: route.Handler(
        handlerFunc: config.buildRouter,
      ));
    });
  }
}
