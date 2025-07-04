import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:project_timer/timer_sound_helper.dart';
import 'package:project_timer/notification_helper.dart';
import 'package:project_timer/config_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final ValueNotifier<List<TimerData>> timersNotifier = ValueNotifier([]);
  List<TimerData> get timers => timersNotifier.value;

  Future<void> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('timers') ?? [];
    List<TimerData> loaded =
        list.map((e) => TimerData.fromJson(jsonDecode(e))).toList();
    // 排序
    final sortMode = ConfigService().countdownSortMode;
    loaded.sort((a, b) {
      switch (sortMode) {
        case AppListSortMode.createdAsc:
          return a.createdAt.compareTo(b.createdAt);
        case AppListSortMode.createdDesc:
          return b.createdAt.compareTo(a.createdAt);
        case AppListSortMode.updatedAsc:
          return a.updatedAt.compareTo(b.updatedAt);
        case AppListSortMode.updatedDesc:
          return b.updatedAt.compareTo(a.updatedAt);
        case AppListSortMode.dateAsc:
          // TODO: Handle this case.
          throw UnimplementedError();
        case AppListSortMode.dateDesc:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
    timersNotifier.value = loaded;
    // 恢复定时器运行状态
    for (var i = 0; i < timers.length; i++) {
      if (timers[i].isRunning && !timers[i].isFinished) {
        _startTimerInternal(i);
      }
    }
    _startBackgroundService();
  }

  Future<void> saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = timers.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('timers', list);
  }

  void _log(String action, {TimerData? timer}) {
    if (timer != null) {
      print(
          '[TimerService] $action: id=${timer.id}, name=${timer.name}, createdAt=${timer.createdAt}, updatedAt=${timer.updatedAt}');
    } else {
      print('[TimerService] $action');
    }
  }

  void addTimer(TimerData timer) {
    timersNotifier.value = List.from(timers)..add(timer);
    saveTimers();
    _log('addTimer', timer: timer);
  }

  void removeTimer(int index) {
    timers[index].timer?.cancel();
    _log('removeTimer', timer: timers[index]);
    timersNotifier.value = List.from(timers)..removeAt(index);
    saveTimers();
  }

  void removeTimerById(String id) {
    final removed = timers.where((t) => t.id == id);
    for (final t in removed) {
      _log('removeTimerById', timer: t);
    }
    timersNotifier.value = List.from(timers)..removeWhere((t) => t.id == id);
    saveTimers();
  }

  void startTimer(int index) {
    _startTimerInternal(index);
    timersNotifier.value = List.from(timers);
    saveTimers();
  }

  void _startTimerInternal(int index) {
    final timerData = timers[index];
    timerData.timer?.cancel();
    timerData.timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timerData.remainingSeconds > 0) {
        timerData.remainingSeconds--;
      }
      if (timerData.remainingSeconds == 0 && !timerData.isFinished) {
        timerData.isFinished = true;
        timerData.isRunning = false;
        timerData.timer?.cancel();
        TimerSoundHelper.playFinishSound(); // 播放提示音
        NotificationHelper.showTimerFinishedNotification(
          id: timerData.id.hashCode,
          title: '倒计时结束',
          body: '${timerData.name} 完成',
        );
      }
      timersNotifier.value = List.from(timers);
      saveTimers();
    });
    timerData.isRunning = true;
    timerData.isFinished = false;
  }

  void stopTimer(int index) {
    final timerData = timers[index];
    timerData.timer?.cancel();
    timerData.isRunning = false;
    timersNotifier.value = List.from(timers);
    saveTimers();
  }

  void resetTimer(int index) {
    final timerData = timers[index];
    timerData.timer?.cancel();
    timerData.remainingSeconds = timerData.totalSeconds;
    timerData.isFinished = false;
    timerData.isRunning = false;
    timersNotifier.value = List.from(timers);
    saveTimers();
  }

  void dispose() {
    for (var t in timers) {
      t.timer?.cancel();
    }
    saveTimers();
  }

  void _startBackgroundService() {
    FlutterBackgroundService().startService();
  }
}

class TimerData {
  final String id;
  final String name;
  final int totalSeconds;
  int remainingSeconds;
  bool isFinished;
  bool isRunning;
  final Color color;
  Timer? timer;
  final DateTime createdAt;
  DateTime updatedAt;
  TimerData({
    String? id,
    required this.name,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isFinished,
    this.isRunning = false,
    required this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'isFinished': isFinished,
        'isRunning': isRunning,
        'color': color.value,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
  factory TimerData.fromJson(Map<String, dynamic> json) => TimerData(
        id: json['id'],
        name: json['name'],
        totalSeconds: json['totalSeconds'],
        remainingSeconds: json['remainingSeconds'],
        isFinished: json['isFinished'],
        isRunning: json['isRunning'],
        color: Color(json['color']),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'])
            : DateTime.now(),
      );
}

extension TimerServiceBusiness on TimerService {
  void updateTimer(int index, TimerData newTimer) {
    final timers = List<TimerData>.from(timersNotifier.value);
    timers[index] = newTimer..updatedAt = DateTime.now();
    timersNotifier.value = timers;
    saveTimers();
    _log('updateTimer', timer: newTimer);
  }
}
