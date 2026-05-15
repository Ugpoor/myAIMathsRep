import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database/models/practice_session.dart';
import '../database/models/practice_question.dart';

/// 一人一练服务 - 核心功能1
/// 负责AI出题和批改
class PracticeService {
  final String _baseUrl = 'https://api.openai.com/v1'; // TODO: 替换为真实API
  final String _apiKey = 'YOUR_API_KEY'; // TODO: 从环境变量读取

  /// 生成练习题
  Future<List<PracticeQuestion>> generateQuestions({
    required String knowledgePoint,
    required String difficulty,
    required int count,
  }) async {
    // TODO: 调用真实LLM API生成练习题
    // 临时返回fake数据用于测试
    return List.generate(count, (index) {
      return PracticeQuestion(
        id: index,
        sessionId: 0,
        questionText: '关于$knowledgePoint的第${index + 1}题？',
        standardAnswer: '答案$index',
        explanation: '解析$index',
        knowledgePoint: knowledgePoint,
      );
    });
  }

  /// 批改答案
  Future<Map<String, dynamic>> gradeAnswer({
    required String questionId,
    required String userAnswer,
    required String correctAnswer,
  }) async {
    // TODO: 调用真实LLM API批改答案
    // 临时返回fake数据用于测试
    final isCorrect = userAnswer.trim() == correctAnswer.trim();
    return {
      'isCorrect': isCorrect,
      'score': isCorrect ? 10 : 0,
      'feedback': isCorrect ? '回答正确！' : '回答错误，正确答案是：$correctAnswer',
    };
  }

  /// 保存练习记录
  Future<void> savePracticeSession(PracticeSession session) async {
    // TODO: 保存到数据库
    print('保存练习记录：${session.id}');
  }

  /// 获取练习记录
  Future<List<PracticeSession>> getPracticeSessions(String classId) async {
    // TODO: 从数据库读取
    return [];
  }
}
