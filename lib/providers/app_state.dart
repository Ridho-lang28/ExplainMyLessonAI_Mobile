import 'dart:async';
import 'package:flutter/material.dart';
import '../data/local_catalog.dart';
import '../models/badge.dart';
import '../models/chapter.dart';
import '../models/daily_mission.dart';
import '../models/notification_item.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class PointRewardNotice {
  final int amount;
  final String message;
  final DateTime timestamp;

  PointRewardNotice({required this.amount, required this.message})
      : timestamp = DateTime.now();
}

class AppState extends ChangeNotifier {
  late Student _currentStudent;
  late int _totalPoints;
  DailyMissions _dailyMissions = const DailyMissions();
  late Chapter _currentChapter;
  String _activeSubject = 'pkn'; // 'pkn' | 'bjawa'
  PointRewardNotice? _latestReward;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  // Modul Kurikulum Dinamis dari Guru via Backend
  List<Chapter> _chapters = List.from(LocalCatalog.chapters);
  Chapter? _activeTeacherModule;
  bool _isLoadingTeacherModule = false;

  // Mode Gelap & Notifikasi Siswa
  ThemeMode _themeMode = ThemeMode.light;
  List<NotificationItem> _notifications = [];
  bool _isQuizActive = false;
  bool _isPointsReset = false;
  List<Map<String, dynamic>> _liveClassmates = [];
  List<String> _completedChapterIds = [];
  Timer? _periodicSyncTimer;

  final TtsService _ttsService = TtsService();

  Student get currentStudent => _currentStudent;
  int get totalPoints => _totalPoints;
  DailyMissions get dailyMissions => _dailyMissions;
  Chapter get currentChapter => _currentChapter;
  String get activeSubject => _activeSubject;
  PointRewardNotice? get latestReward => _latestReward;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  TtsService get ttsService => _ttsService;
  bool get isQuizActive => _isQuizActive;
  bool get isPointsReset => _isPointsReset;
  List<Map<String, dynamic>> get liveClassmates => _liveClassmates;
  List<String> get completedChapterIds => _completedChapterIds;

  bool get isRankingEmpty =>
      (_isPointsReset && _totalPoints == 0) ||
      (leaderboard.isNotEmpty && leaderboard.every((e) => e.points == 0));

  void setQuizActive(bool active) {
    if (_isQuizActive != active) {
      _isQuizActive = active;
      notifyListeners();
    }
  }

  List<Chapter> get chapters => _chapters;
  Chapter? get activeTeacherModule => _activeTeacherModule;
  bool get isLoadingTeacherModule => _isLoadingTeacherModule;
  List<Chapter> get teacherModules => _chapters.where((c) => c.isFromTeacher).toList();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  List<NotificationItem> get notifications => _notifications;
  int get unreadNotificationCount => _notifications.where((n) => !n.isRead).length;

  List<Student> get availableStudents => LocalCatalog.demoStudents;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    _currentStudent = LocalCatalog.demoStudents.first;
    _totalPoints = _currentStudent.points;
    _currentChapter = LocalCatalog.chapters.first;

    // Check login state
    _isLoggedIn = await StorageService.getIsLoggedIn();

    // Load custom profile if user had previously edited
    final customProfile = await StorageService.getCustomProfile();
    if (customProfile != null) {
      _currentStudent = customProfile;
    } else {
      final savedStudentId = await StorageService.getActiveStudentId();
      if (savedStudentId != null) {
        final found = LocalCatalog.demoStudents.firstWhere(
          (s) => s.id == savedStudentId,
          orElse: () => LocalCatalog.demoStudents.first,
        );
        _currentStudent = found;
      }
    }

    // Load saved points
    final savedPoints = await StorageService.getPoints(_currentStudent.points);
    _totalPoints = savedPoints;

    final missionsMap = await StorageService.getMissions();
    _dailyMissions = DailyMissions(
      readSummary: missionsMap['readSummary'] ?? false,
      listenedAudio: missionsMap['listenedAudio'] ?? false,
      quizLevel1: missionsMap['quizLevel1'] ?? false,
      quizLevel2: missionsMap['quizLevel2'] ?? false,
      quizLevel3: missionsMap['quizLevel3'] ?? false,
      completedQuiz: missionsMap['completedQuiz'] ?? false,
    );

