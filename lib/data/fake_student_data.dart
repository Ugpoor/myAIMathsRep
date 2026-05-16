import 'dart:math';

final Random _random = Random(42);

final List<String> _surnames = [
  '张',
  '李',
  '王',
  '赵',
  '刘',
  '陈',
  '杨',
  '黄',
  '周',
  '吴',
  '徐',
  '孙',
  '马',
  '朱',
  '胡',
  '林',
  '何',
  '郭',
  '罗',
  '梁',
];
final List<String> _givenNames = [
  '伟',
  '强',
  '勇',
  '军',
  '敏',
  '娜',
  '静',
  '磊',
  '芳',
  '涛',
  '明',
  '华',
  '丽',
  '杰',
  '秀',
  '霞',
  '强',
  '文',
  '辉',
  '燕',
];

List<Map<String, dynamic>> generateStudentData() {
  final students = <Map<String, dynamic>>[];

  for (int i = 1; i <= 36; i++) {
    final surname = _surnames[_random.nextInt(_surnames.length)];
    final givenName = _givenNames[_random.nextInt(_givenNames.length)];

    final score = 40 + _random.nextInt(61);
    final knowledge = 40 + _random.nextInt(61);
    final literacy = 40 + _random.nextInt(61);
    final overall = ((score + knowledge + literacy) / 3).round();

    final trendRisk = _random.nextInt(100);
    final abilityRisk = _random.nextInt(100);
    final mindsetRisk = _random.nextInt(100);
    final behaviorRisk = _random.nextInt(100);

    students.add({
      'id': i.toString().padLeft(2, '0'),
      'name': '$surname$givenName',
      'studentId': '2026${i.toString().padLeft(3, '0')}',
      'deviceId': 'DEV10${i.toString().padLeft(2, '0')}',
      'score': score,
      'knowledge': knowledge,
      'literacy': literacy,
      'overall': overall,
      'trendRisk': trendRisk,
      'abilityRisk': abilityRisk,
      'mindsetRisk': mindsetRisk,
      'behaviorRisk': behaviorRisk,
    });
  }

  return students;
}

final List<Map<String, dynamic>> studentData = generateStudentData();

Map<String, dynamic> calculateClassStats() {
  if (studentData.isEmpty) {
    return {
      'averageScore': 0,
      'scoreChange': 0,
      'riskCount': 0,
      'riskRate': 0.0,
      'unfinishedHomework': 0,
      'unfinishedRate': 0.0,
      'groupCompletion': 0,
      'groupCompletionRate': 0.0,
      'weakKnowledgeCount': 0,
      'weakKnowledgeRate': 0.0,
      'examProgress': 0,
      'examProgressRate': 0.0,
      'todoCount': 0,
      'deviceOnline': 0,
      'deviceOnlineRate': 0.0,
    };
  }

  final totalScore = studentData.fold(0, (sum, s) => sum + (s['score'] as int));
  final avgScore = (totalScore / studentData.length).round();

  final riskCount = studentData.where((s) {
    return s['trendRisk'] >= 60 ||
        s['abilityRisk'] >= 60 ||
        s['mindsetRisk'] >= 60 ||
        s['behaviorRisk'] >= 60;
  }).length;

  final weakKnowledgeCount = studentData
      .where((s) => s['knowledge'] < 60)
      .length;

  return {
    'averageScore': avgScore,
    'scoreChange': 4,
    'riskCount': riskCount,
    'riskRate': ((riskCount / studentData.length) * 100).round(),
    'unfinishedHomework': 12,
    'unfinishedRate': 29,
    'groupCompletion': 14,
    'groupCompletionRate': 100,
    'weakKnowledgeCount': weakKnowledgeCount,
    'weakKnowledgeRate':
        ((weakKnowledgeCount / studentData.length) * 10).round() * 10,
    'examProgress': 17,
    'examProgressRate': 17,
    'todoCount': 10,
    'deviceOnline': studentData.length - 1,
    'deviceOnlineRate': 98,
  };
}

final Map<String, dynamic> classStats = calculateClassStats();

const Map<String, Map<String, int>> riskThresholds = {
  '高风险': {'min': 70, 'max': 100},
  '中风险': {'min': 40, 'max': 69},
  '低风险': {'min': 0, 'max': 39},
};

String getRiskLevel(int value) {
  if (value >= riskThresholds['高风险']!['min']!) return '高风险';
  if (value >= riskThresholds['中风险']!['min']!) return '中风险';
  return '低风险';
}
