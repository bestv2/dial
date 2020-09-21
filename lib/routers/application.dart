import 'package:fluro/fluro.dart';

enum ENV {
  PRODUCTION,
  DEV,
}

class Application {
  static ENV env = ENV.DEV;
  static Router router;
}