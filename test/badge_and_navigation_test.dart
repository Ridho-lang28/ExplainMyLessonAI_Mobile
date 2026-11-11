import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:explainmylessonai_mobile/models/badge.dart';
import 'package:explainmylessonai_mobile/providers/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lencana Prestasi Realtime Unlocking Test', () {
    test('Badge unlocking logic correctly unlocks only earned modules', () {
      const badge1 = BadgeModel(
        id: "bab1",
        chapterCode: "Bab 1",
        subject: "pkn",
        name: "Bab 1 · Makna Sila Ke-3",
        icon: "🌳",
        description: "Deskripsi",
        howToGet: "Materi pokok pertama",
        motivation: "Semangat",
        targetChapterId: "pkn-sila3",
        defaultUnlocked: true,
      );

      const badge2 = BadgeModel(
        id: "bab2",
        chapterCode: "Bab 2",
        subject: "pkn",
        name: "Bab 2 · Gotong Royong",
        icon: "🤝",
        description: "Deskripsi",
        howToGet: "Selesaikan materi atau 200 poin",
        motivation: "Semangat",
        targetChapterId: "pkn-gotongroyong",
        requiredPoints: 200,
        defaultUnlocked: false,
      );

      // Awal mula (poin 0, belum kuis, belum selesai): hanya Bab 1 yang diraih (1 Lencana)
      expect(badge1.isUnlocked(0, false, false, []), isTrue);
      expect(badge2.isUnlocked(0, false, false, []), isFalse);

      // Siswa menyelesaikan Bab 2 secara nyata (ada di completedChapterIds)
      expect(badge2.isUnlocked(0, false, false, ["pkn-gotongroyong"]), isTrue);

      // Atau siswa menuntaskan kuis
      expect(badge2.isUnlocked(0, true, false, []), isTrue);

      // Atau siswa mencapai 200 poin
      expect(badge2.isUnlocked(200, false, false, []), isTrue);
    });

    test('AppState initial badges shows only 1 earned badge when points are 0 and no quiz completed', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      final badges = state.currentSubjectBadges;
      final earned = badges.where((b) => b.isUnlocked(
        0,
        false,
        false,
        state.completedChapterIds,
      )).toList();

      // Memastikan hanya 1 lencana yang diraih diawal (persis web), bukan dummy semua terbuka
      expect(earned.length, 1);
      expect(earned.first.targetChapterId, 'pkn-sila3');
    });

    test('markChapterCompleted adds chapter to completed list and unlocks its badge', () async {
      final state = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(state.completedChapterIds.contains('pkn-gotongroyong'), isFalse);

      await state.markChapterCompleted('pkn-gotongroyong');
      expect(state.completedChapterIds.contains('pkn-gotongroyong'), isTrue);

      final badges = state.currentSubjectBadges;
      final earned = badges.where((b) => b.isUnlocked(
        0,
        false,
        false,
        state.completedChapterIds,
      )).toList();

      // Sekarang ada 2 lencana yang diraih secara sah
      expect(earned.length, 2);
    });
  });
}
