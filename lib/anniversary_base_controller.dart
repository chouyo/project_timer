import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_timer/anniversary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_timer/date_picker_field.dart';
import 'dart:ui';
import 'dart:io';

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
    DateTime selectedDate = isEdit ? ann.date : DateTime.now();
    String? selectedImageLocalPath = isEdit ? ann.imageLocalPath : null;
    String? selectedImageNetworkUrl = isEdit ? ann.imageNetworkUrl : null;
    final nameController = TextEditingController(text: name);
    final imagePicker = ImagePicker();

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
                                  final now = DateTime.now();
                                  Navigator.of(context).pop(
                                    Anniversary(
                                      id: isEdit ? ann.id : null,
                                      name: annName,
                                      date: selectedDate,
                                      imageLocalPath: selectedImageLocalPath,
                                      imageNetworkUrl: selectedImageNetworkUrl,
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
                          // 图片选择入口
                          if (selectedImageLocalPath == null &&
                              selectedImageNetworkUrl == null)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        final pickedFile =
                                            await imagePicker.pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (pickedFile != null) {
                                          setStateSheet(() {
                                            selectedImageLocalPath =
                                                pickedFile.path;
                                            selectedImageNetworkUrl = null;
                                          });
                                        }
                                      } catch (e) {
                                        debugPrint('Error picking image: $e');
                                      }
                                    },
                                    icon: const Icon(Icons.image),
                                    label: const Text('本地图库'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () {
                                      // TODO: 实现网络图片选择功能
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text('网络图片功能即将推出')),
                                      );
                                    },
                                    icon: const Icon(Icons.link),
                                    label: const Text('网络图片'),
                                  ),
                                ),
                              ],
                            ),
                          if (selectedImageLocalPath != null) ...[
                            //const SizedBox(height: 12),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(selectedImageLocalPath!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '已选择本地图片',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setStateSheet(() {
                                    selectedImageLocalPath = null;
                                  }),
                                  icon: const Icon(Icons.cancel),
                                ),
                              ],
                            ),
                          ] else if (selectedImageNetworkUrl != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedImageNetworkUrl!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setStateSheet(() {
                                    selectedImageNetworkUrl = null;
                                  }),
                                  child: const Text('取消'),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          // 日期选择器
                          DatePickerField(
                            initialDate: selectedDate,
                            labelText: '选择日期',
                            onDateChanged: (date) {
                              selectedDate = date;
                            },
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
