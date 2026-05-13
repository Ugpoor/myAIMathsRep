
import 'package:sqflite/sqflite.dart';

class Setting {
  final int? id;
  final String key;
  final String? value;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Setting({
    this.id,
    required this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'value': value,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static Setting fromMap(Map<String, dynamic> map) {
    return Setting(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }
}

class SettingsDao {
  final Database db;

  SettingsDao(this.db);

  Future<int> insert(Setting setting) async {
    return await db.insert('settings', setting.toMap());
  }

  Future<String?> get(String key) async {
    final maps = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    return maps.isNotEmpty ? maps.first['value'] as String? : null;
  }

  Future<int> set(String key, String value) async {
    final existing = await get(key);
    if (existing != null) {
      return await db.update(
        'settings',
        {'value': value, 'updated_at': DateTime.now().toIso8601String()},
        where: 'key = ?',
        whereArgs: [key],
      );
    } else {
      return await insert(Setting(
        key: key,
        value: value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
  }

  Future<int> delete(String key) async {
    return await db.delete(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<List<Setting>> getAll() async {
    final maps = await db.query('settings');
    return maps.map((map) => Setting.fromMap(map)).toList();
  }
}
