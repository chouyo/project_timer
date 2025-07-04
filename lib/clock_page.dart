import 'package:flutter/material.dart';
import 'clocks/text_clock.dart';
import 'clocks/analog_clock.dart';
import 'clocks/date_display.dart';
import 'clocks/ampm_display.dart';
import 'config_service.dart';

class ClockPage extends StatefulWidget {
  final ValueNotifier<bool>? showAppBarNotifier;
  const ClockPage({super.key, this.showAppBarNotifier});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;
    double analogClockSize = 240;
    double spacing = 32;
    if (isDesktop) {
      analogClockSize = 320;
    } else if (isTablet) {
      analogClockSize = 240;
    }
    return Scaffold(
      appBar: null, // 由MainScaffold控制
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onDoubleTap: () {
          if (widget.showAppBarNotifier != null) {
            widget.showAppBarNotifier!.value =
                !widget.showAppBarNotifier!.value;
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 56),
                Center(
                  child: DateDisplay(
                    format: 'yyyy.MM.dd EEEE',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Center(
                  child: ValueListenableBuilder<AppTimeFormat>(
                    valueListenable: timeFormatNotifier,
                    builder: (context, format, _) {
                      return TextClock(
                        fontSize: 46,
                        is24HourFormat: format == AppTimeFormat.h24,
                      );
                    },
                  ),
                ),
                SizedBox(height: spacing),
                SizedBox(
                  width: analogClockSize,
                  height: analogClockSize,
                  child: const AnalogClock(),
                ),
                SizedBox(height: spacing),
                AmPmDisplay(
                    style: TextStyle(
                  fontFamily: 'Orbitron-Regular',
                  fontSize: 140,
                  color: Colors.grey.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}
