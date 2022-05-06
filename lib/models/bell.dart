import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:auto_bell/settings.dart';

enum BellError {
  audioFileNotFound,
}

/// just a wrapper around the [BellError] with extra info
class BellErrorExtended {
  final BellError error;
  final String? description;
  final String? title;
  final String? help;
  const BellErrorExtended(
      {required this.error, this.description, this.title, this.help});

  @override
  int get hashCode => Object.hash(error, description, title);

  @override
  bool operator ==(dynamic other) {
    return error == other.error;
  }
}

class BellErrors {
  final Bell parent;
  final List<BellErrorExtended> _errorsList = [];
  BellErrors({
    required this.parent,
  });

  /// returns [true] if there is any errors otherwise it will return [false]
  bool get isThereErrors => _errorsList.isNotEmpty;

  /// number of errors in the errorsList
  int get errorCount => _errorsList.length;

  /// the errorsList
  List<BellErrorExtended> get getErrorsList => _errorsList;

  /// return [true] if value was in the errorsList otherwise [false]
  bool add(BellErrorExtended error) {
    if (!_errorsList.contains(error)) {
      _errorsList.add(error);
      return true;
    }
    return false;
  }

  /// return [true] if value was in the errorsList otherwise [false]
  bool remove(BellErrorExtended error) {
    return _errorsList.remove(error);
  }

  @override
  int get hashCode => Object.hash(_errorsList, parent);

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    if (errorCount != other.errorCount) return false;
    return getErrorsList
        .every((element) => other.getErrorsList.contains(element));
  }
}

class Bell {
  TimeOfDay? time;
  String? title;
  String? description;
  String? pathToAudio;
  List<bool> days;
  bool activateOnInit;
  bool activated = false;
  Timer? countDown;
  Timer? notifyDown;
  int id;
  int position;
  Function()? onPlay;
  Function()? onStop;
  Function()? onActivate;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final LocalNotifier _localNotifier = LocalNotifier.instance;
  final Settings _settings = Settings.instance;

  // days
  // 0 - monday
  // 1 - tuesday
  // 2 - wednesday
  // 3 - thursday
  // 4 - friday
  Bell({
    this.days = const [true, true, true, true, true],
    this.time,
    this.title,
    this.description,
    this.activateOnInit = false,
    this.pathToAudio,
    this.id = 0,
    this.position = 0,
    this.onPlay,
    this.onStop,
  }) {
    if (activateOnInit) activateBell();
  }

  /// returns the errors if there are any
  Future<BellErrors> get getErrors async {
    BellErrors bellErrors = BellErrors(parent: this);
    if (pathToAudio != null) {
      // if there is a audio file we are checking if there is any errors with it
      File audioFile = File(pathToAudio!);
      if (!await audioFile.exists()) {
        bellErrors.add(
          BellErrorExtended(
            error: BellError.audioFileNotFound,
            title: 'audio file is not found',
            description: '"$pathToAudio" doesn\'t exist',
            help: 'please make sure that this "$pathToAudio" file exists',
          ),
        );
      }
    }
    return bellErrors;
  }

  /// disposes the [Bell]
  Future<void> dispose() async {
    await deactivateBell();
    await _audioPlayer.dispose();
  }

  /// displays a notification
  Future<void> notify() async {
    LocalNotification notification = LocalNotification(
      title: "icmu-autobell",
      body:
          "${title ?? "bell"} is gonna be ringing at ${DateFormat("HH:mm").format(dateTime)}",
      subtitle: title,
    );
    await _localNotifier.notify(notification);
  }

