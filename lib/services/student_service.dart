
import 'dart:math';
import '../database/db_helper.dart';
import '../database/models/student.dart';
import '../database/models/exam.dart';
import '../database/models/student_exam.dart';

class StudentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<String> _surnames = [
    '张', '李', '王', '刘', '陈', '杨', '赵', '黄', '周', '吴',
    '徐', '孙', '马', '朱', '胡', '林', '何', '郭', '罗', '高',
    '郑', '梁', '谢', '宋', '唐', '许', '韩', '冯', '邓', '曹',
    '彭', '曾', '肖', '田', '董', '袁'
  ];

  final List<String> _givenNames = [
    '小明', '小红', '小华', '小丽', '小军', '小芳', '小强', '小雪',
    '小雨', '小雷', '小晴', '小阳', '小月', '小星', '小海', '小峰',
    '小涛', '小波', '小勇', '小亮', '小燕', '小妮', '小琳', '小婷',
    '小雯', '小茜', '小茹', '小娜', '小蕾', '小蕊', '小琪', '小琳',
    '小龙', '小虎', '小豹', '小鹰'
  ];

  final List<String> _examNames = [
    '第一次月考', '第二次月考', '期中考试', '第三次月考', '第四次月考'
  ];

  Future<void> initFakeData() async {
    final studentCount = await _dbHelper.count('students');
    if (studentCount > 0) return;

    final random = Random(42);

    for (int i = 0; i < 36; i++) {
      final surname = _surnames[random.nextInt(_surnames.length)];
      final givenName = _givenNames[i % _givenNames.length];
      final name = '$surname$givenName';
      final studentId = '2026${(i + 1).toString().padLeft(3, '0')}';
      final deviceId = 'DEV${(1001 + i).toString().padLeft(4, '0')}';

      final student = Student(
        name: name,
        studentId: studentId,
        deviceId: deviceId,
      );

      final studentDbId = await _dbHelper.insert('students', student.toMap());

      for (int j = 0; j < 5; j++) {
        if (j == 0) {
          await _ensureExamExists(j);
        }

        final exam = await _getExamByName(_examNames[j]);
        if (exam == null) continue;

        final wrongCount = random.nextInt(8) + 2;
        final wrongAnswers = <int>{};
        while (wrongAnswers.length < wrongCount) {
          wrongAnswers.add(random.nextInt(20) + 1);
        }

        final studentExam = StudentExam(
          studentId: studentDbId,
          examId: exam.id!,
          wrongAnswers: wrongAnswers.join(','),
        );

        await _dbHelper.insert('student_exams', studentExam.toMap());
      }
    }
  }

  Future<void> _ensureExamExists(int index) async {
    for (int i = index; i < _examNames.length; i++) {
      final count = await _dbHelper.count('exams', where: 'name = ?', whereArgs: [_examNames[i]]);
      if (count == 0) {
        final exam = Exam(
          name: _examNames[i],
          totalQuestions: 20,
          scorePerQuestion: 5,
        );
        await _dbHelper.insert('exams', exam.toMap());
      }
    }
  }

  Future<Exam?> _getExamByName(String name) async {
    final result = await _dbHelper.query('exams', where: 'name = ?', whereArgs: [name]);
    if (result.isEmpty) return null;
    return Exam.fromMap(result.first);
  }

  Future<List<Student>> getAllStudents() async {
    final result = await _dbHelper.query('students', orderBy: 'student_id');
    return result.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudentById(int id) async {
    final result = await _dbHelper.query('students', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Student.fromMap(result.first);
  }

  Future<List<Exam>> getAllExams() async {
    final result = await _dbHelper.query('exams', orderBy: 'id');
    return result.map((map) => Exam.fromMap(map)).toList();
  }

  Future<List<StudentExam>> getStudentExams(int studentId) async {
    final result = await _dbHelper.query('student_exams', where: 'student_id = ?', whereArgs: [studentId]);
    return result.map((map) => StudentExam.fromMap(map)).toList();
  }

  Future<double> getStudentAverageScore(int studentId) async {
    final exams = await getAllExams();
    final studentExams = await getStudentExams(studentId);

    if (exams.isEmpty || studentExams.isEmpty) return 0;

    double totalScore = 0;
    int count = 0;

    for (final exam in exams) {
      final studentExam = studentExams.firstWhere(
        (se) => se.examId == exam.id,
        orElse: () => StudentExam(studentId: studentId, examId: exam.id!, wrongAnswers: ''),
      );

      final correctCount = exam.totalQuestions - studentExam.wrongAnswersList.length;
      totalScore += correctCount * exam.scorePerQuestion;
      count++;
    }

    return count > 0 ? totalScore / count : 0;
  }

  Future<int> getStudentWrongCount(int studentId) async {
    final studentExams = await getStudentExams(studentId);
    return studentExams.fold<int>(0, (sum, se) => sum + se.wrongAnswersList.length);
  }

  Future<List<int>> getStudentWeakTopics(int studentId) async {
    final topicCount = <int, int>{};
    final studentExams = await getStudentExams(studentId);

    for (final se in studentExams) {
      for (final wrong in se.wrongAnswersList) {
        final topic = (wrong - 1) ~/ 4 + 1;
        topicCount[topic] = (topicCount[topic] ?? 0) + 1;
      }
    }

    return topicCount.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .toList();
  }

  Future<Map<String, dynamic>> calculateClassStats() async {
    final students = await getAllStudents();

    if (students.isEmpty) {
      return {
        'averageScore': 0,
        'riskCount': 0,
        'riskPercentage': 0,
        'homeworkNotSubmitted': 12,
        'homeworkPercentage': 29,
        'groupCompletion': 14,
        'groupPercentage': 100,
        'weakKnowledgeCount': 0,
        'weakKnowledgePercentage': 10,
        'examProgress': 63,
        'todoCount': 10,
        'deviceOnline': 0,
        'devicePercentage': 98,
      };
    }

    double totalScore = 0;
    int riskCount = 0;
    int totalWrongCount = 0;

    for (final student in students) {
      final avgScore = await getStudentAverageScore(student.id!);
      totalScore += avgScore;
      if (avgScore < 60) riskCount++;
      totalWrongCount += await getStudentWrongCount(student.id!);
    }

    final averageScore = totalScore / students.length;
    final riskPercentage = (riskCount / students.length * 100).round();
    final deviceOnline = (students.length * 0.98).round();

    return {
      'averageScore': averageScore.round(),
      'riskCount': riskCount,
      'riskPercentage': riskPercentage,
      'homeworkNotSubmitted': 12,
      'homeworkPercentage': 29,
      'groupCompletion': 14,
      'groupPercentage': 100,
      'weakKnowledgeCount': totalWrongCount,
      'weakKnowledgePercentage': 10,
      'examProgress': 63,
      'todoCount': 10,
      'deviceOnline': deviceOnline,
      'devicePercentage': 98,
    };
  }

  Future<int> insertStudent(Student student) async {
    return await _dbHelper.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    if (student.id == null) return 0;
    return await _dbHelper.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    return await _dbHelper.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertExam(Exam exam) async {
    return await _dbHelper.insert('exams', exam.toMap());
  }

  Future<int> insertStudentExam(StudentExam studentExam) async {
    return await _dbHelper.insert('student_exams', studentExam.toMap());
  }

  Future<void> clearAllData() async {
    await _dbHelper.delete('student_exams', where: '1=1', whereArgs: []);
    await _dbHelper.delete('exams', where: '1=1', whereArgs: []);
    await _dbHelper.delete('students', where: '1=1', whereArgs: []);
  }
}