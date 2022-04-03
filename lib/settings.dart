import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class Settings {
  Settings._init();
  static final Settings instance = Settings._init();

  static SharedPreferences? _prefs;
  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<bool?> get getLaunchOnStartup async =>
      (await prefs).getBool('launchOnStartup');

  Future<bool?> get getPreventClose async =>
      (await prefs).getBool('preventClose');

  Future<bool?> get getShowNotifications async =>
      (await prefs).getBool('showNotifications');

  Future<void> setLaunchOnStartup(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    value ? launchAtStartup.enable() : launchAtStartup.disable();
    sharedPrefs.setBool('launchOnStartup', value);
  }

  Future<void> setPreventClose(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    windowManager.setPreventClose(value);
    await sharedPrefs.setBool('preventClose', value);
  }

  Future<void> setShowNotifications(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    sharedPrefs.setBool('showNotifications', value);
  }
}
