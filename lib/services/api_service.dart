import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/local_catalog.dart';
import '../models/notification_item.dart';
import '../models/quiz.dart';

class ApiService {
  // Backend Express berjalan di port 4000 (dari backend/server/index.ts)
  // Untuk Android Emulator gunakan 10.0.2.2, untuk Web/Desktop/iOS Simulator gunakan localhost
  // Untuk HP Fisik (USB/WiFi), set customBaseUrl ke IP LAN PC (misal: http://10.111.10.9:4000)
  static const int port = 4000;

  /// IP LAN PC kamu — dipakai otomatis saat di HP fisik tidak bisa konek via 10.0.2.2
  /// Ganti sesuai IP PC kamu (cek dengan: ipconfig | findstr IPv4)
  static const String _lanIp = '10.111.10.9';

  /// Custom Base URL (misalnya jika menggunakan HP fisik via IP WiFi atau test)
  static String? customBaseUrl;

  /// URL yang sudah terbukti bisa dipakai (di-cache setelah auto-detect berhasil)
  static String? _resolvedBaseUrl;

  static String get baseUrl {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      return customBaseUrl!;
    }
    // Gunakan URL yang sudah di-resolve sebelumnya (hasil auto-detect)
    if (_resolvedBaseUrl != null) {
      return _resolvedBaseUrl!;
    }
    if (kIsWeb) return 'http://localhost:$port';
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Default ke emulator; auto-detect dilakukan oleh initBaseUrl()
      return 'http://10.0.2.2:$port';
    }
    return 'http://localhost:$port';
  }

  /// Inisialisasi baseUrl dengan auto-detect: coba 10.0.2.2 (emulator) dulu,
  /// kalau gagal fallback ke IP LAN PC (untuk HP fisik via USB/WiFi).
  /// Panggil sekali saat app start (di main.dart / AppState.init).
  static Future<void> initBaseUrl() async {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) return;
    if (kIsWeb) {
      _resolvedBaseUrl = 'http://localhost:$port';
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android) {
      _resolvedBaseUrl = 'http://localhost:$port';
      return;
    }

    // Coba 10.0.2.2 (Android Emulator)
    final candidateUrls = [
      'http://10.0.2.2:$port',
      'http://$_lanIp:$port',
    ];

    for (final url in candidateUrls) {
      try {
        final uri = Uri.parse('$url/api/system/status');
        final res = await http.get(uri).timeout(const Duration(milliseconds: 1800));
        if (res.statusCode == 200) {
          _resolvedBaseUrl = url;
          debugPrint('[ApiService] Backend ditemukan di: $url');
          return;
        }
      } catch (_) {
        debugPrint('[ApiService] Tidak bisa konek ke $url, coba berikutnya...');
      }
    }

    // Jika semua gagal, tetap pakai default emulator (offline mode)
    _resolvedBaseUrl = 'http://10.0.2.2:$port';
    debugPrint('[ApiService] Semua backend tidak dapat dijangkau, mode offline.');
  }

  /// Cek apakah backend server sedang aktif/online
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/api/system/status');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Login siswa ke backend via POST /api/login
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/login');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim(),
              'password': password,
              'role': 'siswa',
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("API login error (fallback offline): $e");
    }
    return null;
  }

  /// Registrasi siswa baru ke backend via POST /api/register
  static Future<Map<String, dynamic>?> register({
    required String name,
    required String email,
    required String password,
    required String avatar,
    required String grade,
    required String school,
    String? nisn,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/register');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'email': email.trim(),
              'password': password,
              'role': 'siswa',
              'avatar': avatar,
              'grade': grade.trim(),
              'school': school.trim(),
              'nisn': nisn ?? '0084729102',
            }),
          )
          .timeout(const Duration(seconds: 3));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("API register error (fallback offline): $e");
    }
    return null;
  }

  /// Sinkronisasi pembaruan profil siswa ke backend via PUT /api/profile
  static Future<bool> updateProfile({
    required String name,
    required String avatar,
    required String grade,
    required String school,
    required String nisn,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/profile');
      final res = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name.trim(),
              'avatar': avatar,
              'grade': grade.trim(),
              'school': school.trim(),
              'nisn': nisn.trim(),
            }),
          )
          .timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("API updateProfile error (fallback offline): $e");
      return false;
    }
  }

  /// Mengambil bank soal kuis adaptif via GET /api/quiz?level=X
  /// Jika backend offline, otomatis fallback ke bank soal lokal
  static Future<List<Question>> fetchQuizQuestions(int level) async {
    try {
      final uri = Uri.parse('$baseUrl/api/quiz?level=$level');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['questions'] is List) {
          final list = data['questions'] as List;
          return list.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      debugPrint("API quiz offline, using local quiz questions: $e");
    }
    return LocalCatalog.quizQuestions[level] ?? [];
  }

  /// Sinkronisasi poin siswa ke backend via POST /api/students/points
  static Future<bool> syncPoints({
    required int amount,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/students/points');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              if (userId != null) 'userId': userId,
            }),
          )
          .timeout(const Duration(milliseconds: 1500));

      return res.statusCode == 200;
    } catch (e) {
      debugPrint("API sync points offline: $e");
      return false;
    }
  }

  /// Mengambil modul kurikulum aktif dari guru via GET /api/v1/curriculum/active
  static Future<Map<String, dynamic>?> fetchActiveValidatedModule() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/curriculum/active');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint("API active curriculum check: $e");
    }
    return null;
  }

  /// Mengambil seluruh daftar modul pembelajaran yang divalidasi/disubmit pengajar via GET /api/v1/curriculum/modules
  static Future<List<Map<String, dynamic>>> fetchCurriculumModules() async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/curriculum/modules');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is Map && data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'] as List);
        }
      }
    } catch (e) {
      debugPrint("API curriculum modules error: $e");
    }
    return [];
  }

  /// Mengambil konten materi AI via GET /api/ai-content?chapter=...&mode=...
  static Future<Map<String, dynamic>?> fetchAiContent(String chapterId, {String mode = 'cerita'}) async {
    try {
      final uri = Uri.parse('$baseUrl/api/ai-content?chapter=$chapterId&mode=$mode');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("API ai-content error: $e");
    }
    return null;
  }

  /// Mengambil notifikasi siswa dari backend via GET /api/notifications?role=pelajar
  static Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications?role=pelajar');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return data
              .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("API fetch notifications error: $e");
    }
    return [];
  }

  /// Menandai notifikasi sebagai telah dibaca via POST /api/notifications/:id/read
  static Future<bool> markNotificationRead(String id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/notifications/$id/read');
      final res = await http.post(uri).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("API mark notification read error: $e");
      return false;
    }
  }

  /// Cek status reset poin siswa oleh guru via GET /api/students/reset-status
  static Future<Map<String, dynamic>?> checkResetStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/api/students/reset-status');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("API check reset status error: $e");
    }
    return null;
  }

  /// Mengambil daftar siswa kelas & ranking poin realtime dari backend via GET /api/students
  static Future<List<Map<String, dynamic>>> fetchClassmates() async {
    try {
      final uri = Uri.parse('$baseUrl/api/students');
      final res = await http.get(uri).timeout(const Duration(milliseconds: 2500));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
    } catch (e) {
      debugPrint("API fetch classmates error: $e");
    }
    return [];
  }
}
