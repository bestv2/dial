import 'package:flutter/material.dart';

class FlexibleBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  FlexibleBar({@required this.child}) : assert(child != null);
  @override
  Widget build(BuildContext context) {
    // return Container(padding: EdgeInsets.only(top: 30), child: child);
    // // TODO: implement build
    return SafeArea(
      top: true,
      child: child,
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => new Size.fromHeight(56.0);
}
