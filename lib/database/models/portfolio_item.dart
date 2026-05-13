
import 'package:sqflite/sqflite.dart';

class PortfolioItem {
  final int? id;
  final String title;
  final String? type;
  final String? contentPath;
  final String? thumbnailPath;
  final DateTime? createdAt;
  final String lang;

  PortfolioItem({
    this.id,
    required this.title,
    this.type,
    this.contentPath,
    this.thumbnailPath,
    this.createdAt,
    this.lang = 'cn',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'content_path': contentPath,
      'thumbnail_path': thumbnailPath,
      'created_at': createdAt?.toIso8601String(),
      'lang': lang,
    };
  }

  static PortfolioItem fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: map['type'] as String?,
      contentPath: map['content_path'] as String?,
      thumbnailPath: map['thumbnail_path'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      lang: map['lang'] as String? ?? 'cn',
    );
  }

  PortfolioItem copyWith({
    int? id,
    String? title,
    String? type,
    String? contentPath,
    String? thumbnailPath,
    DateTime? createdAt,
    String? lang,
  }) {
    return PortfolioItem(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      contentPath: contentPath ?? this.contentPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      createdAt: createdAt ?? this.createdAt,
      lang: lang ?? this.lang,
    );
  }
}

class PortfolioDao {
  final Database db;

  PortfolioDao(this.db);

  Future<int> insert(PortfolioItem item) async {
    return await db.insert('portfolio_items', item.toMap());
  }

  Future<List<PortfolioItem>> getAll({String? lang, String? type}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }

    final maps = await db.query(
      'portfolio_items',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => PortfolioItem.fromMap(map)).toList();
  }

  Future<PortfolioItem?> getById(int id) async {
    final maps = await db.query(
      'portfolio_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? PortfolioItem.fromMap(maps.first) : null;
  }

  Future<int> update(PortfolioItem item) async {
    return await db.update(
      'portfolio_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'portfolio_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang, String? type}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (type != null) {
      conditions.add('type = ?');
      args.add(type);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM portfolio_items${conditions.isNotEmpty ? " WHERE ${conditions.join(' AND ')}" : ""}',
      args.isNotEmpty ? args : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
