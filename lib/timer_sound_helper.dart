import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class TimerSoundHelper {
  // static final AudioPlayer _player = AudioPlayer();
  static final FlutterRingtonePlayer _player = FlutterRingtonePlayer();

  static Future<void> playFinishSound() async {
    try {
      // await _player.play(AssetSource('sounds/timer_finish.mp3'));
      await _player.playAlarm(
        volume: 0.5,
        looping: false,
        asAlarm: true,
      );
    } catch (e) {
      // ignore error
    }
  }
}
