import 'dart:math';
import '../models/practice_models.dart';

class PracticeGeneratorService {
  final Random _random = Random();

  final List<Question> _questionBank = [
    Question(
      questionId: 'Q001',
      knowledgePoint: '二次函数',
      content: '已知二次函数y=ax²+bx+c经过点(1,0)、(2,0)、(3,6)，求a、b、c的值。',
      answer: 'a=3, b=-10, c=7',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q002',
      knowledgePoint: '二次函数',
      content: '求二次函数y=x²-4x+3的顶点坐标和对称轴。',
      answer: '顶点(2,-1)，对称轴x=2',
      difficulty: '简单',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q003',
      knowledgePoint: '二次函数',
      content: '若二次函数y=ax²+bx+c的图像开口向下，且顶点在原点，求a、b、c满足的条件。',
      answer: 'a<0, b=0, c=0',
      difficulty: '困难',
      questionType: '证明题',
    ),
    Question(
      questionId: 'Q004',
      knowledgePoint: '二次函数',
      content: '已知二次函数y=2x²-4x+1，求其在x=3处的函数值。',
      answer: 'y=7',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q005',
      knowledgePoint: '二次函数',
      content: '二次函数y=x²-mx+4与x轴有两个交点，求m的取值范围。',
      answer: 'm<-4或m>4',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q006',
      knowledgePoint: '三角形全等',
      content: '已知△ABC中，AB=AC，AD是角平分线，证明△ABD≌△ACD。',
      answer: '证明：∵AB=AC，AD为公共边，∠BAD=∠CAD，∴△ABD≌△ACD(SAS)',
      difficulty: '中等',
      questionType: '证明题',
    ),
    Question(
      questionId: 'Q007',
      knowledgePoint: '三角形全等',
      content: '在△ABC中，AB=5，AC=7，BC=6，求∠A的余弦值。',
      answer: 'cosA=19/35',
      difficulty: '困难',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q008',
      knowledgePoint: '三角形全等',
      content: '判断：有两边和其中一边上的中线对应相等的两个三角形全等。( )',
      answer: '正确',
      difficulty: '简单',
      questionType: '判断题',
    ),
    Question(
      questionId: 'Q009',
      knowledgePoint: '三角形全等',
      content: '已知△ABC≌△DEF，AB=3，BC=4，CA=5，求△DEF的周长。',
      answer: '12',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q010',
      knowledgePoint: '三角形全等',
      content: '用SSS证明三角形全等需要哪些条件？',
      answer: '三条边分别对应相等',
      difficulty: '简单',
      questionType: '简答题',
    ),
    Question(
      questionId: 'Q011',
      knowledgePoint: '圆的性质',
      content: '已知圆的半径为5，圆心到直线的距离为3，求圆心到直线的垂足在圆内的线段长度。',
      answer: '4',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q012',
      knowledgePoint: '圆的性质',
      content: '判断：垂直于弦的直径平分这条弦。( )',
      answer: '正确',
      difficulty: '简单',
      questionType: '判断题',
    ),
    Question(
      questionId: 'Q013',
      knowledgePoint: '圆的性质',
      content: '已知圆的方程为x²+y²=25，求圆上点到直线x+y=7的最大距离。',
      answer: '7√2-5',
      difficulty: '困难',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q014',
      knowledgePoint: '圆的性质',
      content: '圆的直径为10，则圆的面积为多少？',
      answer: '25π',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q015',
      knowledgePoint: '圆的性质',
      content: '已知弧长为6π，对应圆心角为60°，求圆的半径。',
      answer: '18',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q016',
      knowledgePoint: '相似三角形',
      content: '已知△ABC～△DEF，相似比为2:3，△ABC的面积为8，求△DEF的面积。',
      answer: '18',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q017',
      knowledgePoint: '相似三角形',
      content: '判断：相似三角形的对应高之比等于相似比。( )',
      answer: '正确',
      difficulty: '简单',
      questionType: '判断题',
    ),
    Question(
      questionId: 'Q018',
      knowledgePoint: '相似三角形',
      content: '在△ABC中，DE‖BC，AD:DB=2:3，AE=4，求EC的长。',
      answer: '6',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q019',
      knowledgePoint: '相似三角形',
      content: '两个相似三角形的面积比为4:9，则它们的周长比为多少？',
      answer: '2:3',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q020',
      knowledgePoint: '相似三角形',
      content: '已知△ABC～△DEF，AB=4，BC=5，CA=6，DE=8，求△DEF的周长。',
      answer: '30',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q021',
      knowledgePoint: '实数运算',
      content: '化简：√50 - √18 + √8',
      answer: '4√2',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q022',
      knowledgePoint: '实数运算',
      content: '计算：(√3 + 1)(√3 - 1)',
      answer: '2',
      difficulty: '简单',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q023',
      knowledgePoint: '实数运算',
      content: '若|a-3|=5，且a<0，求a的值。',
      answer: 'a=-2',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q024',
      knowledgePoint: '实数运算',
      content: '化简：|3-π| + |π-4|',
      answer: '1',
      difficulty: '中等',
      questionType: '计算题',
    ),
    Question(
      questionId: 'Q025',
      knowledgePoint: '实数运算',
      content: '已知x²=9，y³=-8，求x+y的值。',
      answer: 'x=±3, y=-2，所以x+y=1或-5',
      difficulty: '困难',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q026',
      knowledgePoint: '一元二次方程',
      content: '解方程：x²-5x+6=0',
      answer: 'x=2或x=3',
      difficulty: '简单',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q027',
      knowledgePoint: '一元二次方程',
      content: '已知方程x²+mx+9=0有两个相等的实数根，求m的值。',
      answer: 'm=±6',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q028',
      knowledgePoint: '一元二次方程',
      content: '用配方法解方程：x²+4x-5=0',
      answer: '(x+2)²=9，x=1或x=-5',
      difficulty: '中等',
      questionType: '解答题',
    ),
    Question(
      questionId: 'Q029',
      knowledgePoint: '一元二次方程',
      content: '判断：方程x²+x+1=0有实数根。( )',
      answer: '错误',
      difficulty: '简单',
      questionType: '判断题',
    ),
    Question(
      questionId: 'Q030',
      knowledgePoint: '一元二次方程',
      content: '若关于x的方程x²-2kx+k²-1=0的两个根都在-2和4之间，求k的取值范围。',
      answer: '-1<k<3',
      difficulty: '困难',
      questionType: '解答题',
    ),
  ];

