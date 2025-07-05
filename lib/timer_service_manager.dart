import 'dart:async';
import 'package:flutter/widgets.dart';
import 'timer_service.dart';
import 'notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 管理TimerService的前后台校正，需在入口注册
class TimerServiceManager with WidgetsBindingObserver {
  static final TimerServiceManager _instance = TimerServiceManager._internal();
  factory TimerServiceManager() => _instance;
  TimerServiceManager._internal();

  // 记录离开前所有running timer的剩余秒数
  final Map<String, int> _pausedRemainingSeconds = {};
  DateTime? _pausedTimestamp;

  // 记录离开前所有running timer的剩余秒数和时间戳，便于进程被杀后恢复
  static const String _prefsKeyPausedTimers = 'paused_timers';
  static const String _prefsKeyPausedTimestamp = 'paused_timestamp';

  Future<void> _persistPausedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKeyPausedTimers, jsonEncode(_pausedRemainingSeconds));
    await prefs.setString(
        _prefsKeyPausedTimestamp, _pausedTimestamp?.toIso8601String() ?? '');
  }

  Future<void> _restorePausedState() async {
    final prefs = await SharedPreferences.getInstance();
    final timersStr = prefs.getString(_prefsKeyPausedTimers);
    final timestampStr = prefs.getString(_prefsKeyPausedTimestamp);
    if (timersStr != null &&
        timersStr.isNotEmpty &&
        timestampStr != null &&
        timestampStr.isNotEmpty) {
      final Map<String, dynamic> map = jsonDecode(timersStr);
      _pausedRemainingSeconds.clear();
      map.forEach((k, v) => _pausedRemainingSeconds[k] = v as int);
      _pausedTimestamp = DateTime.tryParse(timestampStr);
    } else {
      _pausedRemainingSeconds.clear();
      _pausedTimestamp = null;
    }
  }

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _onPaused();
      _persistPausedState();
    } else if (state == AppLifecycleState.resumed) {
      _restorePausedState().then((_) => _onResumed());
    }
  }

  void _onPaused() {
    _pausedRemainingSeconds.clear();
    final timers = TimerService().timers;
    for (final timer in timers) {
      if (timer.isRunning && !timer.isFinished) {
        _pausedRemainingSeconds[timer.id] = timer.remainingSeconds;
        TimerService().stopTimer(TimerService().timers.indexOf(timer));
      }
    }
    _pausedTimestamp = DateTime.now();
  }

  void _onResumed() {
    if (_pausedTimestamp == null) return;
    final delta = DateTime.now().difference(_pausedTimestamp!).inSeconds;
    final timers = TimerService().timers;
    for (final entry in _pausedRemainingSeconds.entries) {
      final timerIndex = timers.indexWhere((t) => t.id == entry.key);
      if (timerIndex == -1) continue;
      final timer = timers[timerIndex];
      final newRemaining = entry.value - delta;
      if (newRemaining <= 0) {
        timer.remainingSeconds = 0;
        timer.isFinished = true;
        timer.isRunning = false;
        timer.timer?.cancel();
        NotificationHelper.cancelNotification(timer.id.hashCode);
        // 强制刷新UI
        TimerService().timersNotifier.value = List.from(TimerService().timers);
      } else {
        timer.remainingSeconds = newRemaining;
        timer.isFinished = false;
        timer.isRunning = false;
        TimerService().startTimer(timerIndex);
        // 使用唯一文件名，避免并发/覆盖问题
        NotificationHelper.scheduleTimerFinishedNotification(
          id: timer.id.hashCode,
          title: '倒计时结束',
          body: '${timer.name} 完成',
          secondsFromNow: timer.remainingSeconds,
          uniqueAttachmentName:
              '${timer.id}_${DateTime.now().millisecondsSinceEpoch}.jpeg',
        );
      }
    }
    _pausedRemainingSeconds.clear();
    _pausedTimestamp = null;
    // 清理持久化
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_prefsKeyPausedTimers);
      prefs.remove(_prefsKeyPausedTimestamp);
    });
  }
}
