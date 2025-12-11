import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_timer/anniversary_carousel_page.dart';
import 'package:project_timer/anniversary_grid_page.dart';
import 'anniversary_service.dart';
import 'gradient_background.dart';
import 'anniversary_page.dart';
import 'settings_page.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'config_service.dart';
import 'app_themes.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'native_timezone_channel.dart';
import 'notification_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    await NotificationHelper.init();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    // 初始化时区
    tz.initializeTimeZones();
    final String ianaName = await NativeTimezoneChannel.getLocalTimezone();
    debugPrint('Local IANA timezone: $ianaName');
    tz.setLocalLocation(tz.getLocation(ianaName));
  }

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
        final page = _buildAnniversaryPage();
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.settings),
              tooltip: '设置',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
            actions: [
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
                      if (AnniversaryGridPage.addAnniversary != null) {
                        AnniversaryGridPage.addAnniversary!(context);
                      }
                      break;
                    case AppLayoutMode.carousel:
                      if (AnniversaryCarouselPage.addAnniversary != null) {
                        AnniversaryCarouselPage.addAnniversary!(context);
                      }
                      break;
                  }
                },
              ),
            ],
          ),
          body: page,
        );
      },
    );
  }
}

// ConfigService.setTimeFormat时同步通知
