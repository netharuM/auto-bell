import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// titleBar of the application this contains the `close`,`minimize` and `resize` buttons and
/// also this has ability to drag the window
class TitleBar extends StatelessWidget implements PreferredSizeWidget {
  /// [title] of the [TitleBar]
  final String? title;

  /// background [Color]
  final Color? backgroundColor;

  /// [Color] of the close button
  final Color? closeButtonColor;

  /// text [Color]
  final Color? textColor;

  /// color of the buttons
  final Color? buttonColor;

  /// background [Color]  around the three buttons (`close`,`minimize` and `resize`)
  final Color? windowButtonBGColor;

  /// style of the close button (`x` button)
  final ButtonStyle? closeButtonStyle;

  /// you can add widget before the three buttons with this [suffixTools]
  final Widget? suffixTools;

  /// widget that is below the title bar
  /// like a navigation bar or something
  /// you can add any [Widget] to here
  final Widget? bottom;

  /// size of the [TitleBar]
  /// its better if you use [Height]
  ///
  /// by default its
  /// ```dart
  /// const Size.fromHeight(28)
  /// ```
  final Size customPrefferedSize;
  const TitleBar(
      {Key? key,
      this.title,
      this.backgroundColor,
      this.closeButtonColor,
      this.textColor,
      this.buttonColor,
      this.windowButtonBGColor,
      this.closeButtonStyle,
      this.suffixTools,
      this.bottom,
      this.customPrefferedSize = const Size.fromHeight(28)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xff262a32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                MoveWindow(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: title != null,
                            child: Flexible(
                              child: IgnorePointer(
                                ignoring: true,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Text(
                                    title ?? "",
                                    style: TextStyle(
                                      color: textColor ?? Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                              child:
                                  Flexible(child: suffixTools ?? Container()),
                              visible: suffixTools != null),
                        ],
                      ),
                    ),
                    WindowButtons(
                      buttonColor: buttonColor,
                      closeButtonColor: closeButtonColor,
                      backgroundColor: windowButtonBGColor,
                      closeButtonStyle: closeButtonStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Visibility(
            visible: bottom != null,
            child: bottom ?? Container(),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => customPrefferedSize;
}

class WindowButtons extends StatelessWidget {
  /// color of the buttons
  final Color? buttonColor;

  /// color of the close button
  final Color? closeButtonColor;

  /// background color
  final Color? backgroundColor;

  /// #### close button style
  /// if the [closeButtonStyle] is not [null]
  ///
  /// then it will ignore the [closeButtonColor]
  final ButtonStyle? closeButtonStyle;
  const WindowButtons(
      {Key? key,
      this.buttonColor,
      this.closeButtonColor,
      this.backgroundColor,
      this.closeButtonStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Row(
        children: [
          TextButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(buttonColor ?? Colors.grey),
              overlayColor: MaterialStateProperty.all<Color>(
                  (buttonColor ?? Colors.grey).withOpacity(0.1)),
            ),
            onPressed: () {
              windowManager.minimize();
            },
            child: MinimizeIcon(color: buttonColor ?? Colors.grey),
          ),
          TextButton(
            style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.all<Color>(buttonColor ?? Colors.grey),
              overlayColor: MaterialStateProperty.all<Color>(
                  (buttonColor ?? Colors.grey).withOpacity(0.1)),
            ),
            onPressed: () async {
              if (await windowManager.isMaximized()) {
                windowManager.unmaximize();
              } else {
                windowManager.maximize();
              }
            },
            child: MaximizeIcon(color: buttonColor ?? Colors.grey),
          ),
          TextButton(
            style: closeButtonStyle ??
                ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      closeButtonColor ?? Colors.red),
                  overlayColor: MaterialStateProperty.all<Color>(
                      (closeButtonColor ?? Colors.red).withOpacity(0.1)),
                ),
            onPressed: () {
              windowManager.close();
            },
            child: CloseIcon(color: closeButtonColor ?? Colors.red),
          ),
        ],
      ),
    );
  }
}