  Map<String, KnowledgePointStats> _calculateKnowledgeStats(
    List<ErrorRecord> errors,
    String studentId,
  ) {
    final stats = <String, KnowledgePointStats>{};

    for (final error in errors.where((e) => e.studentId == studentId)) {
      if (!stats.containsKey(error.knowledgePoint)) {
        stats[error.knowledgePoint] = KnowledgePointStats(
          knowledgePoint: error.knowledgePoint,
        );
      }

      final pointStats = stats[error.knowledgePoint]!;
      pointStats.totalAttempts++;

      if (error.isCorrected) {
        pointStats.correctAttempts++;
      } else {
        pointStats.errorAttempts++;
      }
    }

    for (final stat in stats.values) {
      stat.masteryLevel = stat.totalAttempts > 0
          ? stat.correctAttempts / stat.totalAttempts
          : 0.0;
    }

    return stats;
  }

  List<String> _identifyWeakKnowledgePoints(
    Map<String, KnowledgePointStats> stats,
  ) {
    final weakPoints = <String>[];

    for (final entry in stats.entries) {
      if (entry.value.masteryLevel < 0.6) {
        weakPoints.add(entry.key);
      }
    }

    weakPoints.sort(
      (a, b) => stats[a]!.masteryLevel.compareTo(stats[b]!.masteryLevel),
    );

    return weakPoints;
  }

  List<String> _identifyStrongKnowledgePoints(
    Map<String, KnowledgePointStats> stats,
  ) {
    final strongPoints = <String>[];

    for (final entry in stats.entries) {
      if (entry.value.masteryLevel >= 0.8) {
        strongPoints.add(entry.key);
      }
    }

    return strongPoints;
  }

  StudentKnowledgeProfile generateStudentProfile(
    String studentId,
    String studentName,
    List<ErrorRecord> errors,
  ) {
    final stats = _calculateKnowledgeStats(errors, studentId);
    final weakPoints = _identifyWeakKnowledgePoints(stats);
    final strongPoints = _identifyStrongKnowledgePoints(stats);

    return StudentKnowledgeProfile(
      studentId: studentId,
      studentName: studentName,
      knowledgeStats: stats,
      weakKnowledgePoints: weakPoints,
      strongKnowledgePoints: strongPoints,
    );
  }

  String _adjustDifficulty(String originalDifficulty, String adjustment) {
    final difficulties = ['简单', '中等', '困难'];
    final currentIndex = difficulties.indexOf(originalDifficulty);

    switch (adjustment) {
      case '更容易':
        if (currentIndex > 0) return difficulties[currentIndex - 1];
        return originalDifficulty;
      case '更难':
        if (currentIndex < difficulties.length - 1)
          return difficulties[currentIndex + 1];
        return originalDifficulty;
      default:
        return originalDifficulty;
    }
  }

  List<Question> _selectQuestionsForKnowledgePoint(
    String knowledgePoint,
    String targetDifficulty,
    int count,
    List<String> excludeQuestionIds,
  ) {
    final available = _questionBank.where((q) {
      if (q.knowledgePoint != knowledgePoint) return false;
      if (excludeQuestionIds.contains(q.questionId)) return false;

      if (targetDifficulty == '不变') return true;
      return q.difficulty == targetDifficulty;
    }).toList();

    available.shuffle(_random);

    final selected = <Question>[];
    for (int i = 0; i < count && i < available.length; i++) {
      selected.add(available[i]);
    }

    return selected;
  }

