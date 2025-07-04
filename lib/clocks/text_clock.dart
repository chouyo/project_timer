import 'package:flutter/material.dart';
import 'dart:async';

class TextClock extends StatefulWidget {
  final double fontSize;
  final bool is24HourFormat;
  const TextClock({super.key, this.fontSize = 40, this.is24HourFormat = true});

  @override
  State<TextClock> createState() => _TextClockState();
}

class _TextClockState extends State<TextClock> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeStr;
    if (widget.is24HourFormat) {
      timeStr =
          "${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";
    } else {
      int hour = _now.hour % 12;
      if (hour == 0) hour = 12;
      timeStr =
          "$hour:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}";
    }
    return Text(
      timeStr,
      style: TextStyle(
        fontFamily: 'Orbitron-Regular',
        fontSize: widget.fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
