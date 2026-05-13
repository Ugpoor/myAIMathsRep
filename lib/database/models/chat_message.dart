
import 'package:sqflite/sqflite.dart';

class ChatMessage {
  final int? id;
  final String content;
  final String reasoning;
  final bool isUser;
  final DateTime createdAt;
  final String lang;

  ChatMessage({
    this.id,
    required this.content,
    this.reasoning = '',
    required this.isUser,
    required this.createdAt,
    this.lang = 'cn',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'reasoning': reasoning,
      'is_user': isUser ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'lang': lang,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int?,
      content: map['content'] as String,
      reasoning: map['reasoning'] as String? ?? '',
      isUser: (map['is_user'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      lang: map['lang'] as String? ?? 'cn',
    );
  }

  ChatMessage copyWith({
    int? id,
    String? content,
    String? reasoning,
    bool? isUser,
    DateTime? createdAt,
    String? lang,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      reasoning: reasoning ?? this.reasoning,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      lang: lang ?? this.lang,
    );
  }
}

class ChatMessageDao {
  final Database db;

  ChatMessageDao(this.db);

  Future<int> insert(ChatMessage message) async {
    return await db.insert('chat_messages', message.toMap());
  }

  Future<List<ChatMessage>> getAll({String? lang}) async {
    final maps = await db.query(
      'chat_messages',
      where: lang != null ? 'lang = ?' : null,
      whereArgs: lang != null ? [lang] : null,
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => ChatMessage.fromMap(map)).toList();
  }

  Future<ChatMessage?> getById(int id) async {
    final maps = await db.query(
      'chat_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? ChatMessage.fromMap(maps.first) : null;
  }

  Future<int> update(ChatMessage message) async {
    return await db.update(
      'chat_messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'chat_messages',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang}) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM chat_messages${lang != null ? " WHERE lang = ?" : ""}',
      lang != null ? [lang] : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> clear() async {
    await db.delete('chat_messages');
  }
}
