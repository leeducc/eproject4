import 'package:flutter_tts/flutter_tts.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();

  Function()? onStart;
  Function()? onComplete;

  Future init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(0.9);

    _tts.setStartHandler(() {
      if (onStart != null) onStart!();
    });

    _tts.setCompletionHandler(() {
      if (onComplete != null) onComplete!();
    });
  }

  Future speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future stop() async {
    await _tts.stop();
  }
}