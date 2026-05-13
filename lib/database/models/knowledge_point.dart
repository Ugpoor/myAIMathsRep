
import 'package:sqflite/sqflite.dart';

class KnowledgePoint {
  final int? id;
  final String title;
  final String? content;
  final String? category;
  final int difficulty;
  final bool mastered;
  final DateTime? createdAt;
  final String lang;

  KnowledgePoint({
    this.id,
    required this.title,
    this.content,
    this.category,
    this.difficulty = 1,
    this.mastered = false,
    this.createdAt,
    this.lang = 'cn',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'mastered': mastered ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'lang': lang,
    };
  }

  static KnowledgePoint fromMap(Map<String, dynamic> map) {
    return KnowledgePoint(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String?,
      category: map['category'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
      mastered: (map['mastered'] as int?) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      lang: map['lang'] as String? ?? 'cn',
    );
  }

  KnowledgePoint copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? difficulty,
    bool? mastered,
    DateTime? createdAt,
    String? lang,
  }) {
    return KnowledgePoint(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      mastered: mastered ?? this.mastered,
      createdAt: createdAt ?? this.createdAt,
      lang: lang ?? this.lang,
    );
  }
}

class KnowledgePointDao {
  final Database db;

  KnowledgePointDao(this.db);

  Future<int> insert(KnowledgePoint point) async {
    return await db.insert('knowledge_points', point.toMap());
  }

  Future<List<KnowledgePoint>> getAll({String? lang, String? category}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }

    final maps = await db.query(
      'knowledge_points',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'difficulty ASC, title ASC',
    );
    return maps.map((map) => KnowledgePoint.fromMap(map)).toList();
  }

  Future<KnowledgePoint?> getById(int id) async {
    final maps = await db.query(
      'knowledge_points',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? KnowledgePoint.fromMap(maps.first) : null;
  }

  Future<int> update(KnowledgePoint point) async {
    return await db.update(
      'knowledge_points',
      point.toMap(),
      where: 'id = ?',
      whereArgs: [point.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'knowledge_points',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang, String? category}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM knowledge_points${conditions.isNotEmpty ? " WHERE ${conditions.join(' AND ')}" : ""}',
      args.isNotEmpty ? args : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