  /// activating the bell before playing
  ///
  /// this will look at the week days before activating
  ///
  /// so if you wanna force the activation set
  ///  - @param force to [true] its [false] by default
  ///  - @param disableTimer - disables the activation of the timer
  Future<void> activateBell({
    bool force = false,
    bool disableTimer = false,
  }) async {
    assert(time != null);
    assert(pathToAudio != null);
    if ((await getErrors).isThereErrors) {
      debugPrint('there are errors so not activating the bell : "$title"');
      return;
    }
    String weekDay = DateFormat.EEEE().format(DateTime.now());
    // checks the week days
    if (force ||
        weekDay == "Monday" && days[0] ||
        weekDay == "Tuesday" && days[1] ||
        weekDay == "Wednesday" && days[2] ||
        weekDay == "Thursday" && days[3] ||
        weekDay == "Friday" && days[4] ||
        weekDay == "Saturday" ||
        weekDay == "Sunday") {
      if (!disableTimer) {
        Duration playAt = dateTime.difference(DateTime.now());
        countDown = Timer(
          playAt,
          () {
            if (!playAt.isNegative) {
              playBell(force: false);
            }
          },
        );
        bool showNotification = await _settings.getShowNotifications ?? true;
        if (showNotification) {
          Duration ringAt = (dateTime.subtract(const Duration(minutes: 1)))
              .difference(DateTime.now());
          notifyDown = Timer(
            ringAt,
            () async {
              if (!ringAt.isNegative) {
                await notify();
              }
            },
          );
        }
      }
      await _audioPlayer.setFilePath(pathToAudio!);
      await _audioPlayer.setLoopMode(LoopMode.off);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (onStop != null) onStop!();
        }
      });
      activated = true;
      if (onActivate != null) onActivate!();
    }
  }

  /// [time] in [DateTime] format
  get dateTime => DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, time!.hour, time!.minute);

  /// returns [true] if the bell is activateable and [false] if its not
  Future<bool> get activateable async {
    return pathToAudio != null &&
        time != null &&
        !(await getErrors).isThereErrors;
  }

  /// returns [true] if timer is active and [false] if its not
  bool get timerActive =>
      countDown != null && !dateTime.difference(DateTime.now()).isNegative;

  /// deactivates the [Bell] including notifications and countdowns
  Future<void> deactivateBell() async {
    countDown?.cancel();
    notifyDown?.cancel();
    await stopBell();
  }

  /// plays the [Bell] it will activate the [Bell] if its not already activated
  Future<void> playBell({bool force = true}) async {
    if (force ||
        time?.minute == DateTime.now().minute &&
            time?.hour == DateTime.now().hour) {
      if (!activated) {
        activateBell(force: true, disableTimer: true);
      }
      await _audioPlayer.play();
      if (onPlay != null) onPlay!();
    }
  }

  /// stops the [Bell]
  Future<void> stopBell() async {
    if (onStop != null) onStop!();
    await _audioPlayer.stop();
    activated = false;
  }

  /// converts to a [Map]
  /// format :
  ///  - 'time' - time in "HH:mm" [DateFormat]
  ///  - 'title' - title of the [Bell]
  ///  - 'position' - position or the order of the [Bell]
  ///  - 'description' - description of the [Bell]
  ///  - 'pathToAudio' - the audio path of the [Bell]
  ///  - 'days' - weekdays list
  ///  - 'activate' - whether to activate on init or not
  Map<String, dynamic> toMap(
      {bool boolToInt = false, bool listToString = false, noId = true}) {
    Map<String, dynamic> map = {
      'time': DateFormat("HH:mm").format(dateTime),
      'title': title,
      'position': position,
      'description': description,
      'pathToAudio': pathToAudio,
      'days': listToString ? days.toString() : days,
      'activate': boolToInt ? (activateOnInit ? 1 : 0) : activateOnInit,
    };
    if (!noId) map['id'] = id;
    return map;
  }

  /// setup args need for this [Bell] from a [Map]
  ///  - 'time' - time in "HH:mm" [DateFormat]
  ///  - 'title' - title of the [Bell]
  ///  - 'position' - position or the order of the [Bell]
  ///  - 'description' - description of the [Bell]
  ///  - 'pathToAudio' - the audio path of the [Bell]
  ///  - 'days' - weekdays list
  ///  - 'activate' - whether to activate on init or not
  void fromMap(Map<String, dynamic> map,
      {bool intAsBool = false,
      listAsStrings = false,
      disableActivation = false}) {
    time = TimeOfDay(
      hour: int.parse(map['time'].split(':')[0]),
      minute: int.parse(map['time'].split(':')[1]),
    );
    title = map['title'];
    id = map['id'];
    description = map['description'];
    pathToAudio = map['pathToAudio'];
    position = map['position'];
    days =
        List<bool>.from(listAsStrings ? json.decode(map['days']) : map['days']);
    activateOnInit =
        intAsBool ? (map['activate'] == 0 ? false : true) : map['activate'];
    if (activateOnInit && !disableActivation) activateBell();
  }
}
