class Syllabus {
  final int? id;
  final String chapter;
  final String? section;
  final String knowledgePoint;
  final String? difficulty; // easy/medium/hard
  final double? examWeight; // 考试权重 (%)
  final String? description;
  final int version;
  final DateTime createdAt;

  Syllabus({
    this.id,
    required this.chapter,
    this.section,
    required this.knowledgePoint,
    this.difficulty,
    this.examWeight,
    this.description,
    this.version = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chapter': chapter,
      'section': section,
      'knowledge_point': knowledgePoint,
      'difficulty': difficulty,
      'exam_weight': examWeight,
      'description': description,
      'version': version,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Syllabus.fromMap(Map<String, dynamic> map) {
    return Syllabus(
      id: map['id'],
      chapter: map['chapter'],
      section: map['section'],
      knowledgePoint: map['knowledge_point'],
      difficulty: map['difficulty'],
      examWeight: map['exam_weight'],
      description: map['description'],
      version: map['version'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
