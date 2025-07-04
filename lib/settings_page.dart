import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // 设为不透明
        elevation: Theme.of(context).appBarTheme.elevation,
        surfaceTintColor: Theme.of(context).appBarTheme.surfaceTintColor,
        centerTitle: true,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: Builder(
        builder: (context) {
          final top = MediaQuery.of(context).padding.top + 16;
          return ListView(
            padding: EdgeInsets.only(top: top, left: 16, right: 16),
            children: [
              // 分组1：通用
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('通用',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Material(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.color_lens_outlined),
                      title: const Text('主题模式', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeModeSheet(context),
                    ),
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                      secondary:
                          const Icon(Icons.screen_lock_portrait_outlined),
                      title: const Text('屏幕常亮', style: TextStyle(fontSize: 15)),
                      value: ConfigService().keepScreenOn,
                      onChanged: (v) async {
                        await ConfigService().setKeepScreenOn(v);
                        (context as Element).markNeedsBuild();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // 分组2：倒计时设置
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('倒计时',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Material(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.sort),
                      title: const Text('排序方式', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showCountdownSortSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // 分组3：纪念日设置
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('纪念日',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Material(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.view_quilt_outlined),
                      title: const Text('布局模式', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showLayoutModeSheet(context),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.sort),
                      title: const Text('排序方式', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAnniversarySortSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // 分组4：时钟设置
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('时钟',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Material(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.access_time_outlined),
                      title: const Text('时间制式', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showTimeFormatSheet(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // 分组5：关于
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('关于',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ),
              Material(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                elevation: 1,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.info_outline),
                      title: const Text('关于我', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      minVerticalPadding: 8,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('隐私', style: TextStyle(fontSize: 15)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _launchPrivacyUrl(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showThemeModeSheet(BuildContext context) {
    final config = ConfigService();
    AppThemeMode current = config.themeMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), // 底部多留空间
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('主题模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<AppThemeMode>(
                title: const Text('跟随系统'),
                value: AppThemeMode.system,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setThemeMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('亮色模式'),
                value: AppThemeMode.light,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setThemeMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppThemeMode>(
                title: const Text('暗色模式'),
                value: AppThemeMode.dark,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setThemeMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24), // popup底部额外空白
            ],
          ),
        );
      },
    );
  }

  void _showLayoutModeSheet(BuildContext context) {
    final config = ConfigService();
    AppLayoutMode current = config.layoutMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('布局模式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<AppLayoutMode>(
                title: const Text('列表'),
                value: AppLayoutMode.list,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setLayoutMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppLayoutMode>(
                title: const Text('网格'),
                value: AppLayoutMode.grid,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setLayoutMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppLayoutMode>(
                title: const Text('轮播'),
                value: AppLayoutMode.carousel,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setLayoutMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showTimeFormatSheet(BuildContext context) {
    final config = ConfigService();
    AppTimeFormat current = config.timeFormat;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('时间制式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<AppTimeFormat>(
                title: const Text('24小时制'),
                value: AppTimeFormat.h24,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setTimeFormat(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppTimeFormat>(
                title: const Text('12小时制'),
                value: AppTimeFormat.h12,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setTimeFormat(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('关于我'),
          content: const Text(
              'Time Matter\n\nBy XYOL Studio\nxyolstudio@gmail.com\n\n版本：1.0.0'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _launchPrivacyUrl() async {
    const url = 'https://www.baidu.com'; // 替换为你的隐私政策链接
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showCountdownSortSheet(BuildContext context) {
    final config = ConfigService();
    AppListSortMode current = config.countdownSortMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('倒计时排序方式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<AppListSortMode>(
                title: const Text('按新增时间升序'),
                value: AppListSortMode.createdAsc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setCountdownSortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按新增时间降序'),
                value: AppListSortMode.createdDesc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setCountdownSortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按修改时间升序'),
                value: AppListSortMode.updatedAsc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setCountdownSortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按修改时间降序'),
                value: AppListSortMode.updatedDesc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setCountdownSortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAnniversarySortSheet(BuildContext context) {
    final config = ConfigService();
    AppListSortMode current = config.anniversarySortMode;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('纪念日排序方式',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              RadioListTile<AppListSortMode>(
                title: const Text('按新增时间升序'),
                value: AppListSortMode.createdAsc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按新增时间降序'),
                value: AppListSortMode.createdDesc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按修改时间升序'),
                value: AppListSortMode.updatedAsc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按修改时间降序'),
                value: AppListSortMode.updatedDesc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按纪念日升序'),
                value: AppListSortMode.dateAsc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<AppListSortMode>(
                title: const Text('按纪念日降序'),
                value: AppListSortMode.dateDesc,
                groupValue: current,
                onChanged: (v) async {
                  if (v != null) {
                    await config.setAnniversarySortMode(v);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
