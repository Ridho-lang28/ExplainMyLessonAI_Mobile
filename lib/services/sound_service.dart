import 'sound_service_stub.dart'
    if (dart.library.js_interop) 'sound_service_web.dart';

/// Layanan Efek Suara Interaktif (Persis Web Sound Effects)
/// Menggunakan Web Audio API untuk suara game arcade yang renyah dan empuk
class SoundService {
  /// Suara klik tombol bubbly pop Mario/Nintendo
  static void playClick() {
    playPlatformClick();
  }

  /// Suara selebrasi jawaban benar (Fanfare nada mayor C-Major)
  static void playCorrect() {
    playPlatformCorrect();
  }

  /// Suara jawaban salah (Buzzer TET-TET + kartun boing)
  static void playWrong() {
    playPlatformWrong();
  }

  /// Suara hujan koin emas bertambah
  static void playCoin() {
    playPlatformCoin();
  }

  /// Suara fanfare perolehan lencana prestasi
  static void playBadgeFanfare() {
    playPlatformBadgeFanfare();
  }
}
