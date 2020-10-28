import 'dart:async';

import 'package:flutter/material.dart';

class Toast {
  static void show(String msg, BuildContext context,
      {Duration duration, bool rootOverlay = false}) {
    duration = duration ?? Duration(seconds: 2);
    Color backgroundColor = const Color(0xAA000000);
    TextStyle textStyle = const TextStyle(fontSize: 15, color: Colors.white);
    double backgroundRadius = 20;
    OverlayEntry entry = OverlayEntry(
        builder: (context) => IgnorePointer(
            child: Positioned(
                top: null,
                bottom: MediaQuery.of(context).viewInsets.bottom + 50,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius:
                                BorderRadius.circular(backgroundRadius),
                            border: null,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                          child: Text(msg, softWrap: true, style: textStyle),
                        )),
                  ),
                ))));
    Overlay.of(context, rootOverlay: rootOverlay).insert(entry);
    ToastFuture future = ToastFuture.create(duration, entry, () {
      entry.remove();
    });
    ToastManager().addFuture(future);
  }
}

class ToastFuture {
  final OverlayEntry _entry;
  final VoidCallback _onDismiss;
  bool _isShow = true;
  Timer _timer;
  ToastFuture(this._entry, this._onDismiss);

  ToastFuture.create(Duration duration, this._entry, this._onDismiss) {
    _timer = Timer(duration, () {
      dismiss();
    });
  }
  dismiss() {
    if (!_isShow) {
      return;
    }
    // _entry.remove();
    _isShow = false;
    _timer.cancel();
    _onDismiss?.call();
    // ToastManager().
  }
}

class ToastManager {
  static ToastManager _singleton = ToastManager._internal();
  factory ToastManager() {
    return _singleton;
  }
  static ToastManager get instance => _singleton;

  ToastManager._internal() {}

  Set<ToastFuture> toastSet = Set();

  addFuture(ToastFuture future) {
    toastSet.add(future);
  }

  removeFuture(ToastFuture future) {
    toastSet.remove(future);
  }
}
