import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_timer/anniversary_carousel_page.dart';
import 'package:project_timer/anniversary_grid_page.dart';
import 'countdown_page.dart';
import 'anniversary_service.dart';
import 'timer_service.dart';
import 'gradient_background.dart';
import 'anniversary_page.dart';
import 'clock_page.dart';
import 'settings_page.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'config_service.dart';
import 'app_themes.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'native_timezone_channel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化时区
  tz.initializeTimeZones();
  final String ianaName = await NativeTimezoneChannel.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(ianaName));

  // 桌面端设置最小窗口尺寸
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.setMinimumSize(const Size(640, 480));
  }

  // 全屏显示
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 预加载数据，防止UI闪烁
  await TimerService().loadTimers();
  await AnniversaryService().loadAnniversaries();

  // 加载主题配置，并设置Notifier初始值，保证通知UI更新的逻辑是正确的
  await ConfigService().loadConfig();

  // 设置初始入口页面
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: mode,
          home: GradientBackground(
            child: const MainScaffold(),
          ),
        );
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = ConfigService().entryPage.index;

  void _onSegmentChanged(Set<int> s) async {
    final idx = s.first;
    setState(() => _currentIndex = idx);
    await ConfigService().setEntryPage(AppEntryPage.values[idx]);
  }

  Widget _buildAnniversaryPage() {
    switch (ConfigService().layoutMode) {
      case AppLayoutMode.grid:
        return const AnniversaryGridPage();
      case AppLayoutMode.carousel:
        return const AnniversaryCarouselPage();
      case AppLayoutMode.list:
        return const AnniversaryPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLayoutMode>(
      valueListenable: layoutModeNotifier,
      builder: (context, layoutMode, _) {
        final pages = [
          const CountdownPage(),
          _buildAnniversaryPage(),
          ClockPage(showAppBarNotifier: showAppBarNotifier),
        ];
        return ValueListenableBuilder<bool>(
          valueListenable: showAppBarNotifier,
          builder: (context, showAppBar, _) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: showAppBar
                  ? AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      surfaceTintColor: Colors.transparent,
                      leading: IconButton(
                        icon: const Icon(Icons.settings),
                        tooltip: '设置',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const SettingsPage()),
                          );
                        },
                      ),
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: IntrinsicWidth(
                          child: SegmentedButton<int>(
                            segments: [
                              ButtonSegment(
                                value: 0,
                                icon: Tooltip(
                                  message: '倒计时',
                                  child: Icon(
                                    Icons.timer,
                                    color: _currentIndex == 0
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white)
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              ButtonSegment(
                                value: 1,
                                icon: Tooltip(
                                  message: '纪念日',
                                  child: Icon(
                                    Icons.event,
                                    color: _currentIndex == 1
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white)
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              ButtonSegment(
                                value: 2,
                                icon: Tooltip(
                                  message: '时钟',
                                  child: Icon(
                                    Icons.access_time,
                                    color: _currentIndex == 2
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white)
                                        : (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            ],
                            selected: {_currentIndex},
                            onSelectionChanged: _onSegmentChanged,
                            showSelectedIcon: false,
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide.none, // 移除边框
                                ),
                              ),
                              side: MaterialStateProperty.all(
                                  BorderSide.none), // 移除边框
                              backgroundColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                      (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.85);
                                }
                                return Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.7);
                              }),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                      (states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Theme.of(context)
                                      .colorScheme
                                      .onPrimary;
                                }
                                return Theme.of(context).colorScheme.onSurface;
                              }),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(horizontal: 8)),
                              minimumSize:
                                  MaterialStateProperty.all(const Size(0, 40)),
                              elevation: MaterialStateProperty.all(0), // 去除阴影
                              overlayColor: MaterialStateProperty.all(
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.08),
                              ),
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      actions: [
                        if (_currentIndex == 0)
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: '新增倒计时',
                            onPressed: () {
                              CountdownPage.showAddTimerSheet?.call(context);
                            },
                          ),
                        if (_currentIndex == 1)
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: '新增纪念日',
                            onPressed: () {
                              switch (ConfigService().layoutMode) {
                                case AppLayoutMode.list:
                                  if (AnniversaryPage.addAnniversary != null) {
                                    AnniversaryPage.addAnniversary!(context);
                                  }
                                  break;
                                case AppLayoutMode.grid:
                                  if (AnniversaryGridPage.addAnniversary !=
                                      null) {
                                    AnniversaryGridPage
                                        .addAnniversary!(context);
                                  }
                                  break;
                                case AppLayoutMode.carousel:
                                  if (AnniversaryCarouselPage.addAnniversary !=
                                      null) {
                                    AnniversaryCarouselPage
                                        .addAnniversary!(context);
                                  }
                                  break;
                              }
                            },
                          ),
                      ],
                    )
                  : null,
              body: pages[_currentIndex],
            );
          },
        );
      },
    );
  }
}

// ConfigService.setTimeFormat时同步通知
