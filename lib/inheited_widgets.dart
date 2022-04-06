import 'package:flutter/material.dart';

class BellCardData extends InheritedWidget {
  const BellCardData({required this.shake, Key? key, required Widget child})
      : super(child: child, key: key);

  final bool shake;

  static BellCardData of(BuildContext context) {
    final BellCardData? result =
        context.dependOnInheritedWidgetOfExactType<BellCardData>();
    assert(result != null, 'No BellCardData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(BellCardData oldWidget) {
    return shake != oldWidget.shake;
  }
}
