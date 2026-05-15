
class Exam {
  final int? id;
  final String name;
  final int totalQuestions;
  final int scorePerQuestion;
  final int? createdAt;

  Exam({
    this.id,
    required this.name,
    required this.totalQuestions,
    required this.scorePerQuestion,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'total_questions': totalQuestions,
      'score_per_question': scorePerQuestion,
      'created_at': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      name: map['name'],
      totalQuestions: map['total_questions'],
      scorePerQuestion: map['score_per_question'],
      createdAt: map['created_at'],
    );
  }
}