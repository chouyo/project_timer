import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

/// 日期选择器输入框组件
/// 点击输入框弹出年月日选择器
class DatePickerField extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final String? labelText;
  final InputDecoration? decoration;

  const DatePickerField({
    super.key,
    required this.initialDate,
    required this.onDateChanged,
    this.labelText,
    this.decoration,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
    _selectedDay = widget.initialDate.day;
    _controller = TextEditingController(text: _formatDate());
  }

  @override
  void didUpdateWidget(DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedYear = widget.initialDate.year;
      _selectedMonth = widget.initialDate.month;
      _selectedDay = widget.initialDate.day;
      _controller.text = _formatDate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate() {
    return '$_selectedYear年$_selectedMonth月$_selectedDay日';
  }

  void _updateDate() {
    final newDate = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    _controller.text = _formatDate();
    widget.onDateChanged(newDate);
  }

  Future<void> _showDatePicker() async {
    // 临时变量用于弹窗内选择
    int tempYear = _selectedYear;
    int tempMonth = _selectedMonth;
    int tempDay = _selectedDay;

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            int daysInMonth = DateTime(tempYear, tempMonth + 1, 0).day;
            if (tempDay > daysInMonth) tempDay = daysInMonth;

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('取消'),
                          ),
                          const Text(
                            '选择日期',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // 年月日选择器
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 年
                          Column(
                            children: [
                              const Text('年',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              NumberPicker(
                                minValue: 1900,
                                maxValue: 2100,
                                value: tempYear,
                                onChanged: (v) {
                                  HapticFeedback.lightImpact();
                                  setStateSheet(() => tempYear = v);
                                },
                                infiniteLoop: true,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // 月
                          Column(
                            children: [
                              const Text('月',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              NumberPicker(
                                minValue: 1,
                                maxValue: 12,
                                value: tempMonth,
                                onChanged: (v) {
                                  HapticFeedback.lightImpact();
                                  setStateSheet(() => tempMonth = v);
                                },
                                infiniteLoop: true,
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // 日
                          Column(
                            children: [
                              const Text('日',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              NumberPicker(
                                minValue: 1,
                                maxValue: daysInMonth,
                                value: tempDay,
                                onChanged: (v) {
                                  HapticFeedback.lightImpact();
                                  setStateSheet(() => tempDay = v);
                                },
                                infiniteLoop: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _selectedYear = tempYear;
          _selectedMonth = tempMonth;
          _selectedDay = tempDay;
          _updateDate();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDatePicker,
      child: AbsorbPointer(
        child: TextField(
          controller: _controller,
          readOnly: true,
          decoration: widget.decoration ??
              InputDecoration(
                labelText: widget.labelText ?? '选择日期',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
        ),
      ),
    );
  }
}
