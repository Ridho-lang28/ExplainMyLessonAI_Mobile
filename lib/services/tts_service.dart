import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isPlaying = false;
  String? _currentlySpeakingText;
  VoidCallback? _onCompleteCallback;

  bool get isPlaying => _isPlaying;
  String? get currentlySpeakingText => _currentlySpeakingText;

  final ValueNotifier<bool> playingStateNotifier = ValueNotifier<bool>(false);

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _flutterTts = FlutterTts();

      await _flutterTts!.setLanguage("id-ID");
      await _flutterTts!.setSpeechRate(0.48); // Kecepatan ramah anak SD
      await _flutterTts!.setPitch(1.05); // Nada ceria & hangat
      await _flutterTts!.setVolume(1.0);

      _flutterTts!.setStartHandler(() {
        _isPlaying = true;
        playingStateNotifier.value = true;
      });

      _flutterTts!.setCompletionHandler(() {
        _isPlaying = false;
        _currentlySpeakingText = null;
        playingStateNotifier.value = false;
        _onCompleteCallback?.call();
      });

      _flutterTts!.setCancelHandler(() {
        _isPlaying = false;
        _currentlySpeakingText = null;
        playingStateNotifier.value = false;
      });

      _flutterTts!.setErrorHandler((msg) {
        debugPrint("TTS Error: $msg");
        _isPlaying = false;
        _currentlySpeakingText = null;
        playingStateNotifier.value = false;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint("TTS init failed (fallback mode active): $e");
    }
  }

  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    _onCompleteCallback = onComplete;
    final cleanText = _sanitizeText(text);

    if (_flutterTts == null) {
      await init();
    }

    try {
      if (_isPlaying) {
        await stop();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _currentlySpeakingText = cleanText;
      _isPlaying = true;
      playingStateNotifier.value = true;

      if (_flutterTts != null) {
        await _flutterTts!.speak(cleanText);
      } else {
        // Fallback simulation timer if platform has no TTS engine
        Future.delayed(const Duration(seconds: 4), () {
          if (_isPlaying) {
            _isPlaying = false;
            playingStateNotifier.value = false;
            onComplete?.call();
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal memutar suara TTS: $e");
      _isPlaying = false;
      playingStateNotifier.value = false;
    }
  }

  Future<void> stop() async {
    try {
      if (_flutterTts != null) {
        await _flutterTts!.stop();
      }
    } catch (e) {
      debugPrint("Stop TTS error: $e");
    } finally {
      _isPlaying = false;
      _currentlySpeakingText = null;
      playingStateNotifier.value = false;
    }
  }

  String _sanitizeText(String text) {
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]', unicode: true), '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('·', '')
        .trim();
  }
}
