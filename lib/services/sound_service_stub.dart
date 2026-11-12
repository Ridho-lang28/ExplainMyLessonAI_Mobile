import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const MethodChannel _soundChannel = MethodChannel('com.explainmylesson/sound');

void _invokeNativeSound(String method) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  try {
    _soundChannel.invokeMethod<void>(method).catchError((_) {});
  } catch (_) {}
}

void playPlatformClick() {
  _invokeNativeSound('playClick');
  HapticFeedback.lightImpact();
}

void playPlatformCorrect() {
  _invokeNativeSound('playCorrect');
  HapticFeedback.mediumImpact();
}

void playPlatformWrong() {
  _invokeNativeSound('playWrong');
  HapticFeedback.heavyImpact();
}

void playPlatformCoin() {
  _invokeNativeSound('playCoin');
  HapticFeedback.lightImpact();
}

void playPlatformBadgeFanfare() {
  _invokeNativeSound('playBadgeFanfare');
  HapticFeedback.mediumImpact();
}
