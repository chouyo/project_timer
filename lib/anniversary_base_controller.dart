import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:project_timer/anniversary_service.dart';
import 'dart:ui';

/// 纪念日相关页面的通用Controller基类，便于后续扩展业务逻辑
abstract class AnniversaryBaseController<T extends StatefulWidget>
    extends State<T> {
  final AnniversaryService anniversaryService = AnniversaryService();

  Center noAnniversary(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cake_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 24),
          Text('暂无纪念日',
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('点击右上角 “+” 或下方按钮新增纪念日',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
            label: const Text('新增纪念日'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: showAnniversarySheet,
          ),
        ],
      ),
    );
  }

  // 新增和编辑纪念日弹窗
  Future<void> showAnniversarySheet({Anniversary? ann}) async {
    final isEdit = ann != null;
    String name = isEdit ? ann.name : '';
    DateTime date = isEdit ? ann.date : DateTime.now();
    int selectedYear = date.year;
    int selectedMonth = date.month;
    int selectedDay = date.day;
    int selectedImageIndex = 0;
    final imageAssets = AnniversaryService.imageAssets;
    if (isEdit &&
        ann.imageAsset != null &&
        imageAssets.contains(ann.imageAsset)) {
      selectedImageIndex = imageAssets.indexOf(ann.imageAsset!);
    }
    final nameController = TextEditingController(text: name);

    await showModalBottomSheet<Anniversary>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 磨砂弹窗
      barrierColor: Colors.black38,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                    builder: (context, setStateSheet) {
                      int daysInMonth =
                          DateTime(selectedYear, selectedMonth + 1, 0).day;
                      if (selectedDay > daysInMonth) selectedDay = daysInMonth;
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
                                isEdit ? '编辑纪念日' : '新增纪念日',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  final annName =
                                      nameController.text.trim().isEmpty
                                          ? '某天'
                                          : nameController.text.trim();
                                  final newDate = DateTime(
                                      selectedYear, selectedMonth, selectedDay);
                                  final imgAsset =
                                      imageAssets[selectedImageIndex];
                                  final now = DateTime.now();
                                  Navigator.of(context).pop(
                                    Anniversary(
                                      id: isEdit ? ann.id : null,
                                      name: annName,
                                      date: newDate,
                                      imageAsset: imgAsset,
                                      createdAt: isEdit ? ann.createdAt : now,
                                      updatedAt: now,
                                    ),
                                  );
                                },
                                child: const Text('确定'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                labelText: '事件名称',
                                border: OutlineInputBorder()),
                            onChanged: (v) => name = v,
                          ),
                          const SizedBox(height: 16),
                          // 图片选择器
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: imageAssets.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                return GestureDetector(
                                  onTap: () => setStateSheet(
                                      () => selectedImageIndex = idx),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.asset(
                                          imageAssets[idx],
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (selectedImageIndex == idx)
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              width: 3,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  const Text('年'),
                                  NumberPicker(
                                    minValue: 1900,
                                    maxValue: 2100,
                                    value: selectedYear,
                                    onChanged: (v) {
                                      HapticFeedback.lightImpact();
                                      setStateSheet(() => selectedYear = v);
                                    },
                                    infiniteLoop: true, // 允许循环滚动
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  const Text('月'),
                                  NumberPicker(
                                    minValue: 1,
                                    maxValue: 12,
                                    value: selectedMonth,
                                    onChanged: (v) {
                                      HapticFeedback.lightImpact();
                                      setStateSheet(() => selectedMonth = v);
                                    },
                                    infiniteLoop: true, // 允许循环滚动
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  const Text('日'),
                                  NumberPicker(
                                    minValue: 1,
                                    maxValue: daysInMonth,
                                    value: selectedDay,
                                    onChanged: (v) {
                                      HapticFeedback.lightImpact();
                                      setStateSheet(() => selectedDay = v);
                                    },
                                    infiniteLoop: true, // 允许循环滚动
                                  ),
                                ],
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
    ).then((result) {
      if (result != null) {
        if (isEdit) {
          // 编辑
          final list = List<Anniversary>.from(anniversaryService.anniversaries);
          final idx = list.indexWhere((a) => a.id == ann.id);
          if (idx != -1) {
            list[idx] = result;
            anniversaryService.anniversariesNotifier.value = list;
            anniversaryService.saveAnniversaries();
          }
        } else {
          // 新增
          anniversaryService.addAnniversary(result);
        }
      }
    });
  }

  void deleteAnniversary(int index) async {
    anniversaryService.removeAnniversary(index);
  }

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";
  }

  String weekdayString(DateTime date) {
    const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    return weekdays[date.weekday - 1];
  }

  String daysDiffString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final diff = eventDay.difference(today).inDays;
    return diff.toString();
  }

  String daysDiffLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    final diff = eventDay.difference(today).inDays;
    if (diff == 0) return '就是今天';
    if (diff > 0) return '还有';
    return '已过去';
  }

  String formatDayNumber(String dayStr) {
    final num = int.tryParse(dayStr) ?? 0;
    if (num == 0) return '0';
    if (num < 0) return (-num).toString();
    return num.toString();
  }

  Widget buildDaysDiffNumber(String text, {TextStyle? style}) {
    final formatted = formatDayNumber(text);
    if (formatted.isEmpty) return const SizedBox.shrink();
    return Text(
      formatted,
      style: style ??
          const TextStyle(
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
            color: Colors.white,
            fontFamily: 'Orbitron-Regular',
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  String dayUnitLabel(String dayStr) {
    final n = formatDayNumber(dayStr);
    return (n == '1' || n == '0') ? 'DAY' : 'DAYS';
  }
}
