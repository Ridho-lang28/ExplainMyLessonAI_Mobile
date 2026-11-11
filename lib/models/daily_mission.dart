class DailyMissions {
  final bool readSummary;
  final bool listenedAudio;
  final bool quizLevel1;
  final bool quizLevel2;
  final bool quizLevel3;
  final bool completedQuiz;

  const DailyMissions({
    this.readSummary = false,
    this.listenedAudio = false,
    this.quizLevel1 = false,
    this.quizLevel2 = false,
    this.quizLevel3 = false,
    this.completedQuiz = false,
  });

  DailyMissions copyWith({
    bool? readSummary,
    bool? listenedAudio,
    bool? quizLevel1,
    bool? quizLevel2,
    bool? quizLevel3,
    bool? completedQuiz,
  }) {
    return DailyMissions(
      readSummary: readSummary ?? this.readSummary,
      listenedAudio: listenedAudio ?? this.listenedAudio,
      quizLevel1: quizLevel1 ?? this.quizLevel1,
      quizLevel2: quizLevel2 ?? this.quizLevel2,
      quizLevel3: quizLevel3 ?? this.quizLevel3,
      completedQuiz: completedQuiz ?? this.completedQuiz,
    );
  }

  int get completedCount {
    int count = 0;
    if (readSummary) count++;
    if (listenedAudio) count++;
    if (quizLevel1) count++;
    if (quizLevel2) count++;
    if (quizLevel3 || completedQuiz) count++;
    return count;
  }

  int get totalMissions => 5;

  double get progressPercent => completedCount / totalMissions;

  int get progressPercentInt => ((completedCount / totalMissions) * 100).round();
}
