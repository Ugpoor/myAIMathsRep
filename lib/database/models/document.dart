
import 'package:sqflite/sqflite.dart';

class Document {
  final int? id;
  final String title;
  final String folderName;
  final String? url;
  final String? source;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String lang;
  final String? category;
  final String status;

  Document({
    this.id,
    required this.title,
    required this.folderName,
    this.url,
    this.source,
    this.createdAt,
    this.updatedAt,
    this.lang = 'cn',
    this.category,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'folder_name': folderName,
      'url': url,
      'source': source,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'lang': lang,
      'category': category,
      'status': status,
    };
  }

  static Document fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      title: map['title'] as String,
      folderName: map['folder_name'] as String,
      url: map['url'] as String?,
      source: map['source'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
      lang: map['lang'] as String? ?? 'cn',
      category: map['category'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }

  Document copyWith({
    int? id,
    String? title,
    String? folderName,
    String? url,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lang,
    String? category,
    String? status,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      folderName: folderName ?? this.folderName,
      url: url ?? this.url,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lang: lang ?? this.lang,
      category: category ?? this.category,
      status: status ?? this.status,
    );
  }
}

class DocumentDao {
  final Database db;

  DocumentDao(this.db);

  Future<int> insert(Document document) async {
    return await db.insert('documents', document.toMap());
  }

  Future<List<Document>> getAll({String? lang}) async {
    final maps = await db.query(
      'documents',
      where: lang != null ? 'lang = ?' : null,
      whereArgs: lang != null ? [lang] : null,
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Document.fromMap(map)).toList();
  }

  Future<Document?> getById(int id) async {
    final maps = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Document.fromMap(maps.first) : null;
  }

  Future<int> update(Document document) async {
    return await db.update(
      'documents',
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang}) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM documents${lang != null ? " WHERE lang = ?" : ""}',
      lang != null ? [lang] : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
