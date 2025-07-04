import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';

class AnalogClock extends StatefulWidget {
  const AnalogClock({super.key});

  @override
  State<AnalogClock> createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      setState(() {
        _now = DateTime.now();
      });
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
    final size = MediaQuery.of(context).size;
    final clockSize = size.width * 0.8;
    return Center(
      child: SizedBox(
        width: clockSize,
        height: clockSize,
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: _AnalogClockPainter(_now, Theme.of(context)),
          ),
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime datetime;
  final ThemeData theme;
  _AnalogClockPainter(this.datetime, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paintCircle = Paint()
      ..color = theme.colorScheme.surface.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final paintBorder = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, paintCircle);
    canvas.drawCircle(center, radius, paintBorder);

    // Draw hour marks
    final markPaint = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.5)
      ..strokeWidth = 2;
    for (int i = 0; i < 12; i++) {
      final angle = 2 * pi * i / 12;
      final p1 = center + Offset(cos(angle), sin(angle)) * (radius - 10);
      final p2 = center + Offset(cos(angle), sin(angle)) * (radius - 20);
      canvas.drawLine(p1, p2, markPaint);
    }

    // Hour hand
    final hourAngle =
        2 * pi * ((datetime.hour % 12) / 12 + datetime.minute / 720) - pi / 2;
    final hourHand = Paint()
      ..color = theme.colorScheme.onSurface
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center,
        center + Offset(cos(hourAngle), sin(hourAngle)) * (radius * 0.5),
        hourHand);

    // Minute hand
    final minuteAngle =
        2 * pi * (datetime.minute / 60 + datetime.second / 3600) - pi / 2;
    final minuteHand = Paint()
      ..color = theme.colorScheme.onSurface.withOpacity(0.8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center,
        center + Offset(cos(minuteAngle), sin(minuteAngle)) * (radius * 0.7),
        minuteHand);

    // Second hand
    final secondAngle =
        2 * pi * (datetime.second / 60 + datetime.millisecond / 60000) - pi / 2;
    final secondHand = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        center,
        center + Offset(cos(secondAngle), sin(secondAngle)) * (radius * 0.85),
        secondHand);

    // Center dot
    final dotPaint = Paint()..color = theme.colorScheme.primary;
    canvas.drawCircle(center, 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
