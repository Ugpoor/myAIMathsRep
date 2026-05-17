class CurriculumOutline {
  final String id;
  final String knowledgePoint;
  final String grade;
  final String difficulty;
  final String requirement;
  final String description;
  final List<String> relatedTopics;

  CurriculumOutline({
    required this.id,
    required this.knowledgePoint,
    required this.grade,
    required this.difficulty,
    required this.requirement,
    required this.description,
    required this.relatedTopics,
  });

  Map<String, String> toMap() {
    return {
      'id': id,
      '知识点': knowledgePoint,
      '年级': grade,
      '难度': difficulty,
      '考纲要求': requirement,
      '描述': description,
      '相关主题': relatedTopics.join(';'),
    };
  }

  factory CurriculumOutline.fromMap(Map<String, String> map) {
    return CurriculumOutline(
      id: map['id'] ?? map['ID'] ?? '',
      knowledgePoint: map['知识点'] ?? map['知识'] ?? '',
      grade: map['年级'] ?? map['Grade'] ?? '',
      difficulty: map['难度'] ?? map['Difficulty'] ?? '',
      requirement: map['考纲要求'] ?? map['要求'] ?? '',
      description: map['描述'] ?? map['Description'] ?? '',
      relatedTopics: (map['相关主题'] ?? map['相关'] ?? '').split(';'),
    );
  }

  CurriculumOutline copyWith({
    String? id,
    String? knowledgePoint,
    String? grade,
    String? difficulty,
    String? requirement,
    String? description,
    List<String>? relatedTopics,
  }) {
    return CurriculumOutline(
      id: id ?? this.id,
      knowledgePoint: knowledgePoint ?? this.knowledgePoint,
      grade: grade ?? this.grade,
      difficulty: difficulty ?? this.difficulty,
      requirement: requirement ?? this.requirement,
      description: description ?? this.description,
      relatedTopics: relatedTopics ?? this.relatedTopics,
    );
  }
}
