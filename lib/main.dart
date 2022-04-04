import 'dart:io';
import 'package:auto_bell/pages/bells_page.dart';
import 'package:auto_bell/settings.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  windowManager.ensureInitialized();
  runApp(const MyApp());
  doWhenWindowReady(() {
    const Size initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
  launchAtStartup.setup(
    appName: "Auto Bell",
    appPath: Platform.resolvedExecutable,
  );
  launchAtStartup.isEnabled().then((value) {
    if (value) launchAtStartup.disable();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final SystemTray _systemTray = SystemTray();
  List<MenuItem> _menuItems = [];
  final Settings _settings = Settings.instance;

  @override
  void initState() {
    super.initState();
    initSystemTray();
    windowManager.addListener(this);
    _init();
  }

  Future<void> _init() async {
    bool? preventClose = await _settings.getPreventClose;
    if (preventClose == null) {
      await _settings.setPreventClose(true);
      preventClose = true;
    }
    await windowManager.setPreventClose(preventClose);
    setState(() {});
  }

  @override
  void onWindowClose() async {
    bool _isPrevetClose = await windowManager.isPreventClose();
    if (_isPrevetClose) {
      await hideWindow();
    } else {
      windowManager.destroy();
    }
  }

  Future<void> hideWindow() async {
    await windowManager.hide();
    _menuItems[0] = MenuItem(label: 'show', onClicked: showWindow);
    await _systemTray.setContextMenu(_menuItems);
  }

  Future<void> showWindow() async {
    await windowManager.show();
    _menuItems[0] = MenuItem(label: 'hide', onClicked: hideWindow);
    await _systemTray.setContextMenu(_menuItems);
  }

  Future<void> initSystemTray() async {
    String path = Platform.isWindows ? 'assets/icon.ico' : 'assets/icon.png';

    await _systemTray.initSystemTray(
        title: 'system tray title', iconPath: path);

    _menuItems = [
      MenuItem(label: 'show', onClicked: showWindow),
      MenuItem(label: 'exit', onClicked: windowManager.destroy)
    ];

    await _systemTray.setContextMenu(_menuItems);

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == "leftMouseDown") {
      } else if (eventName == "leftMouseUp") {
        windowManager.show();
      } else if (eventName == "rightMouseDown") {
      } else if (eventName == "rightMouseUp") {}
      _systemTray.popUpContextMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor color =
        generateMaterialColorFromColor(const Color(0xff53a679));
    return MaterialApp(
      title: 'Auto bell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: color,
        primaryColor: const Color(0xff53a679),
        scaffoldBackgroundColor: const Color(0xff21252b),
        cardColor: const Color(0xFF282c34).withOpacity(0.9),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? color
                : const Color(0xff414855);
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            return states.contains(MaterialState.selected)
                ? color
                : const Color(0xff414855);
          }),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: const Color(0xFF2C2F36),
          dialTextColor: Colors.white,
          helpTextStyle: TextStyle(color: color),
          hourMinuteTextColor: color,
          dayPeriodTextColor: color,
          entryModeIconColor: color,
        ),
        textTheme: Typography().white,
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.all(const Color(0xff414855)),
        ),
      ),
      home: const BellPage(),
    );
  }
}

MaterialColor generateMaterialColorFromColor(Color color) {
  return MaterialColor(color.value, {
    50: Color.fromRGBO(color.red, color.green, color.blue, 0.1),
    100: Color.fromRGBO(color.red, color.green, color.blue, 0.2),
    200: Color.fromRGBO(color.red, color.green, color.blue, 0.3),
    300: Color.fromRGBO(color.red, color.green, color.blue, 0.4),
    400: Color.fromRGBO(color.red, color.green, color.blue, 0.5),
    500: Color.fromRGBO(color.red, color.green, color.blue, 0.6),
    600: Color.fromRGBO(color.red, color.green, color.blue, 0.7),
    700: Color.fromRGBO(color.red, color.green, color.blue, 0.8),
    800: Color.fromRGBO(color.red, color.green, color.blue, 0.9),
    900: Color.fromRGBO(color.red, color.green, color.blue, 1.0),
  });
}
