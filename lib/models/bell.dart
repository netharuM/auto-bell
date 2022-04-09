import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:auto_bell/settings.dart';

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

  Future<void> dispose() async {
    await deactivateBell();
    await _audioPlayer.dispose();
  }

  Future<void> notify() async {
    LocalNotification notification = LocalNotification(
      title: "icmu-autobell",
      body:
          "${title ?? "bell"} is gonna be ringing at ${DateFormat("HH:mm").format(dateTime)}",
      subtitle: title,
    );
    await _localNotifier.notify(notification);
  }

  void activateBell({bool force = false, bool disableTimer = false}) {
    assert(time != null);
    assert(pathToAudio != null);
    String weekDay = DateFormat.EEEE().format(DateTime.now());
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
        _settings.getShowNotifications.then((value) {
          if (value ?? true) {
            Duration ringAt = (dateTime.subtract(const Duration(minutes: 1)))
                .difference(DateTime.now());
            notifyDown = Timer(
              ringAt,
              () {
                if (!ringAt.isNegative) {
                  notify();
                }
              },
            );
          }
        });
      }
      _audioPlayer.setFilePath(pathToAudio!);
      _audioPlayer.setLoopMode(LoopMode.off);
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          if (onStop != null) onStop!();
        }
      });
      activated = true;
      if (onActivate != null) onActivate!();
    }
  }

  get dateTime => DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, time!.hour, time!.minute);

  bool get activateable {
    return pathToAudio != null && time != null;
  }

  bool get timerActive =>
      countDown != null && !dateTime.difference(DateTime.now()).isNegative;

  Future<void> deactivateBell() async {
    countDown?.cancel();
    notifyDown?.cancel();
    await stopBell();
  }

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

  Future<void> stopBell() async {
    if (onStop != null) onStop!();
    await _audioPlayer.stop();
    activated = false;
  }

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
