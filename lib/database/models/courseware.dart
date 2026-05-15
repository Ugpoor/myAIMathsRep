class Courseware {
  final int? id;
  final String title;
  final String? knowledgePoint;
  final String? cognitiveMode; // logical/visual/kinesthetic
  final String? content; // Markdown/HTML/Flutter Widget code
  final String? contentType; // markdown/html/flutter_widget
  final List<Map<String, String>>? slides;
  final int viewCount;
  final String status; // draft/published
  final DateTime createdAt;

  Courseware({
    this.id,
    required this.title,
    this.knowledgePoint,
    this.cognitiveMode,
    this.content,
    this.contentType,
    this.slides,
    this.viewCount = 0,
    this.status = 'draft',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'knowledge_point': knowledgePoint,
      'cognitive_mode': cognitiveMode,
      'content': content,
      'content_type': contentType,
      'view_count': viewCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Courseware.fromMap(Map<String, dynamic> map) {
    return Courseware(
      id: map['id'],
      title: map['title'],
      knowledgePoint: map['knowledge_point'],
      cognitiveMode: map['cognitive_mode'],
      content: map['content'],
      contentType: map['content_type'],
      viewCount: map['view_count'] ?? 0,
      status: map['status'] ?? 'draft',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
