void wLog(Object message, {StackTrace trace}) {
  Logger().log(message?.toString(), trace);
}

class Logger {
  static Logger _instace = Logger._internal();
  factory Logger() {
    return _instace;
  }
  Logger._internal() {}

  log(String message, StackTrace trace) {
    print(trace.toString());
    int row = trace == null ? 2 : 0;
    trace = trace ?? StackTrace.current;
    var traceString = trace.toString().split("\n")[row];
    // var indexOfFileName = traceString.indexOf(RegExp(r'[A-Za-z_]+.dart'));
    print("$message\n${traceString.replaceFirst(RegExp(r"^#\d+\s+"), 'located at ')}");
  }
}
