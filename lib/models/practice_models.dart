class StudentKnowledgeProfile {
  final String studentId;
  final String studentName;
  final Map<String, KnowledgePointStats> knowledgeStats;
  final List<String> weakKnowledgePoints;
  final List<String> strongKnowledgePoints;

  StudentKnowledgeProfile({
    required this.studentId,
    required this.studentName,
    required this.knowledgeStats,
    required this.weakKnowledgePoints,
    required this.strongKnowledgePoints,
  });
}

class KnowledgePointStats {
  final String knowledgePoint;
  int totalAttempts;
  int correctAttempts;
  int errorAttempts;
  double masteryLevel;

  KnowledgePointStats({
    required this.knowledgePoint,
    this.totalAttempts = 0,
    this.correctAttempts = 0,
    this.errorAttempts = 0,
    this.masteryLevel = 0.0,
  });

  double get accuracyRate =>
      totalAttempts > 0 ? correctAttempts / totalAttempts : 0.0;

  String get masteryLabel {
    if (masteryLevel >= 0.9) return '精通';
    if (masteryLevel >= 0.7) return '掌握';
    if (masteryLevel >= 0.5) return '一般';
    if (masteryLevel >= 0.3) return '薄弱';
    return '很差';
  }
}

class Question {
  final String questionId;
  final String knowledgePoint;
  final String content;
  final String answer;
  final String difficulty;
  final String questionType;
  final List<String> similarQuestions;

  Question({
    required this.questionId,
    required this.knowledgePoint,
    required this.content,
    required this.answer,
    required this.difficulty,
    required this.questionType,
    this.similarQuestions = const [],
  });
}

class ErrorRecord {
  final String recordId;
  final String studentId;
  final String studentName;
  final String questionId;
  final String knowledgePoint;
  final DateTime errorDate;
  final String errorReason;
  final bool isCorrected;
  final String? correctionDate;

  ErrorRecord({
    required this.recordId,
    required this.studentId,
    required this.studentName,
    required this.questionId,
    required this.knowledgePoint,
    required this.errorDate,
    required this.errorReason,
    this.isCorrected = false,
    this.correctionDate,
  });
}

class GeneratedPractice {
  final String practiceId;
  final String studentId;
  final String studentName;
  final List<PracticeQuestion> questions;
  final DateTime generatedDate;
  final String targetKnowledgePoint;
  final String difficulty;

  GeneratedPractice({
    required this.practiceId,
    required this.studentId,
    required this.studentName,
    required this.questions,
    required this.generatedDate,
    required this.targetKnowledgePoint,
    required this.difficulty,
  });
}

class PracticeQuestion {
  final String questionId;
  final String content;
  final String answer;
  final String difficulty;
  final String knowledgePoint;
  final String sourceType;
  final String? sourceQuestionId;

  PracticeQuestion({
    required this.questionId,
    required this.content,
    required this.answer,
    required this.difficulty,
    required this.knowledgePoint,
    this.sourceType = '新题',
    this.sourceQuestionId,
  });
}

class PracticeGeneratorConfig {
  final String difficultyAdjustment;
  final String diffusionLevel;
  final List<String> knowledgeFence;
  final int targetQuestionCount;
  final int timeLimit;
  final List<String> excludedStudentIds;

  PracticeGeneratorConfig({
    this.difficultyAdjustment = '不变',
    this.diffusionLevel = '不扩散',
    this.knowledgeFence = const [],
    this.targetQuestionCount = 5,
    this.timeLimit = 30,
    this.excludedStudentIds = const [],
  });
}
