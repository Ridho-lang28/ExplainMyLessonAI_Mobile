class StudentWeakness {
  final String chapterId;
  final String chapterName;
  final String subject;
  final int score;
  final int outOf;
  final String status; // 'tuntas' | 'remedial'
  final String message;

  const StudentWeakness({
    required this.chapterId,
    required this.chapterName,
    required this.subject,
    required this.score,
    required this.outOf,
    required this.status,
    required this.message,
  });

  bool get isRemedial => status == 'remedial' || (score / outOf) < 0.6;

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'chapterName': chapterName,
    'subject': subject,
    'score': score,
    'outOf': outOf,
    'status': status,
    'message': message,
  };

  factory StudentWeakness.fromJson(Map<String, dynamic> json) => StudentWeakness(
    chapterId: json['chapterId'] as String,
    chapterName: json['chapterName'] as String,
    subject: json['subject'] as String,
    score: json['score'] as int,
    outOf: json['outOf'] as int,
    status: json['status'] as String,
    message: json['message'] as String,
  );
}

class Student {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final String grade;
  final String school;
  final String nisn;
  final int points;
  final StudentWeakness? weakness;

  const Student({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.grade = "Kelas 4 SD",
    this.school = "SD Negeri 1 Madiun",
    this.nisn = "0084729102",
    this.points = 180,
    this.weakness,
  });

  Student copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? grade,
    String? school,
    String? nisn,
    int? points,
    StudentWeakness? weakness,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      grade: grade ?? this.grade,
      school: school ?? this.school,
      nisn: nisn ?? this.nisn,
      points: points ?? this.points,
      weakness: weakness ?? this.weakness,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar': avatar,
    'grade': grade,
    'school': school,
    'nisn': nisn,
    'points': points,
    if (weakness != null) 'weakness': weakness!.toJson(),
  };

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    avatar: json['avatar'] as String,
    grade: json['grade'] as String? ?? "Kelas 4 SD",
    school: json['school'] as String? ?? "SD Negeri 1 Madiun",
    nisn: json['nisn'] as String? ?? "0084729102",
    points: json['points'] as int? ?? 180,
    weakness: json['weakness'] != null
        ? StudentWeakness.fromJson(json['weakness'] as Map<String, dynamic>)
        : null,
  );
}

class LeaderboardEntry {
  final String id;
  final String name;
  final int points;
  final bool isUser;
  final String avatar;
  final int rank;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.points,
    required this.isUser,
    required this.avatar,
    required this.rank,
  });
}
