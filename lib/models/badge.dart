class BadgeModel {
  final String id;
  final String? chapterCode;
  final String subject; // 'pkn' | 'bjawa'
  final String name;
  final String icon;
  final String description;
  final String howToGet;
  final String motivation;
  final String? targetChapterId;
  final int requiredPoints;
  final bool defaultUnlocked;

  const BadgeModel({
    required this.id,
    this.chapterCode,
    required this.subject,
    required this.name,
    required this.icon,
    required this.description,
    required this.howToGet,
    required this.motivation,
    this.targetChapterId,
    this.requiredPoints = 0,
    this.defaultUnlocked = false,
  });

  bool isUnlocked(
    int totalPoints,
    bool completedQuiz,
    bool quizLevel1, [
    List<String>? completedChapterIds,
  ]) {
    // Jika bab materi ini sudah benar-benar diselesaikan oleh siswa (baca materi atau kuis)
    if (completedChapterIds != null && targetChapterId != null) {
      final cleanTarget = targetChapterId!.replaceFirst('mod-', '');
      final isFinished = completedChapterIds.any(
        (id) => id == targetChapterId || id.replaceFirst('mod-', '') == cleanTarget,
      );
      if (isFinished) return true;
    }

    if (defaultUnlocked) return true;
    if (requiredPoints <= 0) return false;

    if (requiredPoints == 200) {
      return completedQuiz || quizLevel1 || totalPoints >= 200;
    }

    return totalPoints >= requiredPoints;
  }
}
