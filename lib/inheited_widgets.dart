import 'package:flutter/material.dart';

/// inherited widget for the [BellCard] this will provide data needed for [BellCard]
class BellCardData extends InheritedWidget {
  const BellCardData({required this.shake, Key? key, required Widget child})
      : super(child: child, key: key);

  /// if [BellCard] needs to shake it needs to be [true] otherwise [false]
  final bool shake;

  /// picks the bellCardData from the [context]
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
