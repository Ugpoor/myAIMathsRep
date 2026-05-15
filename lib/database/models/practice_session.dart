class PracticeSession {
  final String? id;
  final String classId;
  final String knowledgePoint;
  final String? difficulty;
  final int? questionCount;
  final int? timeLimit; // 分钟
  final String status; // generated/ongoing/graded/revised
  final double? score;
  final DateTime createdAt;

  PracticeSession({
    this.id,
    required this.classId,
    required this.knowledgePoint,
    this.difficulty,
    this.questionCount,
    this.timeLimit,
    this.status = 'generated',
    this.score,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'class_id': classId,
      'knowledge_point': knowledgePoint,
      'difficulty': difficulty,
      'question_count': questionCount,
      'time_limit': timeLimit,
      'status': status,
      'score': score,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PracticeSession.fromMap(Map<String, dynamic> map) {
    return PracticeSession(
      id: map['id'],
      classId: map['class_id'],
      knowledgePoint: map['knowledge_point'],
      difficulty: map['difficulty'],
      questionCount: map['question_count'],
      timeLimit: map['time_limit'],
      status: map['status'] ?? 'generated',
      score: map['score'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
