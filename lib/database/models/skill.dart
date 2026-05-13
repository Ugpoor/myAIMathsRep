
import 'package:sqflite/sqflite.dart';

class Skill {
  final int? id;
  final String name;
  final int level;
  final double progress;
  final DateTime? lastPracticed;
  final DateTime? createdAt;
  final String lang;

  Skill({
    this.id,
    required this.name,
    this.level = 1,
    this.progress = 0,
    this.lastPracticed,
    this.createdAt,
    this.lang = 'cn',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'progress': progress,
      'last_practiced': lastPracticed?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'lang': lang,
    };
  }

  static Skill fromMap(Map<String, dynamic> map) {
    return Skill(
      id: map['id'] as int?,
      name: map['name'] as String,
      level: map['level'] as int? ?? 1,
      progress: (map['progress'] as double?) ?? 0,
      lastPracticed: map['last_practiced'] != null 
          ? DateTime.parse(map['last_practiced'] as String) 
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      lang: map['lang'] as String? ?? 'cn',
    );
  }

  Skill copyWith({
    int? id,
    String? name,
    int? level,
    double? progress,
    DateTime? lastPracticed,
    DateTime? createdAt,
    String? lang,
  }) {
    return Skill(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      createdAt: createdAt ?? this.createdAt,
      lang: lang ?? this.lang,
    );
  }
}

class SkillDao {
  final Database db;

  SkillDao(this.db);

  Future<int> insert(Skill skill) async {
    return await db.insert('skills', skill.toMap());
  }

  Future<List<Skill>> getAll({String? lang}) async {
    final maps = await db.query(
      'skills',
      where: lang != null ? 'lang = ?' : null,
      whereArgs: lang != null ? [lang] : null,
      orderBy: 'level DESC, progress DESC',
    );
    return maps.map((map) => Skill.fromMap(map)).toList();
  }

  Future<Skill?> getById(int id) async {
    final maps = await db.query(
      'skills',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Skill.fromMap(maps.first) : null;
  }

  Future<int> update(Skill skill) async {
    return await db.update(
      'skills',
      skill.toMap(),
      where: 'id = ?',
      whereArgs: [skill.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'skills',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang}) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM skills${lang != null ? " WHERE lang = ?" : ""}',
      lang != null ? [lang] : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
