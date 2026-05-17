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
  pm.GeneratedPractice? _generatedPractice;
  PracticeRecord? _selectedPractice;
  PracticeStudentRecord? _selectedStudentRecord;
  final Set<String> _selectedRows = {};

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
      _generateMode = 'AI生成';
      _aiDifficulty = '不变';
      _topicDiffusion = '不扩散';
      _selectedKnowledgeFence.clear();
      _excludedStudents.clear();
      _manualDifficulty = '中';
      _selectedKnowledgePoints.clear();
      _timeController.text = '15';
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedRows.clear();
    });
  }

  void _generatePractice() async {
    if (_hasGenerated) {
      setState(() {
        _aiMessage = '练习已生成，无需重复生成';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _aiMessage = '正在调用AI分析学生知识点缺失和错题记录...';
    });

    // 默认所有学生参与
    final allStudents = ['张三', '李四', '王五', '赵六', '钱七', '孙八'];
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

        final weakPoints = profile.weakKnowledgePoints.isNotEmpty
            ? profile.weakKnowledgePoints.join('、')
            : '综合练习';

        final knowledge = _selectedKnowledgePoints.isNotEmpty
            ? _selectedKnowledgePoints.join('、')
            : weakPoints;

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

        final llmPrompt =
            '''你是一位专业的数学练习生成专家。请为初中生生成5道个性化练习题。

学生信息：
- 学生姓名：$studentName
- 学生ID：$studentId
- 薄弱知识点：$weakPoints
- 目标知识点：$knowledge
- 难度要求：$difficulty$curriculumRequirements

题目要求：
1. 针对学生的薄弱知识点生成练习题
2. 严格遵循考纲要求
3. 包含不同题型的题目（选择题、填空题、解答题）
4. 每道题目都要有详细的解题步骤和答案

输出格式（严格遵循JSON格式）：
{
  "questions": [
    {
      "number": 1,
      "type": "选择题",
      "knowledgePoint": "知识点名称",
      "content": "题目内容",
      "options": ["A. 选项1", "B. 选项2", "C. 选项3", "D. 选项4"],
      "answer": "正确答案",
      "solution": "解题步骤"
    },
    {
      "number": 2,
      "type": "填空题",
      "knowledgePoint": "知识点名称",
      "content": "题目内容",
      "answer": "正确答案",
      "solution": "解题步骤"
    },
    {
      "number": 3,
      "type": "解答题",
      "knowledgePoint": "知识点名称",
      "content": "题目内容",
      "answer": "正确答案",
      "solution": "解题步骤"
    }
  ]
}

请直接输出JSON格式，不要添加其他文字说明。''';

        try {
          final result = await _llmService.generateResponse(llmPrompt);

          if (result['success'] == true) {
            final responseText = result['response'] as String;

            final questions = _parseQuestionsFromResponse(responseText);

            if (questions.isNotEmpty) {
              final practiceQuestions = questions.map((q) {
                return pm.PracticeQuestion(
                  questionId: 'P${q['number']}',
                  content: q['content'] ?? '',
                  answer: q['answer'] ?? '',
                  difficulty: difficulty,
                  knowledgePoint: q['knowledgePoint'] ?? knowledge,
                  sourceType: 'AI生成',
                );
              }).toList();

              final practice = pm.GeneratedPractice(
                practiceId: 'PR${DateTime.now().millisecondsSinceEpoch}',
                studentId: studentId,
                studentName: studentName,
                questions: practiceQuestions,
                generatedDate: DateTime.now(),
                targetKnowledgePoint: knowledge,
                difficulty: difficulty,
              );

              setState(() {
                _generatedPractice = practice;
                _showPracticeDetail = true;
                _hasGenerated = true;
                _aiMessage =
                    '✅ AI已为$studentName生成个性化练习题！\n'
                    '薄弱知识点：$weakPoints\n'
                    '生成题目数：${practiceQuestions.length}道\n'
                    '点击"查看详情"查看生成的练习题。';
              });
            } else {
              setState(() {
                _aiMessage = '⚠️ AI响应格式解析失败，使用传统方式生成...';
              });
              _generatePracticeFallback(studentName, studentId, profile);
            }
          } else {
            setState(() {
              _aiMessage = '⚠️ AI生成失败：${result['response']}，使用传统方式生成...';
            });
            _generatePracticeFallback(studentName, studentId, profile);
          }
        } catch (e) {
          setState(() {
            _aiMessage = '⚠️ AI生成出错：$e，使用传统方式生成...';
          });
          _generatePracticeFallback(studentName, studentId, profile);
        }
      }
    } else {
      // 默认所有学生参与
      final allStudents = ['张三', '李四', '王五', '赵六', '钱七', '孙八'];
      final participatingStudents = allStudents
          .where((name) => !_excludedStudents.contains(name))
          .toList();

      final newId =
          'P${(_practiceRecords.length + 1).toString().padLeft(3, '0')}';
      final now = DateTime.now();

      final studentRecords = participatingStudents.map((name) {
        final studentId = _findStudentId(name) ?? name.hashCode.toString();
        return PracticeStudentRecord(
          id: 'PS${DateTime.now().millisecondsSinceEpoch}_${name.hashCode}',
          practiceId: newId,
          studentId: studentId,
          studentName: name,
          status: '未开始',
          score: null,
          totalQuestions: 5,
          correctCount: 0,
          completedAt: null,
        );
      }).toList();

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
        _aiMessage = '人工配置练习已生成，共${participatingStudents.length}位同学参与';
        _isEditing = false;
        _hasGenerated = true;
      });
    }

    setState(() {
      _isGenerating = false;
    });
  }

  List<Map<String, String>> _parseQuestionsFromResponse(String responseText) {
    final questions = <Map<String, String>>[];

    try {
      final regex = RegExp(
        r'"number"\s*:\s*(\d+).*?"type"\s*:\s*"([^"]+)".*?"knowledgePoint"\s*:\s*"([^"]+)".*?"content"\s*:\s*"([^"]+)".*?"answer"\s*:\s*"([^"]+)".*?"solution"\s*:\s*"([^"]+)"',
        multiLine: true,
        dotAll: true,
      );

      for (final match in regex.allMatches(responseText)) {
        questions.add({
          'number': match.group(1) ?? '',
          'type': match.group(2) ?? '',
          'knowledgePoint': match.group(3) ?? '',
          'content': match.group(4) ?? '',
          'answer': match.group(5) ?? '',
          'solution': match.group(6) ?? '',
        });
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

  void _generatePracticeFallback(
    String studentName,
    String studentId,
    pm.StudentKnowledgeProfile profile,
  ) {
    final config = pm.PracticeGeneratorConfig(
      difficultyAdjustment: _aiDifficulty,
      diffusionLevel: _topicDiffusion,
      knowledgeFence: _selectedKnowledgeFence.toList(),
      targetQuestionCount: 5,
      timeLimit: int.tryParse(_timeController.text) ?? 30,
      excludedStudentIds: _excludedStudents.toList(),
    );

    final practice = _generatorService.generatePractice(
      studentId: studentId,
      studentName: studentName,
      errors: _errorRecords,
      config: config,
    );

    setState(() {
      _generatedPractice = practice;
      _showPracticeDetail = true;
      _hasGenerated = true;
      _aiMessage =
          '已为$studentName生成个性化练习题！\n'
          '薄弱知识点：${profile.weakKnowledgePoints.isNotEmpty ? profile.weakKnowledgePoints.join("、") : "无"}\n'
          '生成题目数：${practice.questions.length}道\n'
          '点击"查看详情"查看生成的练习题。';
    });
  }

  String? _findStudentId(String studentName) {
    final nameToId = {
      '张三': '346001',
      '李四': '346002',
      '王五': '346003',
      '赵六': '346004',
      '钱七': '346005',
      '孙八': '346006',
    };
    return nameToId[studentName];
  }

  void _saveGeneratedPractice() {
    if (_generatedPractice == null) return;

    final practice = _generatedPractice!;
    final newId =
        'P${(_practiceRecords.length + 1).toString().padLeft(3, '0')}';

    final studentRecord = PracticeStudentRecord(
      id: 'PS${DateTime.now().millisecondsSinceEpoch}',
      practiceId: newId,
      studentId: practice.studentId,
      studentName: practice.studentName,
      status: '未开始',
      score: null,
      totalQuestions: practice.questions.length,
      correctCount: 0,
      completedAt: null,
    );

    final newPractice = PracticeRecord(
      id: newId,
      title: practice.targetKnowledgePoint,
      topic: practice.targetKnowledgePoint,
      generatedAt: DateTime.now(),
      status: '未开始',
      students: [studentRecord],
    );

    setState(() {
      _practiceRecords.insert(0, newPractice);
      _isEditing = false;
      _showPracticeDetail = false;
      _hasGenerated = false;
      _generatedPractice = null;
      _aiMessage = '✅ 练习已保存！';
    });
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
        _generatedPractice = null;
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
                        : (_showPracticeDetail && _generatedPractice != null
                              ? _buildPracticeDetailView()
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
            if (_isGenerating)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在调用AI生成练习题...'),
                          SizedBox(height: 8),
                          Text(
                            '请稍候，正在分析学生薄弱知识点',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
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
          const Text(
            '所有学生默认参与，以下为排除名单：',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['张三', '李四', '王五', '赵六', '钱七', '孙八']
                .map(
                  (name) => FilterChip(
                    label: Text(name),
                    selected: _excludedStudents.contains(name),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _excludedStudents.add(name);
                        } else {
                          _excludedStudents.remove(name);
                        }
                      });
                    },
                  ),
                )
                .toList(),
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
                  trailing: student.status == '已完成' || student.status == '已批阅'
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : student.status == '进行中'
                      ? const Icon(Icons.hourglass_empty, color: Colors.orange)
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
    );
  }

  Widget _buildStudentDetailView() {
    final studentRecord = _selectedStudentRecord!;
    final questions = FakePracticeData.getQuestionsByPracticeAndStudent(
      studentRecord.practiceId,
      studentRecord.studentId,
    );

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
    super.dispose();
  }
}