    final isDark = await StorageService.getIsDarkMode();
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    _completedChapterIds = await StorageService.getCompletedChapterIds();

    await _ttsService.init();

    _isLoading = false;
    notifyListeners();

    // Sinkronisasi kurikulum, reset poin dari Guru, & modul aktif di background
    syncCurriculumWithBackend();
    syncTeacherPointReset();
    fetchClassmates();
    fetchNotifications();
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    _periodicSyncTimer?.cancel();
    // Sinkronisasi otomatis setiap 4 detik (Persis seperti interval web PelajarDashboardPage.tsx)
    _periodicSyncTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await syncTeacherPointReset();
      await fetchClassmates();
      await fetchNotifications();
    });
  }

  Future<void> loginWithDemo(Student student) async {
    // 1. Cek apakah ada profil kustom yang tersimpan dari hasil edit profil sebelumnya
    final customProfile = await StorageService.getCustomProfile();
    Student effectiveStudent = student;
    if (customProfile != null) {
      // Prioritaskan profil yang telah diedit dan disimpan oleh user agar tidak kembali ke default
      effectiveStudent = customProfile;
    }

    _currentStudent = effectiveStudent;
    final savedPoints = await StorageService.getPoints(effectiveStudent.points);
    _totalPoints = savedPoints;
    _isLoggedIn = true;
    await StorageService.saveIsLoggedIn(true);
    await StorageService.saveActiveStudentId(effectiveStudent.id);
    await StorageService.savePoints(_totalPoints);
    addPoints(0, "Selamat datang kembali, ${effectiveStudent.name.split(' ').first}! 👋");
    notifyListeners();
  }

  Future<bool> loginWithCredentials(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Coba verifikasi ke backend jika server aktif
    final apiRes = await ApiService.login(email: cleanEmail, password: password);
    if (apiRes != null && apiRes['ok'] == true && apiRes['user'] != null) {
      final u = apiRes['user'] as Map<String, dynamic>;
      final apiStudent = Student(
        id: u['id']?.toString() ?? "user_${DateTime.now().millisecondsSinceEpoch}",
        name: u['name']?.toString() ?? cleanEmail.split('@').first,
        email: u['email']?.toString() ?? cleanEmail,
        avatar: u['avatar']?.toString() ?? "👦",
        grade: u['grade']?.toString() ?? "Kelas 4 SD",
        school: u['school']?.toString() ?? "SD Negeri 1 Madiun",
        points: (u['points'] as num?)?.toInt() ?? 150,
      );

      _currentStudent = apiStudent;
      final savedPoints = await StorageService.getPoints(apiStudent.points);
      _totalPoints = savedPoints;
      _isLoggedIn = true;
      await StorageService.saveIsLoggedIn(true);
      await StorageService.saveActiveStudentId(_currentStudent.id);
      await StorageService.savePoints(_totalPoints);
      await StorageService.saveCustomProfile(_currentStudent);
      addPoints(0, "Berhasil masuk (Terhubung ke Server API) 🚀");
      notifyListeners();
      return true;
    }

    // 2. Cek apakah email cocok dengan profil kustom yang disimpan di lokal
    final customByEmail = await StorageService.getCustomProfileForEmail(cleanEmail);
    final globalCustom = await StorageService.getCustomProfile();
    final customMatch = customByEmail ??
        ((globalCustom != null &&
          (globalCustom.email.toLowerCase() == cleanEmail ||
           cleanEmail.contains(globalCustom.name.toLowerCase())))
            ? globalCustom
            : null);

    if (customMatch != null) {
      _currentStudent = customMatch;
      final savedPoints = await StorageService.getPoints(customMatch.points);
      _totalPoints = savedPoints;
      _isLoggedIn = true;
      await StorageService.saveIsLoggedIn(true);
      await StorageService.saveActiveStudentId(_currentStudent.id);
      await StorageService.savePoints(_totalPoints);
      addPoints(0, "Selamat datang kembali, ${customMatch.name.split(' ').first}! 🌟");
      notifyListeners();
      return true;
    }

    // 3. Fallback offline / local demo data
    final match = LocalCatalog.demoStudents.firstWhere(
      (s) => s.email.toLowerCase() == cleanEmail,
      orElse: () => Student(
        id: "user_${DateTime.now().millisecondsSinceEpoch}",
        name: email.split('@').first,
        email: email,
        avatar: "👦",
        grade: "Kelas 4 SD",
        school: "SD Negeri 1 Madiun",
        points: 150,
      ),
    );

    _currentStudent = match;
    final savedPoints = await StorageService.getPoints(match.points);
    _totalPoints = savedPoints;
    _isLoggedIn = true;
    await StorageService.saveIsLoggedIn(true);
    await StorageService.saveActiveStudentId(_currentStudent.id);
    await StorageService.savePoints(_totalPoints);
    addPoints(0, "Selamat datang kembali di Ruang Belajar SD! 🌟");
    notifyListeners();
    return true;
  }

  Future<bool> registerStudent({
    required String name,
    required String email,
    required String password,
    required String avatar,
    required String grade,
    required String school,
    String? nisn,
  }) async {
    // Sinkronisasi data ke backend jika online
    ApiService.register(
      name: name,
      email: email,
      password: password,
      avatar: avatar,
      grade: grade,
      school: school,
      nisn: nisn,
    );

    final newStudent = Student(
      id: "student_${DateTime.now().millisecondsSinceEpoch}",
      name: name.trim(),
      email: email.trim(),
      avatar: avatar,
      grade: grade.trim(),
      school: school.trim(),
      nisn: nisn ?? "0084729102",
      points: 100, // Welcome gift points
      weakness: const StudentWeakness(
        chapterId: "pkn-sila3",
        chapterName: "Bab 1 Makna Sila Ke-3",
        subject: "PKn",
        score: 9,
        outOf: 10,
        status: "tuntas",
        message: "Selamat datang! Mulai belajarmu dengan membaca modul dan menjawab kuis.",
      ),
    );

    _currentStudent = newStudent;
    _totalPoints = 100;
    _isLoggedIn = true;
    await StorageService.saveIsLoggedIn(true);
    await StorageService.saveCustomProfile(newStudent);
    await StorageService.saveActiveStudentId(newStudent.id);
    await StorageService.savePoints(100);
    addPoints(100, "Bonus pendaftaran siswa baru: +100 ⭐ Poin Prestasi!");
    notifyListeners();
    return true;
  }

  Future<void> updateStudentProfile({
    required String name,
    required String email,
    required String avatar,
    required String grade,
    required String school,
    required String nisn,
  }) async {
    _currentStudent = _currentStudent.copyWith(
      name: name.trim(),
      email: email.trim(),
      avatar: avatar,
      grade: grade.trim(),
      school: school.trim(),
      nisn: nisn.trim(),
    );

    await StorageService.saveCustomProfile(_currentStudent);
    await StorageService.saveActiveStudentId(_currentStudent.id);

    // Sinkronisasi ke backend jika server API aktif
    try {
      await ApiService.updateProfile(
        name: name.trim(),
        avatar: avatar,
        grade: grade.trim(),
        school: school.trim(),
        nisn: nisn.trim(),
      );
    } catch (_) {}

    addPoints(10, "Profil siswa berhasil disimpan & diperbarui! (+10 ⭐)");
    notifyListeners();
  }

  Future<void> logout() async {
    await _ttsService.stop();
    _isLoggedIn = false;
    await StorageService.saveIsLoggedIn(false);
    notifyListeners();
  }

  void addPoints(int amount, [String? message]) {
    _totalPoints += amount;
    StorageService.savePoints(_totalPoints);

    if (amount > 0) {
      final identifier = _currentStudent.name.isNotEmpty
          ? _currentStudent.name
          : (_currentStudent.email.isNotEmpty ? _currentStudent.email : _currentStudent.id);
      ApiService.syncPoints(amount: amount, userId: identifier);
    }

    if (amount > 0 && message != null) {
      _latestReward = PointRewardNotice(amount: amount, message: message);
    }
    notifyListeners();
  }

  PointRewardNotice? consumeLatestReward() {
    final r = _latestReward;
    _latestReward = null;
    return r;
  }

  void clearRewardNotice() {
    _latestReward = null;
  }

  void completeMission(String missionKey, [int points = 10, String? message]) {
    bool changed = false;
    switch (missionKey) {
      case 'readSummary':
        if (!_dailyMissions.readSummary) {
          _dailyMissions = _dailyMissions.copyWith(readSummary: true);
          changed = true;
        }
        break;
      case 'listenedAudio':
        if (!_dailyMissions.listenedAudio) {
          _dailyMissions = _dailyMissions.copyWith(listenedAudio: true);
          changed = true;
        }
        break;
      case 'quizLevel1':
        if (!_dailyMissions.quizLevel1) {
          _dailyMissions = _dailyMissions.copyWith(quizLevel1: true);
          changed = true;
        }
        break;
      case 'quizLevel2':
        if (!_dailyMissions.quizLevel2) {
          _dailyMissions = _dailyMissions.copyWith(quizLevel2: true);
          changed = true;
        }
        break;
      case 'quizLevel3':
        if (!_dailyMissions.quizLevel3) {
          _dailyMissions = _dailyMissions.copyWith(quizLevel3: true, completedQuiz: true);
          changed = true;
        }
        break;
      case 'completedQuiz':
        if (!_dailyMissions.completedQuiz) {
          _dailyMissions = _dailyMissions.copyWith(completedQuiz: true);
          changed = true;
        }
        break;
    }

    if (changed) {
      StorageService.saveMission(missionKey, true);
      addPoints(points, message ?? "Misi Harian Tuntas! +$points ⭐");
    }
  }

  /// Menandai bab materi telah diselesaikan secara sah oleh siswa (baca modul atau kuis)
  Future<void> markChapterCompleted(String chapterId) async {
    if (!_completedChapterIds.contains(chapterId)) {
      _completedChapterIds.add(chapterId);
      await StorageService.markChapterCompleted(chapterId);
      notifyListeners();
    }
  }

  void switchStudent(String studentId) {
    final selected = LocalCatalog.demoStudents.firstWhere(
      (s) => s.id == studentId,
      orElse: () => LocalCatalog.demoStudents.first,
    );
    _currentStudent = selected;
    _totalPoints = selected.points;
    StorageService.saveActiveStudentId(studentId);
    StorageService.savePoints(_totalPoints);
    notifyListeners();
  }

  void setSubject(String subject) {
    if (_activeSubject != subject) {
      _activeSubject = subject;
      final firstInSubject = _chapters.firstWhere(
        (c) => c.subject == subject,
        orElse: () => _chapters.first,
      );
      _currentChapter = firstInSubject;
      notifyListeners();
    }
  }

  void selectChapter(Chapter chapter) {
    _currentChapter = chapter;
    _activeSubject = chapter.subject;
    notifyListeners();
  }

  /// Membuka langsung modul aktif yang disubmit dan divalidasi oleh Guru
  void selectActiveTeacherModule() {
    if (_activeTeacherModule != null) {
      _currentChapter = _activeTeacherModule!;
      _activeSubject = _activeTeacherModule!.subject;
      notifyListeners();
    }
  }

  /// Sinkronisasi materi kurikulum dari Guru melalui Backend Express
  Future<bool> syncCurriculumWithBackend() async {
    _isLoadingTeacherModule = true;
    notifyListeners();

    try {
      // 1. Ambil modul tervalidasi aktif dari guru via GET /api/v1/curriculum/active
      final activeData = await ApiService.fetchActiveValidatedModule();
      if (activeData != null && activeData['title'] != null) {
        final activeModule = Chapter.fromCurriculumModule(activeData, order: 0);
        _activeTeacherModule = activeModule;
      }

      // 2. Ambil seluruh modul yang tersimpan/disubmit oleh pengajar via GET /api/v1/curriculum/modules
      final modulesData = await ApiService.fetchCurriculumModules();
      if (modulesData.isNotEmpty) {
        final dynamicChapters = <Chapter>[];
        int ord = 1;
        for (var m in modulesData) {
          // Hanya muat materi yang telah disubmit / divalidasi oleh pengajar
          if (m['isValidated'] == true || m['isActiveToday'] == true || m['title'] != null) {
            dynamicChapters.add(Chapter.fromCurriculumModule(m, order: ord++));
          }
        }

        if (dynamicChapters.isNotEmpty) {
          _chapters = dynamicChapters;
        }
      }

      // Pastikan modul aktif dari guru masuk di baris pertama dan menjadi bab aktif saat ini
      if (_activeTeacherModule != null) {
        final exists = _chapters.any((c) => c.id == _activeTeacherModule!.id);
        if (!exists) {
          _chapters.insert(0, _activeTeacherModule!);
        } else {
          final idx = _chapters.indexWhere((c) => c.id == _activeTeacherModule!.id);
          _chapters[idx] = _activeTeacherModule!;
        }
        _currentChapter = _activeTeacherModule!;
        _activeSubject = _activeTeacherModule!.subject;
      }

      // Sinkronkan status reset poin & teman sekelas
      await syncTeacherPointReset();
      await fetchClassmates();

      _isLoadingTeacherModule = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Gagal sinkronisasi materi guru: $e");
      _isLoadingTeacherModule = false;
      notifyListeners();
      return false;
    }
  }

  /// Sinkronisasi reset poin siswa oleh Guru via GET /api/students/reset-status
  Future<bool> syncTeacherPointReset() async {
    try {
      final resetData = await ApiService.checkResetStatus();
      if (resetData != null && resetData['isReset'] == true && resetData['resetAt'] != null) {
        final resetAt = (resetData['resetAt'] as num).toInt();
        final lastAck = await StorageService.getLastAcknowledgedResetTime();
        if (resetAt > 0 && resetAt > lastAck) {
          debugPrint("Deteksi reset poin dari Guru! resetAt: $resetAt > lastAck: $lastAck");
          await StorageService.saveLastAcknowledgedResetTime(resetAt);
          _totalPoints = 0;
          _isPointsReset = true;
          await StorageService.savePoints(0);
          await fetchNotifications();
          await fetchClassmates();
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint("Gagal sinkronisasi status reset poin guru: $e");
    }
    return false;
  }

  /// Mengambil daftar siswa kelas & ranking poin realtime dari backend via GET /api/students
  Future<void> fetchClassmates() async {
    try {
      final students = await ApiService.fetchClassmates();
      if (students.isNotEmpty) {
        _liveClassmates = students;

        final myRecord = students.firstWhere(
          (u) =>
              u['id'] == _currentStudent.id ||
              (u['name'] ?? '').toString().toLowerCase() == _currentStudent.name.toLowerCase() ||
              u['email'] == _currentStudent.email,
          orElse: () => <String, dynamic>{},
        );

        if (myRecord.isNotEmpty && myRecord['points'] != null) {
          final serverPoints = (myRecord['points'] as num).toInt();
          // Hanya perbarui dari server jika server memiliki poin lebih tinggi
          if (serverPoints > _totalPoints) {
            _totalPoints = serverPoints;
            await StorageService.savePoints(_totalPoints);
          }
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Gagal fetch classmates: $e");
    }
  }

  // Dynamic Leaderboard list sorted by points (Live Realtime dari Guru & Backend)
  List<LeaderboardEntry> get leaderboard {
    final list = <LeaderboardEntry>[];
    bool userIncluded = false;

    if (_liveClassmates.isNotEmpty) {
      for (var s in _liveClassmates) {
        final sId = s['id']?.toString() ?? '';
        final sName = s['name']?.toString() ?? 'Siswa';
        final isCurrent = sId == _currentStudent.id ||
            sName.toLowerCase() == _currentStudent.name.toLowerCase() ||
            (s['email'] != null && s['email'] == _currentStudent.email);
        if (isCurrent) userIncluded = true;

        final demoMatch = LocalCatalog.demoStudents.firstWhere(
          (d) => d.id == sId || d.name.toLowerCase() == sName.toLowerCase(),
          orElse: () => const Student(
            id: '',
            name: '',
            email: '',
            avatar: '👦',
            school: '',
            grade: '',
            points: 0,
            weakness: StudentWeakness(
              chapterId: '',
              chapterName: '',
              subject: '',
              score: 0,
              outOf: 10,
              status: 'tuntas',
              message: '',
            ),
          ),
        );

        final avatar = isCurrent
            ? _currentStudent.avatar
            : (s['avatar']?.toString() ?? (demoMatch.avatar.isNotEmpty ? demoMatch.avatar : '👦'));

        final pts = isCurrent ? _totalPoints : ((s['points'] as num?)?.toInt() ?? 0);

        list.add(LeaderboardEntry(
          id: sId,
          name: isCurrent ? "${_currentStudent.name} (Kamu)" : sName,
          points: pts,
          isUser: isCurrent,
          avatar: avatar,
          rank: 1,
        ));
      }
    } else {
      for (var s in LocalCatalog.demoStudents) {
        final isCurrent = s.id == _currentStudent.id || s.name.toLowerCase() == _currentStudent.name.toLowerCase();
        if (isCurrent) userIncluded = true;
        list.add(LeaderboardEntry(
          id: s.id,
          name: isCurrent ? "${_currentStudent.name} (Kamu)" : s.name,
          points: isCurrent ? _totalPoints : s.points,
          isUser: isCurrent,
          avatar: isCurrent ? _currentStudent.avatar : s.avatar,
          rank: 1,
        ));
      }
    }

    if (!userIncluded) {
      list.add(LeaderboardEntry(
        id: _currentStudent.id,
        name: "${_currentStudent.name} (Kamu)",
        points: _totalPoints,
        isUser: true,
        avatar: _currentStudent.avatar,
        rank: 1,
      ));
    }

    // Jika ranking kosong (semua poin 0 karena reset guru), urutkan berdasarkan nama agar stabil
    if (list.every((e) => e.points == 0)) {
      list.sort((a, b) => a.name.compareTo(b.name));
    } else {
      list.sort((a, b) => b.points.compareTo(a.points));
    }

    return List.generate(list.length, (index) {
      final item = list[index];
      return LeaderboardEntry(
        id: item.id,
        name: item.name,
        points: item.points,
        isUser: item.isUser,
        avatar: item.avatar,
        rank: index + 1,
      );
    });
  }

  int get userRank {
    final board = leaderboard;
    final index = board.indexWhere((e) => e.isUser);
    return index >= 0 ? index + 1 : 1;
  }

  List<BadgeModel> get currentSubjectBadges {
    final list = <BadgeModel>[];

    // Ambil materi yang diinput/divalidasi oleh pengajar untuk mata pelajaran aktif
    final teacherList = teacherModules.where(
      (m) => m.subject == _activeSubject || _activeSubject.isEmpty,
    ).toList();

    // Jika pengajar telah menginput materi, HANYA tampilkan materi yang diinput pengajar
    if (teacherList.isNotEmpty) {
      for (int i = 0; i < teacherList.length; i++) {
        final module = teacherList[i];
        // Bab pertama dibuka sebagai materi pembuka, bab berikutnya hanya jika telah diselesaikan secara sah / tercapai poin
        final isPrimary = i == 0;
        final reqPts = isPrimary ? 0 : ((i + 1) * 100);

        list.add(
          BadgeModel(
            id: module.id,
            chapterCode: module.chapterCode,
            name: "${module.chapterCode} · ${module.title}",
            subject: module.subject,
            icon: module.icon.isNotEmpty ? module.icon : "✨",
            description: module.shortDescription.isNotEmpty
                ? module.shortDescription
                : module.title,
            howToGet: isPrimary
                ? "Materi pokok pertama dari Guru siap dipelajari."
                : "Selesaikan materi bab ini atau kumpulkan $reqPts poin prestasi.",
            motivation: "Luar biasa! Materi ${module.chapterCode} (${module.title}) berhasil kamu pelajari dengan sangat hebat!",
            targetChapterId: module.id,
            defaultUnlocked: isPrimary,
            requiredPoints: reqPts,
          ),
        );
      }
      return list;
    }

    // Fallback jika belum ada materi yang diinput oleh pengajar
    for (var b in LocalCatalog.badges) {
      if (b.subject == _activeSubject) {
        list.add(b);
      }
    }

    return list;
  }

  List<Chapter> get currentSubjectChapters {
    return _chapters.where((c) => c.subject == _activeSubject).toList();
  }

  /// Beralih antara Mode Terang dan Mode Gelap (Dark Mode)
  Future<void> toggleTheme() async {
    _latestReward = null; // Pastikan tidak ada popup reward/notifikasi saat beralih tema
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await StorageService.saveIsDarkMode(isDarkMode);
    notifyListeners();
  }

  /// Sinkronisasi notifikasi siswa dari backend Express
  Future<void> fetchNotifications() async {
    try {
      final list = await ApiService.fetchNotifications();
      if (list.isNotEmpty) {
        _notifications = list;
        notifyListeners();
      }
    } catch (_) {}
  }

  /// Menandai satu notifikasi telah dibaca
  Future<void> markNotificationRead(String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
    await ApiService.markNotificationRead(id);
  }

  /// Menandai seluruh notifikasi telah dibaca
  Future<void> markAllNotificationsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    for (var n in _notifications) {
      ApiService.markNotificationRead(n.id);
    }
  }
}
