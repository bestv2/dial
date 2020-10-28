import 'package:fluro/fluro.dart' as route;

enum ENV {
  PRODUCTION,
  DEV,
}

class Application {
  static ENV env = ENV.DEV;
  static route.Router router;
}