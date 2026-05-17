import 'package:flutter/material.dart';

class PracticeRecord {
  final String id;
  final String title;
  final String topic;
  final DateTime generatedAt;
  final String status;
  final List<PracticeStudentRecord> students;

  PracticeRecord({
    required this.id,
    required this.title,
    required this.topic,
    required this.generatedAt,
    required this.status,
    required this.students,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'topic': topic,
      'generatedAt': generatedAt.toIso8601String(),
      'status': status,
    };
  }
}

class PracticeStudentRecord {
  final String id;
  final String practiceId;
  final String studentId;
  final String studentName;
  final String status;
  final int? score;
  final int totalQuestions;
  final int correctCount;
  final DateTime? completedAt;

  PracticeStudentRecord({
    required this.id,
    required this.practiceId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.score,
    required this.totalQuestions,
    required this.correctCount,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practiceId': practiceId,
      'studentId': studentId,
      'studentName': studentName,
      'status': status,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctCount': correctCount,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class PracticeQuestion {
  final String id;
  final String practiceId;
  final String studentId;
  final int number;
  final String type;
  final String content;
  final String? options;
  final String answer;
  final String solution;
  final String knowledgePoint;
  final String difficulty;
  final String? studentAnswer;
  final bool? isCorrect;

  PracticeQuestion({
    required this.id,
    required this.practiceId,
    required this.studentId,
    required this.number,
    required this.type,
    required this.content,
    this.options,
    required this.answer,
    required this.solution,
    required this.knowledgePoint,
    required this.difficulty,
    this.studentAnswer,
    this.isCorrect,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'practiceId': practiceId,
      'studentId': studentId,
      'number': number,
      'type': type,
      'content': content,
      'options': options,
      'answer': answer,
      'solution': solution,
      'knowledgePoint': knowledgePoint,
      'difficulty': difficulty,
      'studentAnswer': studentAnswer,
      'isCorrect': isCorrect,
    };
  }
}
