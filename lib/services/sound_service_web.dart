import 'dart:js_interop';

@JS('playClickSound')
external void _playClickSound();

@JS('playCorrectSound')
external void _playCorrectSound();

@JS('playWrongSound')
external void _playWrongSound();

@JS('playCoinSound')
external void _playCoinSound();

@JS('playBadgeFanfareSound')
external void _playBadgeFanfareSound();

void playPlatformClick() {
  try {
    _playClickSound();
  } catch (_) {}
}

void playPlatformCorrect() {
  try {
    _playCorrectSound();
  } catch (_) {}
}

void playPlatformWrong() {
  try {
    _playWrongSound();
  } catch (_) {}
}

void playPlatformCoin() {
  try {
    _playCoinSound();
  } catch (_) {}
}

void playPlatformBadgeFanfare() {
  try {
    _playBadgeFanfareSound();
  } catch (_) {}
}
