
import '../database/db_helper.dart';
import '../data/fake_student_data.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isInitialized = false;

  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    await _syncFakeData();
    _isInitialized = true;
  }

  Future<void> _syncFakeData() async {
    // 同步小组数据
    for (final groupName in groupNames) {
      await _dbHelper.insert(
        'groups',
        {
          'name': groupName,
        },
      );
    }

    // 同步学生数据
    for (final student in studentData) {
      await _dbHelper.insert(
        'students',
        {
          'name': student['name'],
          'student_id': student['studentId'],
          'device_id': student['deviceId'],
          'group_name': student['group'],
          'score': student['score'],
          'knowledge': student['knowledge'],
          'literacy': student['literacy'],
          'overall': student['overall'],
          'trend_risk': student['trendRisk'],
          'ability_risk': student['abilityRisk'],
          'mindset_risk': student['mindsetRisk'],
          'behavior_risk': student['behaviorRisk'],
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    return await _dbHelper.query('students', orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getGroups() async {
    return await _dbHelper.query('groups', orderBy: 'id');
  }

  Future<List<Map<String, dynamic>>> getGroupStudents(String groupName) async {
    return await _dbHelper.query(
      'students',
      where: 'group_name = ?',
      whereArgs: [groupName],
      orderBy: 'id',
    );
  }

  Future<void> updateStudent(Map<String, dynamic> student) async {
    await _dbHelper.update(
      'students',
      {
        'name': student['name'],
        'student_id': student['studentId'],
        'device_id': student['deviceId'],
        'group_name': student['group'],
      },
      where: 'student_id = ?',
      whereArgs: [student['studentId']],
    );
  }

  Future<void> insertStudent(Map<String, dynamic> student) async {
    await _dbHelper.insert('students', {
      'name': student['name'],
      'student_id': student['studentId'],
      'device_id': student['deviceId'],
      'group_name': student['group'],
      'score': student['score'],
      'knowledge': student['knowledge'],
      'literacy': student['literacy'],
      'overall': student['overall'],
      'trend_risk': student['trendRisk'],
      'ability_risk': student['abilityRisk'],
      'mindset_risk': student['mindsetRisk'],
      'behavior_risk': student['behaviorRisk'],
    });
  }

  Future<void> deleteStudent(String studentId) async {
    await _dbHelper.delete(
      'students',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> insertGroup(String groupName) async {
    await _dbHelper.insert('groups', {'name': groupName});
  }
}
