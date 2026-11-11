class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctOption;
  final String hint;

  String get explanation => hint;

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.hint,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctOption: json['correctOption'] as int,
      hint: json['hint'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctOption': correctOption,
    'hint': hint,
  };
}
