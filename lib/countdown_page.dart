import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/services.dart';
import 'package:project_timer/marquee_text.dart';
import 'package:project_timer/timer_service.dart';
import 'config_service.dart';

class CountdownPage extends StatefulWidget {
  const CountdownPage({Key? key}) : super(key: key);

  // 提供静态回调注册
  static void Function(BuildContext context)? showAddTimerSheet;

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage>
    with WidgetsBindingObserver {
  final TimerService _timerService = TimerService();
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    CountdownPage.showAddTimerSheet = (ctx) => _showAddTimerSheetWrapper(ctx);
    // 监听排序方式变化，重新排序
    countdownSortModeNotifier.addListener(_sortTimersByMode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (CountdownPage.showAddTimerSheet != null) {
      CountdownPage.showAddTimerSheet = null;
    }
    countdownSortModeNotifier.removeListener(_sortTimersByMode);
    // 不再调用 _timerService.dispose(); 保证倒计时持续
    super.dispose();
  }

  void _sortTimersByMode() {
    final timers = List<TimerData>.from(_timerService.timersNotifier.value);
    final sortMode = countdownSortModeNotifier.value;
    timers.sort((a, b) {
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
    _timerService.timersNotifier.value = timers;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 不做任何处理，保持定时器运行即可
    // 可选：如需后台静音可在此处理
  }

  Future<void> showTimerSheet({TimerData? timer}) async {
    final isEdit = timer != null;
    int selectedHour = isEdit ? timer.totalSeconds ~/ 3600 : 0;
    int selectedMinute = isEdit ? (timer.totalSeconds % 3600) ~/ 60 : 0;
    int selectedSecond = isEdit ? (timer.totalSeconds % 60) : 0;
    int selectedColorIndex = isEdit ? _colorOptions.indexOf(timer.color) : 0;
    if (selectedColorIndex == -1) selectedColorIndex = 0;
    final TextEditingController nameController =
        TextEditingController(text: isEdit ? timer.name : '');
    final result = await showModalBottomSheet<TimerData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: Theme.of(context).cardColor.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.95
                        : 0.7),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('取消'),
                              ),
                              Text(
                                isEdit ? '编辑倒计时' : '新增倒计时',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  int totalSeconds = selectedHour * 3600 +
                                      selectedMinute * 60 +
                                      selectedSecond;
                                  if (totalSeconds == 0) {
                                    OverlayEntry? entry;
                                    entry = OverlayEntry(
                                      builder: (context) => Positioned(
                                        top:
                                            MediaQuery.of(context).padding.top +
                                                6,
                                        left: 48,
                                        right: 48,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withOpacity(0.92),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              '倒计时时间不能为0',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                    Overlay.of(context).insert(entry);
                                    Future.delayed(const Duration(seconds: 2),
                                        () => entry?.remove());
                                    return;
                                  }
                                  final now = DateTime.now();
                                  Navigator.of(context).pop(TimerData(
                                    id: isEdit ? timer.id : null,
                                    name: nameController.text.trim().isEmpty
                                        ? '某事'
                                        : nameController.text.trim(),
                                    totalSeconds: totalSeconds,
                                    remainingSeconds: totalSeconds,
                                    isFinished: false,
                                    isRunning: false,
                                    color: _colorOptions[selectedColorIndex],
                                    createdAt: isEdit ? timer.createdAt : now,
                                    updatedAt: now,
                                  ));
                                },
                                child: const Text('确认'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: '倒计时名称',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(_colorOptions.length, (i) {
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => selectedColorIndex = i),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Color.alphaBlend(
                                              Colors.black.withOpacity(0.5),
                                              _colorOptions[i])
                                          : _colorOptions[i],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedColorIndex == i
                                            ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.grey.shade400
                                                : Colors.black)
                                            : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('小时'),
                                    NumberPicker(
                                      minValue: 0,
                                      maxValue: 23,
                                      value: selectedHour,
                                      onChanged: (value) {
                                        HapticFeedback.lightImpact();
                                        setState(() => selectedHour = value);
                                      },
                                      infiniteLoop: true, // 允许循环滚动
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('分钟'),
                                    NumberPicker(
                                      minValue: 0,
                                      maxValue: 59,
                                      value: selectedMinute,
                                      onChanged: (value) {
                                        HapticFeedback.lightImpact();
                                        setState(() => selectedMinute = value);
                                      },
                                      infiniteLoop: true, // 允许循环滚动
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('秒'),
                                    NumberPicker(
                                      minValue: 0,
                                      maxValue: 59,
                                      value: selectedSecond,
                                      onChanged: (value) {
                                        HapticFeedback.lightImpact();
                                        setState(() => selectedSecond = value);
                                      },
                                      infiniteLoop: true, // 允许循环滚动
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      if (isEdit) {
        final list = List<TimerData>.from(_timerService.timersNotifier.value);
        final idx = list.indexWhere((t) => t.id == timer.id);
        if (idx != -1) {
          list[idx] = result;
          // 新增：编辑后重新排序
          _sortTimersByModeWithList(list);
          _timerService.timersNotifier.value = list;
          _timerService.saveTimers();
        }
      } else {
        final list = List<TimerData>.from(_timerService.timersNotifier.value)
          ..add(result);
        // 新增：新增后重新排序
        _sortTimersByModeWithList(list);
        _timerService.timersNotifier.value = list;
        _timerService.saveTimers();
      }
    }
  }

  void _showAddTimerSheetWrapper(BuildContext ctx) {
    // 保证在当前页面context下弹出
    if (ModalRoute.of(context)?.isCurrent ?? true) {
      showTimerSheet();
    } else {
      Navigator.of(ctx)
          .push(MaterialPageRoute(builder: (_) => const CountdownPage()))
          .then((_) {
        // 新页面自动弹出
        showTimerSheet();
      });
    }
  }

  String _formatTime(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hStr = hours.toString().padLeft(2, '0');
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$hStr:$mStr:$sStr';
  }

  void _sortTimersByModeWithList(List<TimerData> list) {
    final sortMode = countdownSortModeNotifier.value;
    list.sort((a, b) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // 移除AppBar，交由MainScaffold统一管理
      body: ValueListenableBuilder<List<TimerData>>(
        valueListenable: _timerService.timersNotifier,
        builder: (context, timers, _) {
          if (timers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty,
                      size: 72, color: Colors.grey.shade400),
                  const SizedBox(height: 24),
                  Text(
                    '暂无倒计时',
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右上角 “+” 或下方按钮新增倒计时',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                    label: const Text('新增倒计时'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1,
                    ),
                    onPressed: showTimerSheet,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0, horizontal: 16.0), // 只在外部设置padding
            itemCount: timers.length,
            itemBuilder: (context, index) {
              final timer = timers[index];
              return Dismissible(
                key: ValueKey(timer.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 28),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                      const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await showTimerSheet(timer: timer);
                    return false; // 不真正滑走
                  }
                  return direction == DismissDirection.endToStart;
                },
                onDismissed: (_) {
                  _timerService.removeTimerById(timer.id);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final cardColor = isDark
                        ? Color.alphaBlend(
                            Colors.black.withOpacity(0.5), timer.color)
                        : timer.color;
                    return Card(
                      color: cardColor,
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0), // Card本身设置margin
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 80, // 固定高度，保证动画平滑
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 左列：名称+按钮
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 第一行：名称
                                    MarqueeText(
                                      text: timer.name,
                                      width: 120, // 可根据右侧剩余时间宽度适当调整
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      enableMarquee: true,
                                    ),
                                    const SizedBox(height: 8),
                                    // 第二行：按钮
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            icon: Icon(Icons.play_arrow),
                                            tooltip: '播放',
                                            onPressed: timer.isRunning ||
                                                    timer.isFinished
                                                ? null
                                                : () => _timerService
                                                    .startTimer(index),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            icon: Icon(Icons.pause),
                                            tooltip: '停止',
                                            onPressed: timer.isRunning
                                                ? () => _timerService
                                                    .stopTimer(index)
                                                : null,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40,
                                          child: IconButton(
                                            icon: Icon(Icons.replay),
                                            tooltip: '重新播放',
                                            onPressed: () =>
                                                _timerService.resetTimer(index),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // 右列：剩余时间
                              Container(
                                alignment: Alignment.centerRight,
                                height: 48,
                                constraints:
                                    const BoxConstraints(maxWidth: 160),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _formatTime(timer.remainingSeconds),
                                    style: const TextStyle(
                                      fontFamily: 'Orbitron-Regular',
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
