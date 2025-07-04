import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// 事件通知
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier(ConfigService().flutterThemeMode);
final ValueNotifier<AppLayoutMode> layoutModeNotifier =
    ValueNotifier(ConfigService().layoutMode);
final ValueNotifier<AppTimeFormat> timeFormatNotifier =
    ValueNotifier(ConfigService().timeFormat);
final ValueNotifier<bool> showAppBarNotifier = ValueNotifier(true);
final ValueNotifier<AppListSortMode> countdownSortModeNotifier =
    ValueNotifier(ConfigService().countdownSortMode);
final ValueNotifier<AppListSortMode> anniversarySortModeNotifier =
    ValueNotifier(ConfigService().anniversarySortMode);

/// 主题模式枚举
enum AppThemeMode { system, light, dark }

/// 布局模式枚举
enum AppLayoutMode { list, grid, carousel }

/// 入口页面枚举
enum AppEntryPage { countdown, anniversary, clock }

/// 时间制式枚举
enum AppTimeFormat { h24, h12 }

/// 列表排序方式
enum AppListSortMode {
  createdAsc, // 按新增时间升序
  createdDesc, // 按新增时间降序
  updatedAsc, // 按修改时间升序
  updatedDesc, // 按修改时间降序
  dateAsc, // 按纪念日升序
  dateDesc, // 按纪念日降序
}

/// 全局配置服务，负责存取设置参数
class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  static const String _themeModeKey = 'theme_mode';
  static const String _layoutModeKey = 'layout_mode';
  static const String _entryPageKey = 'entry_page';
  static const String _timeFormatKey = 'time_format';
  static const String _keepScreenOnKey = 'keep_screen_on';
  static const String _countdownSortModeKey = 'countdown_sort_mode';
  static const String _anniversarySortModeKey = 'anniversary_sort_mode';

  /// 当前主题模式
  AppThemeMode themeMode = AppThemeMode.system;

  /// 当前布局模式
  AppLayoutMode layoutMode = AppLayoutMode.list;

  /// 当前入口页面
  AppEntryPage entryPage = AppEntryPage.countdown;

  /// 当前时间制式
  AppTimeFormat timeFormat = AppTimeFormat.h24;

  /// 屏幕常亮配置
  bool keepScreenOn = false;

  /// 倒计时排序方式
  AppListSortMode countdownSortMode = AppListSortMode.createdAsc;

  /// 纪念日排序方式
  AppListSortMode anniversarySortMode = AppListSortMode.createdAsc;

  /// 初始化，加载本地配置
  Future<void> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_themeModeKey);
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < AppThemeMode.values.length) {
      themeMode = AppThemeMode.values[modeIndex];
    }
    final layoutIndex = prefs.getInt(_layoutModeKey);
    if (layoutIndex != null &&
        layoutIndex >= 0 &&
        layoutIndex < AppLayoutMode.values.length) {
      layoutMode = AppLayoutMode.values[layoutIndex];
    }
    final entryIndex = prefs.getInt(_entryPageKey);
    if (entryIndex != null &&
        entryIndex >= 0 &&
        entryIndex < AppEntryPage.values.length) {
      entryPage = AppEntryPage.values[entryIndex];
    }
    final timeFormatIndex = prefs.getInt(_timeFormatKey);
    if (timeFormatIndex != null &&
        timeFormatIndex >= 0 &&
        timeFormatIndex < AppTimeFormat.values.length) {
      timeFormat = AppTimeFormat.values[timeFormatIndex];
    }
    keepScreenOn = prefs.getBool(_keepScreenOnKey) ?? false;
    if (keepScreenOn) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    final countdownSortIndex = prefs.getInt(_countdownSortModeKey);
    if (countdownSortIndex != null &&
        countdownSortIndex >= 0 &&
        countdownSortIndex < AppListSortMode.values.length) {
      countdownSortMode = AppListSortMode.values[countdownSortIndex];
    }
    final anniversarySortIndex = prefs.getInt(_anniversarySortModeKey);
    if (anniversarySortIndex != null &&
        anniversarySortIndex >= 0 &&
        anniversarySortIndex < AppListSortMode.values.length) {
      anniversarySortMode = AppListSortMode.values[anniversarySortIndex];
    }
  }

  /// 设置主题模式并保存
  Future<void> setThemeMode(AppThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    themeModeNotifier.value = flutterThemeMode;
  }

  /// 设置布局模式并保存
  Future<void> setLayoutMode(AppLayoutMode mode) async {
    layoutMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_layoutModeKey, mode.index);
    layoutModeNotifier.value = mode;
  }

  /// 设置入口页面并保存
  Future<void> setEntryPage(AppEntryPage page) async {
    entryPage = page;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_entryPageKey, page.index);
  }

  /// 设置时间制式并保存
  Future<void> setTimeFormat(AppTimeFormat format) async {
    timeFormat = format;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeFormatKey, format.index);
    timeFormatNotifier.value = format;
  }

  /// 设置屏幕常亮并保存
  Future<void> setKeepScreenOn(bool value) async {
    keepScreenOn = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keepScreenOnKey, value);
    if (value) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
  }

  /// 设置倒计时排序方式并保存
  Future<void> setCountdownSortMode(AppListSortMode mode) async {
    countdownSortMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countdownSortModeKey, mode.index);
    countdownSortModeNotifier.value = mode;
  }

  /// 设置纪念日排序方式并保存
  Future<void> setAnniversarySortMode(AppListSortMode mode) async {
    anniversarySortMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_anniversarySortModeKey, mode.index);
    anniversarySortModeNotifier.value = mode;
  }

  /// 获取ThemeMode对应的Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
