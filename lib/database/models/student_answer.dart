class StudentAnswer {
  final int? id;
  final int questionId;
  final int studentId;
  final String? answerText;
  final bool isCorrect;
  final double? score;
  final String? errorAnalysis;
  final DateTime submittedAt;

  StudentAnswer({
    this.id,
    required this.questionId,
    required this.studentId,
    this.answerText,
    this.isCorrect = false,
    this.score,
    this.errorAnalysis,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'student_id': studentId,
      'answer_text': answerText,
      'is_correct': isCorrect ? 1 : 0,
      'score': score,
      'error_analysis': errorAnalysis,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }

  factory StudentAnswer.fromMap(Map<String, dynamic> map) {
    return StudentAnswer(
      id: map['id'],
      questionId: map['question_id'],
      studentId: map['student_id'],
      answerText: map['answer_text'],
      isCorrect: map['is_correct'] == 1,
      score: map['score'],
      errorAnalysis: map['error_analysis'],
      submittedAt: DateTime.parse(map['submitted_at']),
    );
  }
}
