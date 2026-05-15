
class StudentExam {
  final int? id;
  final int studentId;
  final int examId;
  final String wrongAnswers;
  final int? createdAt;

  StudentExam({
    this.id,
    required this.studentId,
    required this.examId,
    required this.wrongAnswers,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'exam_id': examId,
      'wrong_answers': wrongAnswers,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory StudentExam.fromMap(Map<String, dynamic> map) {
    return StudentExam(
      id: map['id'],
      studentId: map['student_id'],
      examId: map['exam_id'],
      wrongAnswers: map['wrong_answers'],
      createdAt: map['created_at'],
    );
  }

  List<int> get wrongAnswersList {
    if (wrongAnswers.isEmpty) return [];
    return wrongAnswers.split(',').map((s) => int.parse(s.trim())).toList();
  }
}