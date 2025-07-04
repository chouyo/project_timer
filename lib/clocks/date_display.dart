import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 实时更新的日期组件，跨天自动刷新
class DateDisplay extends StatefulWidget {
  final TextStyle? style;
  final String? format; // 例如 'yyyy-MM-dd EEEE'
  const DateDisplay({Key? key, this.style, this.format}) : super(key: key);

  @override
  State<DateDisplay> createState() => _DateDisplayState();
}

class _DateDisplayState extends State<DateDisplay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  DateTime _now = DateTime.now();
  String get _dateString {
    final d = _now;
    final format = widget.format ?? 'yyyy-MM-dd EEEE';
    // 简单格式化（可用intl扩展）
    return format
        .replaceAll('yyyy', d.year.toString())
        .replaceAll('MM', d.month.toString().padLeft(2, '0'))
        .replaceAll('dd', d.day.toString().padLeft(2, '0'))
        .replaceAll('EEEE', _weekdayString(d.weekday));
  }

  static String _weekdayString(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      final now = DateTime.now();
      if (now.day != _now.day ||
          now.month != _now.month ||
          now.year != _now.year) {
        setState(() => _now = now);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _dateString,
      style: widget.style ??
          Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
              ),
    );
  }
}
