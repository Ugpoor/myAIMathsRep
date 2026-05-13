
import 'package:sqflite/sqflite.dart';

class TodoItem {
  final int? id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final bool completed;
  final int priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String lang;

  TodoItem({
    this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.completed = false,
    this.priority = 1,
    this.createdAt,
    this.updatedAt,
    this.lang = 'cn',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'completed': completed ? 1 : 0,
      'priority': priority,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'lang': lang,
    };
  }

  static TodoItem fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      dueDate: map['due_date'] != null 
          ? DateTime.parse(map['due_date'] as String) 
          : null,
      completed: (map['completed'] as int?) == 1,
      priority: map['priority'] as int? ?? 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
      lang: map['lang'] as String? ?? 'cn',
    );
  }

  TodoItem copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? completed,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lang,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lang: lang ?? this.lang,
    );
  }
}

class TodoDao {
  final Database db;

  TodoDao(this.db);

  Future<int> insert(TodoItem item) async {
    return await db.insert('todo_items', item.toMap());
  }

  Future<List<TodoItem>> getAll({String? lang, bool? completed}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (completed != null) {
      conditions.add('completed = ?');
      args.add(completed ? 1 : 0);
    }

    final maps = await db.query(
      'todo_items',
      where: conditions.isNotEmpty ? conditions.join(' AND ') : null,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'priority DESC, due_date ASC',
    );
    return maps.map((map) => TodoItem.fromMap(map)).toList();
  }

  Future<TodoItem?> getById(int id) async {
    final maps = await db.query(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? TodoItem.fromMap(maps.first) : null;
  }

  Future<int> update(TodoItem item) async {
    return await db.update(
      'todo_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(int id) async {
    return await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> count({String? lang, bool? completed}) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (lang != null) {
      conditions.add('lang = ?');
      args.add(lang);
    }
    if (completed != null) {
      conditions.add('completed = ?');
      args.add(completed ? 1 : 0);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM todo_items${conditions.isNotEmpty ? " WHERE ${conditions.join(' AND ')}" : ""}',
      args.isNotEmpty ? args : null,
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