  List<String> _getDiffusedKnowledgePoints(String mainPoint, int levels) {
    final allPoints = ['二次函数', '三角形全等', '圆的性质', '相似三角形', '实数运算', '一元二次方程'];
    final mainIndex = allPoints.indexOf(mainPoint);

    if (mainIndex == -1 || levels <= 0) return [mainPoint];

    final diffused = <String>[mainPoint];

    if (mainIndex > 0 && levels >= 1) {
      diffused.add(allPoints[mainIndex - 1]);
    }
    if (mainIndex < allPoints.length - 1 && levels >= 1) {
      diffused.add(allPoints[mainIndex + 1]);
    }

    if (levels >= 2) {
      if (mainIndex > 1) diffused.add(allPoints[mainIndex - 2]);
      if (mainIndex < allPoints.length - 2)
        diffused.add(allPoints[mainIndex + 2]);
    }

    return diffused;
  }

  GeneratedPractice generatePractice({
    required String studentId,
    required String studentName,
    required List<ErrorRecord> errors,
    required PracticeGeneratorConfig config,
  }) {
    final profile = generateStudentProfile(studentId, studentName, errors);

    final List<PracticeQuestion> questions = [];
    int questionCounter = 1;

    if (profile.weakKnowledgePoints.isEmpty) {
      final randomPoint =
          _questionBank[_random.nextInt(_questionBank.length)].knowledgePoint;
      final selectedQs = _selectQuestionsForKnowledgePoint(
        randomPoint,
        config.difficultyAdjustment,
        config.targetQuestionCount,
        [],
      );

      for (final q in selectedQs) {
        questions.add(
          PracticeQuestion(
            questionId: 'P${questionCounter++}',
            content: q.content,
            answer: q.answer,
            difficulty: q.difficulty,
            knowledgePoint: q.knowledgePoint,
            sourceType: '题库选题',
            sourceQuestionId: q.questionId,
          ),
        );
      }
    } else {
      final targetPoints = <String>[];

      for (final weakPoint in profile.weakKnowledgePoints) {
        if (config.knowledgeFence.isNotEmpty &&
            !config.knowledgeFence.contains(weakPoint)) {
          continue;
        }

        if (config.diffusionLevel == '扩散') {
          targetPoints.addAll(_getDiffusedKnowledgePoints(weakPoint, 1));
        } else {
          targetPoints.add(weakPoint);
        }

        if (targetPoints.length >= config.targetQuestionCount) break;
      }

      for (final point in targetPoints) {
        if (questions.length >= config.targetQuestionCount) break;

        final adjustedDifficulty = _adjustDifficulty(
          '中等',
          config.difficultyAdjustment,
        );
        final selectedQs = _selectQuestionsForKnowledgePoint(
          point,
          adjustedDifficulty,
          1,
          questions.map((q) => q.sourceQuestionId).whereType<String>().toList(),
        );

        for (final q in selectedQs) {
          if (questions.length >= config.targetQuestionCount) break;

          questions.add(
            PracticeQuestion(
              questionId: 'P${questionCounter++}',
              content: q.content,
              answer: q.answer,
              difficulty: q.difficulty,
              knowledgePoint: q.knowledgePoint,
              sourceType: _determineSourceType(q, profile, errors),
              sourceQuestionId: q.questionId,
            ),
          );
        }
      }
    }

    return GeneratedPractice(
      practiceId: 'PR${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      questions: questions,
      generatedDate: DateTime.now(),
      targetKnowledgePoint: profile.weakKnowledgePoints.isNotEmpty
          ? profile.weakKnowledgePoints.first
          : '综合练习',
      difficulty: config.difficultyAdjustment,
    );
  }

  String _determineSourceType(
    Question question,
    StudentKnowledgeProfile profile,
    List<ErrorRecord> errors,
  ) {
    final relatedErrors = errors
        .where(
          (e) =>
              e.studentId == profile.studentId &&
              e.knowledgePoint == question.knowledgePoint,
        )
        .toList();

    if (relatedErrors.isNotEmpty && relatedErrors.any((e) => !e.isCorrected)) {
      return '错题同类型';
    }

    if (profile.weakKnowledgePoints.contains(question.knowledgePoint)) {
      return '薄弱知识点';
    }

    return '题库选题';
  }

  List<Question> getQuestionBank() {
    return List.from(_questionBank);
  }

  Map<String, int> getQuestionBankStats() {
    final stats = <String, int>{};

    for (final q in _questionBank) {
      stats[q.knowledgePoint] = (stats[q.knowledgePoint] ?? 0) + 1;
    }

    return stats;
  }
}
