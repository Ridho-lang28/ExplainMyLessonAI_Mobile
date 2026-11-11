import 'package:flutter/services.dart';

void playPlatformClick() {
  SystemSound.play(SystemSoundType.click);
  HapticFeedback.lightImpact();
}

void playPlatformCorrect() {
  HapticFeedback.mediumImpact();
}

void playPlatformWrong() {
  HapticFeedback.heavyImpact();
}

void playPlatformCoin() {
  HapticFeedback.lightImpact();
}

void playPlatformBadgeFanfare() {
  HapticFeedback.mediumImpact();
}
