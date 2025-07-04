import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// 动态AM/PM显示组件
class AmPmDisplay extends StatefulWidget {
  final TextStyle? style;
  const AmPmDisplay({Key? key, this.style}) : super(key: key);

  @override
  State<AmPmDisplay> createState() => _AmPmDisplayState();
}

class _AmPmDisplayState extends State<AmPmDisplay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  String _ampm = '';

  @override
  void initState() {
    super.initState();
    _ampm = _getAmPm(DateTime.now());
    _ticker = createTicker((_) {
      final now = DateTime.now();
      final ampm = _getAmPm(now);
      if (ampm != _ampm) {
        setState(() => _ampm = ampm);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  String _getAmPm(DateTime dt) => dt.hour < 12 ? 'AM' : 'PM';

  @override
  Widget build(BuildContext context) {
    return Text(
      _ampm,
      style: widget.style ??
          TextStyle(
            fontFamily: 'Orbitron-Regular',
            fontSize: 140,
            color: Colors.grey.shade600.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
    );
  }
}
