import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';
import '../models/curriculum_outline.dart';
import '../models/practice_database_models.dart';
import '../models/practice_models.dart' as pm;
import '../data/fake_curriculum_data.dart';
import '../data/fake_practice_data.dart';
import '../data/fake_student_data.dart';
import '../services/practice_generator_service.dart';
import '../services/llm_service.dart';

enum PracticeStatus { notGenerated, notAnswered, notGraded, notCorrected }

extension PracticeStatusExt on PracticeStatus {
  String get label {
    switch (this) {
      case PracticeStatus.notGenerated:
        return '未生成';
      case PracticeStatus.notAnswered:
        return '未答题';
      case PracticeStatus.notGraded:
        return '未批阅';
      case PracticeStatus.notCorrected:
        return '未订正';
    }
  }
}

class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(
    text: '15',
  );
  final TextEditingController _excludeStudentController =
      TextEditingController();

  String _aiMessage = '欢迎使用一人一练功能！我可以帮你生成个性化练习题。';

  String _selectedTab = '筛选';
  bool _isEditing = false;
  bool _showPracticeDetail = false;
  bool _showStudentDetail = false;
  bool _hasGenerated = false;
  bool _showOverview = false;
  bool _showErratum = false;
  pm.GeneratedPractice? _generatedPractice;
  PracticeRecord? _selectedPractice;
  PracticeStudentRecord? _selectedStudentRecord;
  final Set<String> _selectedRows = {};
  final Map<String, String> _erratumMap = {};
  final Map<String, List<PracticeQuestion>> _generatedQuestions = {};
  final Map<String, List<PracticeQuestion>> _savedPracticeQuestions = {};
  bool _showAllQuestions = false;

  String _generateMode = 'AI生成';
  String _aiDifficulty = '不变';
  String _topicDiffusion = '不扩散';
  final Set<String> _selectedKnowledgeFence = {};
  final Set<String> _excludedStudents = {};
  String _manualDifficulty = '中';
  final List<String> _selectedKnowledgePoints = [];

  final PracticeGeneratorService _generatorService = PracticeGeneratorService();
  final LlmService _llmService = LlmService();
  bool _isGenerating = false;
  bool _showGenerationDialog = false;
  final List<Map<String, dynamic>> _generationProgress = [];
  final ScrollController _scrollController = ScrollController();

  late List<PracticeRecord> _practiceRecords;

  @override
  void initState() {
    super.initState();
    _practiceRecords = FakePracticeData.getAllPracticeRecords();
  }

  final List<pm.ErrorRecord> _errorRecords = [
    pm.ErrorRecord(
      recordId: 'E001',
      studentId: '2024001',
      studentName: '张三',
      questionId: 'Q001',
      knowledgePoint: '二次函数',
      errorDate: DateTime.now(),
      errorReason: '计算错误',
      isCorrected: false,
    ),
  ];

  void _enterNew() {
    setState(() {
      _isEditing = true;
      _hasGenerated = false;
      _generatedQuestions.clear();
      _generateMode = 'AI生成';
      _aiDifficulty = '不变';
      _topicDiffusion = '不扩散';
      _selectedKnowledgeFence.clear();
      _excludedStudents.clear();
      // 默认排除30个学生，只保留前6个进行测试
      final allStudents = studentData.map((s) => s['name'] as String).toList();
      if (allStudents.length > 6) {
        _excludedStudents.addAll(allStudents.sublist(6));
      }
      _manualDifficulty = '中';
      _selectedKnowledgePoints.clear();
      _timeController.text = '15';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _hasGenerated = false;
      _generatedQuestions.clear();
      _selectedRows.clear();
      _showGenerationDialog = false;
      _generationProgress.clear();
    });
  }

  void _generatePractice() async {
    if (_hasGenerated) {
      setState(() {
        _aiMessage = '练习已生成，无需重复生成';
      });
      return;
    }

    // 清空之前的生成数据
    setState(() {
      _isGenerating = true;
      _aiMessage = '正在调用AI分析学生知识点缺失和错题记录...';
      _generationProgress.clear();
      _generatedQuestions.clear();
      _showGenerationDialog = true;
    });

    // 默认所有学生参与（从fake数据中获取36个学生）
    final allStudents = studentData.map((s) => s['name'] as String).toList();
    final participatingStudents = allStudents
        .where((name) => !_excludedStudents.contains(name))
        .toList();

    if (_generateMode == 'AI生成') {
      for (final studentName in participatingStudents) {
        final studentId = _findStudentId(studentName);
        if (studentId == null) continue;

        final profile = _generatorService.generateStudentProfile(
          studentId,
          studentName,
          _errorRecords,
        );

        // 获取当前学生的数据 - 提前到这里获取
        final student = studentData.firstWhere(
          (s) => s['studentId'] == studentId,
          orElse: () => {},
        );

        // 获取学生的薄弱知识点和错题
        final studentWeakPoints =
            (student['weakKnowledgePoints'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        final studentErrors =
            (student['errorQuestions'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];

        final knowledge = _selectedKnowledgePoints.isNotEmpty
            ? _selectedKnowledgePoints.join('、')
            : (studentWeakPoints.isNotEmpty
                  ? studentWeakPoints.join('、')
                  : '综合练习');

        final difficulty = _aiDifficulty == '不变' ? '中等' : _aiDifficulty;

        String curriculumRequirements = '';
        final matchingCurriculums = FakeCurriculumData.getByKnowledgePoint(
          knowledge,
        );
        if (matchingCurriculums.isNotEmpty) {
          final curriculum = matchingCurriculums.first;
          curriculumRequirements =
              '''
- 考纲要求：${curriculum.requirement}
- 考纲描述：${curriculum.description}
- 年级：${curriculum.grade}
- 相关主题：${curriculum.relatedTopics.join('、')}''';
        }

        setState(() {
          _generationProgress.add({
            'studentName': studentName,
            'studentId': studentId,
            'knowledge': knowledge,
            'difficulty': difficulty,
            'status': '生成中...',
            'progress': '正在分析知识点...',
          });
        });

        // 滚动到最新添加的项
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        final errorsText = studentErrors
            .map(
              (e) =>
                  '- ${e['content']} (正确答案: ${e['correctAnswer']}, 错误答案: ${e['wrongAnswer']})',
            )
            .join('\n');

        final timeLimit = int.tryParse(_timeController.text) ?? 15;
        final questionCount = (timeLimit / 3).ceil(); // 估算每道题需要3分钟

        final llmPrompt =
            '''结合以下知识点：$knowledge
参考以下错题：
${errorsText.isEmpty ? '（无错题）' : errorsText}

针对此生成类似难度的题目和答案，并按照以下格式：
{
  "题目表": [
    {
      "题号": "1",
      "题目": "具体题目",
      "分值": 5
    },
    {
      "题号": "2",
      "题目": "具体题目",
      "分值": 5
    }
  ],
  "答案表": [
    {
      "题号": "1",
      "答案": "答案",
      "解析": "详细解析"
    },
    {
      "题号": "2",
      "答案": "答案",
      "解析": "详细解析"
    }
  ]
}
生成约$timeLimit分钟答题量的考题（大约 $questionCount 道题）。''';

        List<PracticeQuestion> practiceQuestions = [];
        try {
          final result = await _llmService.generateResponse(llmPrompt);

          if (result['success'] == true) {
            final responseText = result['response'] as String;

            final questions = _parseQuestionsFromResponse(responseText);

            if (questions.isNotEmpty) {
              int questionNum = 1;
              practiceQuestions = questions.map((q) {
                return PracticeQuestion(
                  id: 'Q${studentId}_$questionNum',
                  practiceId: '',
                  studentId: studentId,
                  number: questionNum++,
                  type: q['type'] ?? '解答题',
                  content: q['content'] ?? '',
                  options: q['options']?.join(',') ?? '',
                  answer: q['answer'] ?? '',
                  solution: q['solution'] ?? '',
                  knowledgePoint: q['knowledgePoint'] ?? knowledge,
                  difficulty: difficulty,
                );
              }).toList();
            } else {
              practiceQuestions = _generatePracticeFallbackQuestions(
                studentName,
                studentId,
                profile,
                knowledge,
                difficulty,
              );
            }
          } else {
            practiceQuestions = _generatePracticeFallbackQuestions(
              studentName,
              studentId,
              profile,
              knowledge,
              difficulty,
            );
          }
        } catch (e) {
          practiceQuestions = _generatePracticeFallbackQuestions(
            studentName,
            studentId,
            profile,
            knowledge,
            difficulty,
          );
        }

        // 保存该学生的题目
        _generatedQuestions[studentId] = practiceQuestions;

        setState(() {
          final idx = _generationProgress.indexWhere(
            (p) => p['studentName'] == studentName,
          );
          if (idx >= 0) {
            _generationProgress[idx]['status'] = '✅ 完成';
            _generationProgress[idx]['progress'] =
                '已生成${practiceQuestions.length}道题目';
          }
        });
      }

      // 完成生成，显示保存按钮
      setState(() {
        _hasGenerated = true;
        _isGenerating = false;
        _aiMessage = '✅ AI已为${participatingStudents.length}位同学生成个性化练习题！请点击保存。';
      });
    } else {
      // 人工配置模式
      final allStudentsManual = ['张三', '李四', '王五', '赵六', '钱七', '孙八'];
      final participatingStudentsManual = allStudentsManual
          .where((name) => !_excludedStudents.contains(name))
          .toList();

      for (final studentName in participatingStudentsManual) {
        final studentId =
            _findStudentId(studentName) ?? studentName.hashCode.toString();
        final profile = _generatorService.generateStudentProfile(
          studentId,
          studentName,
          _errorRecords,
        );
        final knowledge = _selectedKnowledgePoints.isNotEmpty
            ? _selectedKnowledgePoints.join('、')
            : '综合';
        final difficulty = _manualDifficulty;

        setState(() {
          _generationProgress.add({
            'studentName': studentName,
            'studentId': studentId,
            'knowledge': knowledge,
            'difficulty': difficulty,
            'status': '生成中...',
            'progress': '正在生成题目...',
          });
        });

        // 滚动到最新添加的项
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        final practiceQuestions = _generatePracticeFallbackQuestions(
          studentName,
          studentId,
          profile,
          knowledge,
          difficulty,
        );

        _generatedQuestions[studentId] = practiceQuestions;

        setState(() {
          final idx = _generationProgress.indexWhere(
            (p) => p['studentName'] == studentName,
          );
          if (idx >= 0) {
            _generationProgress[idx]['status'] = '✅ 完成';
            _generationProgress[idx]['progress'] =
                '已生成${practiceQuestions.length}道题目';
          }
        });
      }

      setState(() {
        _hasGenerated = true;
        _isGenerating = false;
        _aiMessage = '✅ 已为${participatingStudentsManual.length}位同学生成练习题！请点击保存。';
      });
    }
  }

  void _saveGeneratedPractice() {
    if (_generatedQuestions.isEmpty) {
      setState(() {
        _aiMessage = '没有题目可以保存';
      });
      return;
    }

    final newId =
        'P${(_practiceRecords.length + 1).toString().padLeft(3, '0')}';
    final now = DateTime.now();

    final studentRecords = <PracticeStudentRecord>[];

    // 为每个学生创建记录并更新题目中的practiceId
    _generatedQuestions.forEach((studentId, questions) {
      final updatedQuestions = questions.map((q) {
        return PracticeQuestion(
          id: q.id,
          practiceId: newId,
          studentId: q.studentId,
          number: q.number,
          type: q.type,
          content: q.content,
          options: q.options,
          answer: q.answer,
          solution: q.solution,
          knowledgePoint: q.knowledgePoint,
          difficulty: q.difficulty,
          studentAnswer: null, // 新生成的题目还没有学生答案
          isCorrect: null,
          aiComment: null,
        );
      }).toList();

      // 保存题目
      _savedPracticeQuestions[newId + '_' + studentId] = updatedQuestions;

      // 找到学生姓名
      String studentName = '';
      for (final student in studentData) {
        if (student['studentId'] == studentId) {
          studentName = student['name'] as String;
          break;
        }
      }

      // 创建学生记录
      studentRecords.add(
        PracticeStudentRecord(
          id: 'PS${now.millisecondsSinceEpoch}_${studentId.hashCode}',
          practiceId: newId,
          studentId: studentId,
          studentName: studentName,
          status: '未开始',
          score: null,
          totalQuestions: updatedQuestions.length,
          correctCount: 0,
          completedAt: null,
        ),
      );
    });

    final newPractice = PracticeRecord(
      id: newId,
      title:
          '${_selectedKnowledgePoints.isNotEmpty ? _selectedKnowledgePoints.join('、') : '综合练习'}',
      topic: _selectedKnowledgePoints.isNotEmpty
          ? _selectedKnowledgePoints.join('、')
          : '综合',
      generatedAt: now,
      status: '未开始',
      students: studentRecords,
    );

    setState(() {
      _practiceRecords.insert(0, newPractice);
      _isEditing = false;
      _hasGenerated = false;
      _showGenerationDialog = false;
      _generationProgress.clear();
      _generatedQuestions.clear();
      _aiMessage = '✅ 练习已保存成功！';
    });
  }

  List<Map<String, dynamic>> _parseQuestionsFromResponse(String responseText) {
    final questions = <Map<String, dynamic>>[];

    try {
      // 尝试解析新格式的 JSON
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = responseText.substring(jsonStart, jsonEnd);

        try {
          // 这里需要解析 JSON，但为了简单，我们使用正则匹配
          // 匹配题目表
          final questionReg = RegExp(
            r'"题号"\s*:\s*"(\d+)".*?"题目"\s*:\s*"([^"]+)"',
            multiLine: true,
            dotAll: true,
          );

          final answerReg = RegExp(
            r'"题号"\s*:\s*"(\d+)".*?"答案"\s*:\s*"([^"]+)".*?"解析"\s*:\s*"([^"]+)"',
            multiLine: true,
            dotAll: true,
          );

          final questionMatches = questionReg.allMatches(jsonStr).toList();
          final answerMatches = answerReg.allMatches(jsonStr).toList();

          for (int i = 0; i < questionMatches.length; i++) {
            final qMatch = questionMatches[i];
            final number = qMatch.group(1)!;
            final content = qMatch.group(2)!;

            String answer = '';
            String solution = '';

            // 找对应的答案
            for (final aMatch in answerMatches) {
              if (aMatch.group(1) == number) {
                answer = aMatch.group(2)!;
                solution = aMatch.group(3)!;
                break;
              }
            }

            questions.add({
              'number': number,
              'type': '解答题',
              'knowledgePoint': _selectedKnowledgePoints.isNotEmpty
                  ? _selectedKnowledgePoints.first
                  : '综合',
              'content': content,
              'options': null,
              'answer': answer,
              'solution': solution,
            });
          }
        } catch (e) {
          debugPrint('JSON 解析错误: $e');
        }
      }

      // 如果新格式没解析到，尝试旧格式
      if (questions.isEmpty) {
        final regex = RegExp(
          r'"number"\s*:\s*(\d+).*?"type"\s*:\s*"([^"]+)".*?"knowledgePoint"\s*:\s*"([^"]+)".*?"content"\s*:\s*"([^"]+)"(?:.*?"options"\s*:\s*(\[[^\]]+\]))?.*?"answer"\s*:\s*"([^"]+)".*?"solution"\s*:\s*"([^"]+)"',
          multiLine: true,
          dotAll: true,
        );

        for (final match in regex.allMatches(responseText)) {
          List<String>? options;
          final optionsString = match.group(5);
          if (optionsString != null) {
            try {
              final regexOption = RegExp(r'"([^"]+)"');
              final matches = regexOption.allMatches(optionsString);
              options = matches.map((m) => m.group(1)!).toList();
            } catch (e) {
              options = null;
            }
          }

          questions.add({
            'number': match.group(1) ?? '',
            'type': match.group(2) ?? '',
            'knowledgePoint': match.group(3) ?? '',
            'content': match.group(4) ?? '',
            'options': options,
            'answer': match.group(6) ?? '',
            'solution': match.group(7) ?? '',
          });
        }
      }

      if (questions.isEmpty) {
        final lines = responseText.split('\n');
        int currentNumber = 0;
        String? currentType;
        String? currentKnowledge;
        String? currentContent;
        String? currentAnswer;
        StringBuffer solutionBuffer = StringBuffer();

        for (var line in lines) {
          line = line.trim();

          if (line.contains('第') && line.contains('题')) {
            if (currentNumber > 0 && currentContent != null) {
              questions.add({
                'number': currentNumber.toString(),
                'type': currentType ?? '解答题',
                'knowledgePoint': currentKnowledge ?? '综合',
                'content': currentContent,
                'options': null,
                'answer': currentAnswer ?? '',
                'solution': solutionBuffer.toString().trim(),
              });
            }

            final numberMatch = RegExp(r'第(\d+)题').firstMatch(line);
            if (numberMatch != null) {
              currentNumber = int.parse(numberMatch.group(1)!);
            }
            currentType = line.contains('选择')
                ? '选择题'
                : line.contains('填空')
                ? '填空题'
                : '解答题';
            currentKnowledge = _selectedKnowledgePoints.isNotEmpty
                ? _selectedKnowledgePoints.first
                : '二次函数';
            currentContent = null;
            currentAnswer = null;
            solutionBuffer.clear();
          } else if (line.startsWith('题目：') || line.startsWith('题面：')) {
            currentContent = line.substring(line.indexOf('：') + 1).trim();
          } else if (line.startsWith('答案：') || line.startsWith('参考答案：')) {
            currentAnswer = line.substring(line.indexOf('：') + 1).trim();
          } else if (line.startsWith('解：') ||
              line.startsWith('解题：') ||
              line.startsWith('解析：')) {
            solutionBuffer.write(line + '\n');
          } else if (currentContent != null &&
              currentAnswer == null &&
              line.isNotEmpty) {
            if (line.length < 200) {
              currentAnswer = line;
            }
          } else if (currentContent != null && currentAnswer != null) {
            solutionBuffer.write(line + '\n');
          }
        }

        if (currentNumber > 0 && currentContent != null) {
          questions.add({
            'number': currentNumber.toString(),
            'type': currentType ?? '解答题',
            'knowledgePoint': currentKnowledge ?? '综合',
            'content': currentContent,
            'options': null,
            'answer': currentAnswer ?? '',
            'solution': solutionBuffer.toString().trim(),
          });
        }
      }
    } catch (e) {
      debugPrint('解析错误: $e');
    }

    return questions;
  }

  List<PracticeQuestion> _generatePracticeFallbackQuestions(
    String studentName,
    String studentId,
    pm.StudentKnowledgeProfile profile,
    String knowledge,
    String difficulty,
  ) {
    // 创建完整的示例题目
    final sampleQuestions = [
      {
        'number': 1,
        'type': '选择题',
        'knowledgePoint': knowledge,
        'content': '已知二次函数 y = x² - 4x + 3，下列说法正确的是：',
        'options': 'A.开口向下|B.对称轴 x = 2|C.顶点 (2,1)|D.与 x 轴交点为 (1,0) 和 (3,0)',
        'answer': 'B',
        'solution':
            '二次函数 y = x² - 4x + 3 可化为 y = (x - 2)² - 1，对称轴为 x = 2，顶点为 (2,-1)，开口向上，与 x 轴交点为 (1,0) 和 (3,0)。',
      },
      {
        'number': 2,
        'type': '填空题',
        'knowledgePoint': knowledge,
        'content': '二次函数 y = 2x² + 4x - 6 的顶点坐标是 ______',
        'options': null,
        'answer': '(-1, -8)',
        'solution': 'y = 2(x² + 2x) - 6 = 2(x + 1)² - 8，顶点坐标为 (-1, -8)',
      },
      {
        'number': 3,
        'type': '解答题',
        'knowledgePoint': knowledge,
        'content': '已知二次函数图像经过点 (0,3)、(1,0)、(3,0)，求函数解析式。',
        'options': null,
        'answer': 'y = x² - 4x + 3',
        'solution':
            '设 y = a(x - 1)(x - 3)，代入 (0,3) 得 3 = 3a，a = 1，所以 y = x² - 4x + 3',
      },
      {
        'number': 4,
        'type': '选择题',
        'knowledgePoint': knowledge,
        'content': '若二次函数 y = ax² + bx + c 的图像与 x 轴有两个交点，则：',
        'options': 'A.a > 0|B.Δ > 0|C.b² - 4ac < 0|D.c = 0',
        'answer': 'B',
        'solution': '二次函数与 x 轴有两个交点意味着判别式 Δ = b² - 4ac > 0',
      },
      {
        'number': 5,
        'type': '解答题',
        'knowledgePoint': knowledge,
        'content': '求二次函数 y = x² - 2x - 3 的单调区间。',
        'options': null,
        'answer': '单调递减区间 (-∞,1)，单调递增区间 (1,+∞)',
        'solution': 'y = (x - 1)² - 4，顶点为 (1,-4)，开口向上，所以在 (-∞,1) 递减，(1,+∞) 递增',
      },
    ];

    int num = 1;
    return sampleQuestions.map((q) {
      return PracticeQuestion(
        id: 'Q${studentId}_$num',
        practiceId: '',
        studentId: studentId,
        number: num++,
        type: q['type'] as String,
        content: q['content'] as String,
        options: q['options'] as String?,
        answer: q['answer'] as String,
        solution: q['solution'] as String,
        knowledgePoint: q['knowledgePoint'] as String,
        difficulty: difficulty,
        studentAnswer: null,
        isCorrect: null,
        aiComment: null,
      );
    }).toList();
  }

  String? _findStudentId(String studentName) {
    for (final student in studentData) {
      if (student['name'] == studentName) {
        return student['studentId'] as String;
      }
    }
    return null;
  }

  Widget _buildStudentDropdown() {
    final allStudents = studentData.map((s) => s['name'] as String).toList();
    final availableStudents = allStudents
        .where((name) => !_excludedStudents.contains(name))
        .toList();

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return availableStudents;
        }
        return availableStudents.where(
          (name) =>
              name.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      displayStringForOption: (String option) => option,
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController controller,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: '搜索添加排除学生',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                hintText: '输入学生姓名搜索...',
              ),
            );
          },
      onSelected: (String selection) {
        setState(() {
          _excludedStudents.add(selection);
        });
      },
    );
  }

  void _returnFromDetail() {
    setState(() {
      _showPracticeDetail = false;
      _selectedPractice = null;
      _selectedStudentRecord = null;
      _showStudentDetail = false;
      if (_isEditing && _hasGenerated) {
        _isEditing = false;
        _hasGenerated = false;
        _generatedQuestions.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _isEditing
        ? (_hasGenerated || _isGenerating
              ? const ['取消', '保存', '返回']
              : const ['取消', '生成'])
        : (_showPracticeDetail
              ? const ['返回']
              : (_selectedRows.isNotEmpty
                    ? const ['筛选', '新增', '删除']
                    : const ['筛选', '新增']));

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppTitleBar(title: 'AI数学课代表-一人一练'),
                AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
                const CollapsibleDateHeader(),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isEditing
                        ? _buildEditView()
                        : (_showPracticeDetail &&
                                  (_selectedPractice != null ||
                                      _generatedPractice != null)
                              ? (_selectedPractice != null
                                    ? _buildPracticeRecordDetailView()
                                    : _buildPracticeDetailView())
                              : _buildContent()),
                  ),
                ),
                SubmenuTabs(
                  tabs: tabs,
                  selectedTab: _selectedTab,
                  onTabSelected: (tab) {
                    if (_isEditing) {
                      if (tab == '取消')
                        _cancelEditing();
                      else if (tab == '生成')
                        _generatePractice();
                      else if (tab == '保存')
                        _saveGeneratedPractice();
                      else if (tab == '返回')
                        _returnFromDetail();
                    } else if (_showPracticeDetail) {
                      if (tab == '返回') _returnFromDetail();
                    } else {
                      setState(() => _selectedTab = tab);
                      if (tab == '新增')
                        _enterNew();
                      else if (tab == '删除')
                        _deleteSelected();
                    }
                  },
                  onHomeTap: () => Navigator.pop(context),
                ),
                InputArea(
                  controller: _textController,
                  onSend: () {
                    setState(() => _aiMessage = '正在分析...');
                    _textController.clear();
                  },
                  hintText: '输入关键词搜索...',
                ),
              ],
            ),
            if (_showGenerationDialog)
              Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _hasGenerated ? '✅ 练习题生成完成' : 'AI正在生成练习题',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: 300,
                            height: 250,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: _generationProgress.length,
                              itemBuilder: (context, index) {
                                final progress = _generationProgress[index];
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${progress['studentName']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              progress['status'] ?? '',
                                              style: TextStyle(
                                                color:
                                                    progress['status'] == '✅ 完成'
                                                    ? Colors.green
                                                    : Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text('学号: ${progress['studentId']}'),
                                        Text('知识点: ${progress['knowledge']}'),
                                        Text('难度: ${progress['difficulty']}'),
                                        Text(
                                          progress['progress'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_hasGenerated)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _showGenerationDialog = false;
                                      _generationProgress.clear();
                                      _generatedQuestions.clear();
                                      _hasGenerated = false;
                                      _isGenerating = false;
                                      _aiMessage = '已取消生成';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text('取消'),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _saveGeneratedPractice();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text('保存练习'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _practiceRecords.length,
            itemBuilder: (context, index) {
              final record = _practiceRecords[index];
              final isSelected = _selectedRows.contains(record.id);
              final completedCount = record.students
                  .where((s) => s.status == '已完成' || s.status == '已批阅')
                  .length;
              final totalCount = record.students.length;

              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRows.add(record.id);
                        } else {
                          _selectedRows.remove(record.id);
                        }
                      });
                    },
                  ),
                  title: Text(record.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '考点: ${record.topic} | ${record.generatedAt.year}/${record.generatedAt.month}/${record.generatedAt.day} ${record.generatedAt.hour}:${record.generatedAt.minute.toString().padLeft(2, '0')}',
                      ),
                      Text('参与人数: $totalCount | 已完成: $completedCount'),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(record.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      record.status,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedPractice = record;
                      _showPracticeDetail = true;
                      _isEditing = false;
                      _showStudentDetail = false;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '已完成':
      case '已批阅':
        return Colors.green;
      case '进行中':
        return Colors.orange;
      case '未开始':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '生成模式',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('AI生成'),
                selected: _generateMode == 'AI生成',
                onSelected: (selected) {
                  if (selected) setState(() => _generateMode = 'AI生成');
                },
              ),
              ChoiceChip(
                label: const Text('人工配置'),
                selected: _generateMode == '人工配置',
                onSelected: (selected) {
                  if (selected) setState(() => _generateMode = '人工配置');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_generateMode == 'AI生成') ...[
            const Text(
              'AI难度调整',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('更容易'),
                  selected: _aiDifficulty == '更容易',
                  onSelected: (selected) {
                    if (selected) setState(() => _aiDifficulty = '更容易');
                  },
                ),
                ChoiceChip(
                  label: const Text('不变'),
                  selected: _aiDifficulty == '不变',
                  onSelected: (selected) {
                    if (selected) setState(() => _aiDifficulty = '不变');
                  },
                ),
                ChoiceChip(
                  label: const Text('更难'),
                  selected: _aiDifficulty == '更难',
                  onSelected: (selected) {
                    if (selected) setState(() => _aiDifficulty = '更难');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '题目扩散',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('不扩散'),
                  selected: _topicDiffusion == '不扩散',
                  onSelected: (selected) {
                    if (selected) setState(() => _topicDiffusion = '不扩散');
                  },
                ),
                ChoiceChip(
                  label: const Text('扩散'),
                  selected: _topicDiffusion == '扩散',
                  onSelected: (selected) {
                    if (selected) setState(() => _topicDiffusion = '扩散');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '知识点围栏',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['二次函数', '三角形全等', '圆的性质']
                  .map(
                    (kp) => FilterChip(
                      label: Text(kp),
                      selected: _selectedKnowledgeFence.contains(kp),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedKnowledgeFence.add(kp);
                          } else {
                            _selectedKnowledgeFence.remove(kp);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ] else ...[
            const Text(
              '知识点选择',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['二次函数', '三角形全等', '圆的性质']
                  .map(
                    (kp) => FilterChip(
                      label: Text(kp),
                      selected: _selectedKnowledgePoints.contains(kp),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedKnowledgePoints.add(kp);
                          } else {
                            _selectedKnowledgePoints.remove(kp);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              '难度等级',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('简单'),
                  selected: _manualDifficulty == '简单',
                  onSelected: (selected) {
                    if (selected) setState(() => _manualDifficulty = '简单');
                  },
                ),
                ChoiceChip(
                  label: const Text('中等'),
                  selected: _manualDifficulty == '中',
                  onSelected: (selected) {
                    if (selected) setState(() => _manualDifficulty = '中');
                  },
                ),
                ChoiceChip(
                  label: const Text('困难'),
                  selected: _manualDifficulty == '困难',
                  onSelected: (selected) {
                    if (selected) setState(() => _manualDifficulty = '困难');
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            '排除学生',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '已排除',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                '${_excludedStudents.length}人',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '（默认全部学生参与）',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStudentDropdown(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _excludedStudents.map((name) {
              return Chip(
                label: Text(name, style: const TextStyle(fontSize: 12)),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _excludedStudents.remove(name);
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('时间限制（分钟）：'),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeDetailView() {
    if (_selectedStudentRecord != null) {
      return _buildStudentDetailView();
    }

    if (_selectedPractice != null) {
      return _buildPracticeRecordDetailView();
    }

    final practice = _generatedPractice!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '学生: ${practice.studentName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _showPracticeDetail = false),
              child: const Text('返回列表'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('目标知识点：${practice.targetKnowledgePoint}'),
        Text('题目数量：${practice.questions.length}道'),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: practice.questions.length,
            itemBuilder: (context, index) {
              final q = practice.questions[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '第${index + 1}题 (${q.knowledgePoint})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(q.content),
                      const SizedBox(height: 8),
                      Text(
                        '答案：${q.answer}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '来源：${q.sourceType}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeRecordDetailView() {
    final record = _selectedPractice!;

    // 获取练习的所有题目
    List<PracticeQuestion> allQuestions = [];
    for (final student in record.students) {
      final savedKey = record.id + '_' + student.studentId;
      if (_savedPracticeQuestions.containsKey(savedKey)) {
        final questions = _savedPracticeQuestions[savedKey]!;
        if (allQuestions.isEmpty && questions.isNotEmpty) {
          // 取第一个学生的题目作为样例
          allQuestions = questions;
        }
      } else {
        // 从 FakePracticeData 获取题目
        final questions = FakePracticeData.getQuestionsByPracticeAndStudent(
          record.id,
          student.studentId,
        );
        if (allQuestions.isEmpty && questions.isNotEmpty) {
          allQuestions = questions;
        }
      }
    }

    if (_showStudentDetail && _selectedStudentRecord != null) {
      return _buildStudentDetailView();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                record.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _showPracticeDetail = false;
                _selectedPractice = null;
                _selectedStudentRecord = null;
                _showAllQuestions = false;
                _showStudentDetail = false;
              }),
              child: const Text('返回列表'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(record.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            Text('考点: ${record.topic}'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '生成时间: ${record.generatedAt.year}/${record.generatedAt.month}/${record.generatedAt.day} ${record.generatedAt.hour}:${record.generatedAt.minute.toString().padLeft(2, '0')}',
        ),
        const SizedBox(height: 12),
        // 切换标签
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAllQuestions = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !_showAllQuestions ? Colors.blue : Colors.grey,
              ),
              child: const Text('学生答题'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showAllQuestions = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _showAllQuestions ? Colors.blue : Colors.grey,
              ),
              child: const Text('所有题目'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showAllQuestions)
          Expanded(
            child: allQuestions.isNotEmpty
                ? ListView.builder(
                    itemCount: allQuestions.length,
                    itemBuilder: (context, index) {
                      final q = allQuestions[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '第${q.number}题 (${q.type})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '知识点: ${q.knowledgePoint}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(q.content),
                              const SizedBox(height: 8),
                              if (q.options != null && q.options!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('选项:'),
                                    Text(q.options!.replaceAll('|', '\n')),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              Row(
                                children: [
                                  const Text(
                                    '正确答案: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    q.answer,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '解答:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(q.solution),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : const Center(child: Text('暂无题目')),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '学生答题情况:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: record.students.length,
                    itemBuilder: (context, index) {
                      final student = record.students[index];
                      return Card(
                        child: ListTile(
                          title: Text(student.studentName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('学号: ${student.studentId}'),
                              Text('状态: ${student.status}'),
                              if (student.score != null)
                                Text(
                                  '得分: ${student.score}/${student.totalQuestions * 20}',
                                ),
                            ],
                          ),
                          trailing:
                              student.status == '已完成' || student.status == '已批阅'
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : student.status == '进行中'
                              ? const Icon(
                                  Icons.hourglass_empty,
                                  color: Colors.orange,
                                )
                              : const Icon(Icons.circle, color: Colors.grey),
                          onTap: () {
                            setState(() {
                              _selectedStudentRecord = student;
                              _showStudentDetail = true;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStudentDetailView() {
    final studentRecord = _selectedStudentRecord!;

    // 首先尝试从保存的题目中获取
    List<PracticeQuestion> questions = [];
    final savedKey = studentRecord.practiceId + '_' + studentRecord.studentId;
    if (_savedPracticeQuestions.containsKey(savedKey)) {
      questions = _savedPracticeQuestions[savedKey]!;
    }

    // 如果没有找到，从FakePracticeData获取
    if (questions.isEmpty) {
      questions = FakePracticeData.getQuestionsByPracticeAndStudent(
        studentRecord.practiceId,
        studentRecord.studentId,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${studentRecord.studentName} 的答题详情',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _selectedStudentRecord = null;
                _showStudentDetail = false;
              }),
              child: const Text('返回'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(studentRecord.status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                studentRecord.status,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 12),
            if (studentRecord.score != null)
              Text(
                '得分: ${studentRecord.score}/${studentRecord.totalQuestions * 20}',
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '正确: ${studentRecord.correctCount}/${studentRecord.totalQuestions}',
        ),
        if (studentRecord.completedAt != null)
          Text(
            '完成时间: ${studentRecord.completedAt!.year}/${studentRecord.completedAt!.month}/${studentRecord.completedAt!.day} ${studentRecord.completedAt!.hour}:${studentRecord.completedAt!.minute}',
          ),
        const Divider(),
        const SizedBox(height: 8),
        Expanded(
          child: questions.isNotEmpty
              ? ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final isCorrect = q.isCorrect ?? false;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isCorrect ? '✓ 正确' : '✗ 错误',
                                    style: TextStyle(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '第${q.number}题 (${q.type})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '知识点: ${q.knowledgePoint}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(q.content),
                            const SizedBox(height: 8),
                            if (q.options != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('选项:'),
                                  Text(q.options!.replaceAll('|', '\n')),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            Row(
                              children: [
                                const Text(
                                  '正确答案: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  q.answer,
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                            if (q.studentAnswer != null &&
                                q.studentAnswer != q.answer)
                              Row(
                                children: [
                                  const Text(
                                    '学生答案: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    q.studentAnswer!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 8),
                            const Text(
                              '解答:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(q.solution),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: Text('暂无答题记录')),
        ),
      ],
    );
  }

  void _deleteSelected() {
    setState(() {
      _practiceRecords.removeWhere((r) => _selectedRows.contains(r.id));
      _selectedRows.clear();
      _aiMessage = '已删除${_selectedRows.length}条记录';
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    _excludeStudentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
