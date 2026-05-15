class PracticeQuestion {
  final int? id;
  final int sessionId;
  final String questionText;
  final String? questionType; // choice/fill-in/essay
  final String? options; // JSON array string for choice questions
  final String? standardAnswer;
  final String? explanation;
  final String? knowledgePoint;

  PracticeQuestion({
    this.id,
    required this.sessionId,
    required this.questionText,
    this.questionType,
    this.options,
    this.standardAnswer,
    this.explanation,
    this.knowledgePoint,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'question_text': questionText,
      'question_type': questionType,
      'options': options,
      'standard_answer': standardAnswer,
      'explanation': explanation,
      'knowledge_point': knowledgePoint,
    };
  }

  factory PracticeQuestion.fromMap(Map<String, dynamic> map) {
    return PracticeQuestion(
      id: map['id'],
      sessionId: map['session_id'],
      questionText: map['question_text'],
      questionType: map['question_type'],
      options: map['options'],
      standardAnswer: map['standard_answer'],
      explanation: map['explanation'],
      knowledgePoint: map['knowledge_point'],
    );
  }
}
