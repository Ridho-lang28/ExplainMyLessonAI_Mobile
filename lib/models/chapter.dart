import 'quiz.dart';

class Chapter {
  final String id;
  final String chapterCode;
  final String title;
  final String subject; // 'pkn' | 'bjawa'
  final String subjectLabel;
  final String icon;
  final String shortDescription;
  final List<String> storyBody;
  final int defaultComprehension; // % e.g. 88
  final int order;
  final bool isFromTeacher;
  final String? teacherValidatedAt;
  final Map<int, List<Question>>? customQuizQuestions;

  const Chapter({
    required this.id,
    required this.chapterCode,
    required this.title,
    required this.subject,
    required this.subjectLabel,
    required this.icon,
    required this.shortDescription,
    required this.storyBody,
    this.defaultComprehension = 80,
    required this.order,
    this.isFromTeacher = false,
    this.teacherValidatedAt,
    this.customQuizQuestions,
  });

  factory Chapter.fromCurriculumModule(Map<String, dynamic> json, {int order = 1}) {
    final rawSubject = (json['subject'] ?? 'pkn').toString().toLowerCase();
    final isJawa = rawSubject.contains('jawa') || rawSubject == 'bjawa';
    final subject = isJawa ? 'bjawa' : 'pkn';
    final subjectLabel = json['subjectLabel']?.toString() ??
        (isJawa ? 'Bahasa Jawa' : 'Pendidikan Pancasila');

    // Parse ragSummary atau storyBody dari backend
    List<String> body = [];
    if (json['ragSummary'] is List) {
      body = (json['ragSummary'] as List).map((e) => e.toString()).toList();
    } else if (json['storyBody'] is List) {
      body = (json['storyBody'] as List).map((e) => e.toString()).toList();
    }

    // Tentukan icon relevan untuk materi
    String icon = isJawa ? '🎭' : '🇮🇩';
    final titleLower = (json['title'] ?? '').toString().toLowerCase();
    if (titleLower.contains('beringin') || titleLower.contains('sila')) {
      icon = '🌳';
    } else if (titleLower.contains('gotong')) {
      icon = '🤝';
    } else if (titleLower.contains('norma') || titleLower.contains('aturan')) {
      icon = '📜';
    } else if (titleLower.contains('bhinneka')) {
      icon = '🌺';
    } else if (titleLower.contains('unggah')) {
      icon = '🗣️';
    } else if (titleLower.contains('punokawan')) {
      icon = '🎭';
    } else if (titleLower.contains('pandhawa')) {
      icon = '🏹';
    } else if (titleLower.contains('aksara')) {
      icon = '📜';
    } else if (titleLower.contains('tanah air') || titleLower.contains('nasionalisme')) {
      icon = '🇮🇩';
    }

    // Parse bank soal kuis yang digenerate/disubmit pengajar untuk modul ini
    Map<int, List<Question>>? parsedQuiz;
    if (json['quizQuestions'] is Map) {
      final qMap = json['quizQuestions'] as Map;
      parsedQuiz = {};
      qMap.forEach((key, val) {
        final level = int.tryParse(key.toString()) ?? 1;
        if (val is List) {
          parsedQuiz![level] = val
              .map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList();
        }
      });
    }

    return Chapter(
      id: json['id']?.toString() ?? 'mod-${DateTime.now().millisecondsSinceEpoch}',
      chapterCode: json['chapterCode']?.toString() ?? 'Bab Baru',
      title: json['title']?.toString() ?? 'Materi Pelajaran',
      subject: subject,
      subjectLabel: subjectLabel,
      icon: icon,
      shortDescription: json['learningGoal']?.toString() ??
          (body.isNotEmpty ? body.first : 'Materi pembelajaran dari Guru.'),
      storyBody: body,
      order: order,
      isFromTeacher: true,
      teacherValidatedAt: json['validatedAt']?.toString() ?? 'Hari ini, 08:00 WIB',
      customQuizQuestions: parsedQuiz,
    );
  }
}
