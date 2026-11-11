import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/student.dart';

class StorageService {
  static const String _keyPoints = 'user_total_points';
  static const String _keyStudentId = 'active_student_id';
  static const String _keyIsLoggedIn = 'is_user_logged_in';
  static const String _keyCustomProfile = 'custom_student_profile_json';
  static const String _keyMissionSummary = 'mission_read_summary';
  static const String _keyMissionAudio = 'mission_listened_audio';
  static const String _keyMissionQuiz1 = 'mission_quiz_level1';
  static const String _keyMissionQuiz2 = 'mission_quiz_level2';
  static const String _keyMissionQuiz3 = 'mission_quiz_level3';
  static const String _keyMissionCompletedQuiz = 'mission_quiz_completed';
  static const String _keyThemeDark = 'theme_mode_dark';
  static const String _keyLastResetTime = 'last_acknowledged_reset_time';
  static const String _keyCompletedChapters = 'completed_chapter_ids';

  static Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyThemeDark) ?? false;
  }

  static Future<void> saveIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyThemeDark, isDark);
  }

  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  static Future<void> saveIsLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<Student?> getCustomProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyCustomProfile);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Student.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  static Future<Student?> getCustomProfileForEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('${_keyCustomProfile}_${email.trim().toLowerCase()}');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return Student.fromJson(map);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> saveCustomProfile(Student student) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(student.toJson());
    await prefs.setString(_keyCustomProfile, jsonStr);
    await prefs.setString('${_keyCustomProfile}_${student.id}', jsonStr);
    await prefs.setString('${_keyCustomProfile}_${student.email.trim().toLowerCase()}', jsonStr);
  }

  static Future<int> getPoints(int defaultPoints) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPoints) ?? defaultPoints;
  }

  static Future<void> savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, points);
  }

  static Future<int> getLastAcknowledgedResetTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastResetTime) ?? 0;
  }

  static Future<void> saveLastAcknowledgedResetTime(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastResetTime, timestamp);
  }

  static Future<String?> getActiveStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyStudentId);
  }

  static Future<void> saveActiveStudentId(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStudentId, studentId);
  }

  static Future<Map<String, bool>> getMissions() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'readSummary': prefs.getBool(_keyMissionSummary) ?? false,
      'listenedAudio': prefs.getBool(_keyMissionAudio) ?? false,
      'quizLevel1': prefs.getBool(_keyMissionQuiz1) ?? false,
      'quizLevel2': prefs.getBool(_keyMissionQuiz2) ?? false,
      'quizLevel3': prefs.getBool(_keyMissionQuiz3) ?? false,
      'completedQuiz': prefs.getBool(_keyMissionCompletedQuiz) ?? false,
    };
  }

  static Future<void> saveMission(String missionKey, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    switch (missionKey) {
      case 'readSummary':
        await prefs.setBool(_keyMissionSummary, value);
        break;
      case 'listenedAudio':
        await prefs.setBool(_keyMissionAudio, value);
        break;
      case 'quizLevel1':
        await prefs.setBool(_keyMissionQuiz1, value);
        break;
      case 'quizLevel2':
        await prefs.setBool(_keyMissionQuiz2, value);
        break;
      case 'quizLevel3':
        await prefs.setBool(_keyMissionQuiz3, value);
        break;
      case 'completedQuiz':
        await prefs.setBool(_keyMissionCompletedQuiz, value);
        break;
    }
  }

  static Future<void> resetMissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMissionSummary);
    await prefs.remove(_keyMissionAudio);
    await prefs.remove(_keyMissionQuiz1);
    await prefs.remove(_keyMissionQuiz2);
    await prefs.remove(_keyMissionQuiz3);
    await prefs.remove(_keyMissionCompletedQuiz);
    await prefs.remove(_keyCompletedChapters);
  }

  static Future<List<String>> getCompletedChapterIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyCompletedChapters) ?? [];
  }

  static Future<void> markChapterCompleted(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keyCompletedChapters) ?? [];
    if (!list.contains(chapterId)) {
      list.add(chapterId);
      await prefs.setStringList(_keyCompletedChapters, list);
    }
  }

  static Future<void> resetCompletedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletedChapters);
  }
}
