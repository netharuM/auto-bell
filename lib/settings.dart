import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// [Settings] manager
class Settings {
  Settings._init();

  /// [Settings] instance
  static final Settings instance = Settings._init();

  static SharedPreferences? _prefs;
  Future<SharedPreferences> get prefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// launch on system startup
  Future<bool?> get getLaunchOnStartup async =>
      (await prefs).getBool('launchOnStartup');

  /// prevents from closing the window
  Future<bool?> get getPreventClose async =>
      (await prefs).getBool('preventClose');

  /// show notifications
  Future<bool?> get getShowNotifications async =>
      (await prefs).getBool('showNotifications');

  /// icmu background image enabled or not
  Future<bool> get getBGEnabled async {
    SharedPreferences _sharedPrefs = await prefs;
    bool? bgEnabled = _sharedPrefs.getBool('BGEnabled');
    if (bgEnabled == null) {
      setBGEnabled(true);
      return true;
    }
    return bgEnabled;
  }

  /// enable or disable icmu background image
  Future<void> setBGEnabled(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    sharedPrefs.setBool('BGEnabled', value);
  }

  /// enable or disable launching on system startup
  Future<void> setLaunchOnStartup(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    value ? launchAtStartup.enable() : launchAtStartup.disable();
    sharedPrefs.setBool('launchOnStartup', value);
  }

  /// enable or disable preventing from closing the window
  Future<void> setPreventClose(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    windowManager.setPreventClose(value);
    await sharedPrefs.setBool('preventClose', value);
  }

  /// enable or disable notification
  Future<void> setShowNotifications(bool value) async {
    SharedPreferences sharedPrefs = await prefs;
    sharedPrefs.setBool('showNotifications', value);
  }
}
