import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:project_timer/timer_sound_helper.dart';
import 'package:project_timer/notification_helper.dart';
import 'package:project_timer/config_service.dart';

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
  }

  Future<void> saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = timers.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('timers', list);
  }

  void _log(String action, {TimerData? timer}) {
    if (timer != null) {
      debugPrint(
          '[TimerService] $action: id=${timer.id}, name=${timer.name}, createdAt=${timer.createdAt}, updatedAt=${timer.updatedAt}');
    } else {
      debugPrint('[TimerService] $action');
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
    // 注册将来的本地通知
    final timer = timers[index];
    if (!timer.isFinished && timer.remainingSeconds > 0) {
      NotificationHelper.scheduleTimerFinishedNotification(
        id: timer.id.hashCode,
        title: '倒计时结束',
        body: '${timer.name} 完成',
        secondsFromNow: timer.remainingSeconds,
      );
    }
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
        // 这里不再立即推送通知，由schedule保证
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
    // 取消本地通知
    //NotificationHelper.cancelNotification(timerData.id.hashCode);
  }

  void resetTimer(int index) {
    final timerData = timers[index];
    timerData.timer?.cancel();
    timerData.remainingSeconds = timerData.totalSeconds;
    timerData.isFinished = false;
    timerData.isRunning = false;
    timersNotifier.value = List.from(timers);
    saveTimers();
    // 取消本地通知
    NotificationHelper.cancelNotification(timerData.id.hashCode);
  }

  void dispose() {
    for (var t in timers) {
      t.timer?.cancel();
    }
    saveTimers();
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
    this.timer,
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
        id: json['id'] as String?,
        name: json['name'] as String,
        totalSeconds: json['totalSeconds'] is int
            ? json['totalSeconds']
            : int.tryParse(json['totalSeconds'].toString()) ?? 0,
        remainingSeconds: json['remainingSeconds'] is int
            ? json['remainingSeconds']
            : int.tryParse(json['remainingSeconds'].toString()) ?? 0,
        isFinished: json['isFinished'] as bool? ?? false,
        isRunning: json['isRunning'] as bool? ?? false,
        color: Color(json['color'] is int
            ? json['color']
            : int.tryParse(json['color'].toString()) ?? 0),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
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
