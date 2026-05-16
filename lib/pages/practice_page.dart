import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';
import '../models/practice_models.dart';
import '../services/practice_generator_service.dart';

/// 一人一练状态枚举
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

/// 一人一练页面 - 核心功能1
class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _timeController = TextEditingController(
    text: '30',
  );
  final TextEditingController _excludeStudentController =
      TextEditingController();
  final TextEditingController _addStudentController = TextEditingController();

  String _aiMessage = '欢迎使用一人一练功能！我可以帮你生成个性化练习题。';

  // --- 视图状态 ---
  String _selectedTab = '筛选'; // 筛选 / 取消 / 保存 / 删除 / 生成
  bool _isEditing = false;
  String? _editingRecordId;
  PracticeStatus _editingStatus = PracticeStatus.notGenerated;

  // --- 生成方式 ---
  String _generateMode = 'AI生成';

  // --- AI生成选项 ---
  String _aiDifficulty = '不变';
  String _topicDiffusion = '不扩散';
  final Set<String> _selectedKnowledgeFence = {};
  final List<String> _excludedStudents = [];

  // --- 人工配置选项 ---
  String _manualDifficulty = '中';
  final Set<String> _selectedKnowledgePoints = {};
  final List<String> _participatingStudents = [];

  // --- 筛选状态 ---
  FilterResult? _filterResult;
  String? _filterSummary;

  // --- 智能生成服务 ---
  final PracticeGeneratorService _generatorService = PracticeGeneratorService();

  // --- 模拟学生数据 ---
  final List<ErrorRecord> _errorRecords = [];
  GeneratedPractice? _generatedPractice;
  bool _showPracticeDetail = false;

  // --- 数据 ---
  final List<Map<String, String>> _allData = [
    {
      '编号': 'P001',
      '生成时间': '2026/5/14 10:30',
      '状态': '未订正',
      '考点': '二次函数',
      '参与人': '张三',
    },
    {
      '编号': 'P002',
      '生成时间': '2026/5/13 14:15',
      '状态': '未批阅',
      '考点': '三角形全等',
      '参与人': '李四',
    },
    {
      '编号': 'P003',
      '生成时间': '2026/5/12 09:00',
      '状态': '未答题',
      '考点': '圆的性质',
      '参与人': '王五',
    },
    {
      '编号': 'P004',
      '生成时间': '2026/5/11 08:00',
      '状态': '未生成',
      '考点': '相似三角形',
      '参与人': '赵六',
    },
  ];

  final List<String> _knowledgeOptions = [
    '二次函数',
    '三角形全等',
    '圆的性质',
    '相似三角形',
    '实数运算',
    '一元二次方程',
  ];

  @override
  void initState() {
    super.initState();
    _initFakeData();
  }

  void _initFakeData() {
    _errorRecords.addAll([
      ErrorRecord(
        recordId: 'E001',
        studentId: '346001',
        studentName: '张三',
        questionId: 'Q001',
        knowledgePoint: '二次函数',
        errorDate: DateTime(2026, 5, 10),
        errorReason: '计算错误',
        isCorrected: true,
      ),
      ErrorRecord(
        recordId: 'E002',
        studentId: '346001',
        studentName: '张三',
        questionId: 'Q003',
        knowledgePoint: '二次函数',
        errorDate: DateTime(2026, 5, 11),
        errorReason: '概念不清',
        isCorrected: false,
      ),
      ErrorRecord(
        recordId: 'E003',
        studentId: '346002',
        studentName: '李四',
        questionId: 'Q006',
        knowledgePoint: '三角形全等',
        errorDate: DateTime(2026, 5, 9),
        errorReason: '证明步骤缺失',
        isCorrected: true,
      ),
      ErrorRecord(
        recordId: 'E004',
        studentId: '346002',
        studentName: '李四',
        questionId: 'Q007',
        knowledgePoint: '三角形全等',
        errorDate: DateTime(2026, 5, 12),
        errorReason: '公式应用错误',
        isCorrected: false,
      ),
      ErrorRecord(
        recordId: 'E005',
        studentId: '346003',
        studentName: '王五',
        questionId: 'Q011',
        knowledgePoint: '圆的性质',
        errorDate: DateTime(2026, 5, 8),
        errorReason: '几何关系混淆',
        isCorrected: false,
      ),
      ErrorRecord(
        recordId: 'E006',
        studentId: '346004',
        studentName: '赵六',
        questionId: 'Q016',
        knowledgePoint: '相似三角形',
        errorDate: DateTime(2026, 5, 7),
        errorReason: '比例计算错误',
        isCorrected: true,
      ),
      ErrorRecord(
        recordId: 'E007',
        studentId: '346004',
        studentName: '赵六',
        questionId: 'Q018',
        knowledgePoint: '相似三角形',
        errorDate: DateTime(2026, 5, 10),
        errorReason: '定理应用错误',
        isCorrected: false,
      ),
      ErrorRecord(
        recordId: 'E008',
        studentId: '346005',
        studentName: '钱七',
        questionId: 'Q021',
        knowledgePoint: '实数运算',
        errorDate: DateTime(2026, 5, 6),
        errorReason: '开方运算错误',
        isCorrected: true,
      ),
      ErrorRecord(
        recordId: 'E009',
        studentId: '346006',
        studentName: '孙八',
        questionId: 'Q026',
        knowledgePoint: '一元二次方程',
        errorDate: DateTime(2026, 5, 5),
        errorReason: '公式记错',
        isCorrected: false,
      ),
    ]);
  }

  /// 筛选字段定义
  static const _filterFields = [
    FilterField(name: '状态', key: '状态', options: ['未生成', '未答题', '未批阅', '未订正']),
    FilterField(
      name: '考点',
      key: '考点',
      options: ['二次函数', '三角形全等', '圆的性质', '相似三角形', '实数运算', '一元二次方程'],
    ),
  ];

  List<Map<String, String>> get _filteredData {
    if (_filterResult == null || _filterResult!.isEmpty) return _allData;
    return _allData.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null && row[entry.key] != entry.value) return false;
      }
      return true;
    }).toList();
  }

  /// 根据编辑状态动态生成 SubmenuTabs
  List<String> get _currentTabs {
    if (_isEditing) {
      final tabs = <String>['取消'];
      if (_editingStatus == PracticeStatus.notGenerated) {
        tabs.add('保存');
        tabs.add('删除');
        tabs.add('生成');
      } else if (_editingStatus == PracticeStatus.notAnswered) {
        tabs.add('删除');
      }
      return tabs;
    }
    return const ['筛选', '新增'];
  }

  void _enterNew() {
    setState(() {
      _isEditing = true;
      _editingRecordId = null;
      _editingStatus = PracticeStatus.notGenerated;
      _generateMode = 'AI生成';
      _aiDifficulty = '不变';
      _topicDiffusion = '不扩散';
      _selectedKnowledgeFence.clear();
      _excludedStudents.clear();
      _manualDifficulty = '中';
      _selectedKnowledgePoints.clear();
      _participatingStudents.clear();
      _timeController.text = '30';
    });
  }

  void _enterEdit(String id) {
    final record = _allData.firstWhere((r) => r['编号'] == id);
    setState(() {
      _isEditing = true;
      _editingRecordId = id;
      _editingStatus = _parseStatus(record['状态'] ?? '未生成');
      _timeController.text = '30';
      // TODO: 加载已有配置数据
    });
  }

  PracticeStatus _parseStatus(String label) {
    return PracticeStatus.values.firstWhere(
      (s) => s.label == label,
      orElse: () => PracticeStatus.notGenerated,
    );
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  void _saveConfig() {
    setState(() {
      _aiMessage = '配置已保存！';
    });
  }

  void _deleteRecord() {
    if (_editingRecordId != null) {
      setState(() {
        _allData.removeWhere((r) => r['编号'] == _editingRecordId);
        _aiMessage = '记录已删除';
        _isEditing = false;
      });
    }
  }

  void _generatePractice() async {
    setState(() {
      _aiMessage = '正在分析学生知识点缺失和错题记录...';
    });

    if (_generateMode == 'AI生成') {
      for (final studentName in _participatingStudents) {
        final studentId = _findStudentId(studentName);
        if (studentId == null) continue;

        final profile = _generatorService.generateStudentProfile(
          studentId,
          studentName,
          _errorRecords,
        );

        final config = PracticeGeneratorConfig(
          difficultyAdjustment: _aiDifficulty,
          diffusionLevel: _topicDiffusion,
          knowledgeFence: _selectedKnowledgeFence.toList(),
          targetQuestionCount: 5,
          timeLimit: int.tryParse(_timeController.text) ?? 30,
          excludedStudentIds: _excludedStudents,
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
          _aiMessage =
              '已为$studentName生成个性化练习题！\n'
              '薄弱知识点：${profile.weakKnowledgePoints.isNotEmpty ? profile.weakKnowledgePoints.join("、") : "无"}\n'
              '生成题目数：${practice.questions.length}道\n'
              '点击"查看详情"查看生成的练习题。';
        });
      }
    } else {
      final newId = 'P${(_allData.length + 1).toString().padLeft(3, '0')}';
      final now = DateTime.now();
      _allData.insert(0, {
        '编号': newId,
        '生成时间':
            '${now.year}/${now.month}/${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        '状态': '未答题',
        '考点': _selectedKnowledgePoints.join('、'),
        '参与人': _participatingStudents.join('、'),
      });
      setState(() {
        _aiMessage = '人工配置练习已生成，共${_participatingStudents.length}位同学参与';
        _isEditing = false;
      });
    }
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

  Widget _buildPracticeDetailView() {
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
              child: const Text('返回'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '目标知识点: ${practice.targetKnowledgePoint}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '难度调整: ${practice.difficulty}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '题目数量: ${practice.questions.length}道',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '生成的练习题:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: practice.questions.length,
            itemBuilder: (context, index) {
              final q = practice.questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(q.difficulty),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              q.difficulty,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              q.knowledgePoint,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '来源: ${q.sourceType}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${index + 1}. ${q.content}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '答案:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q.answer,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return Colors.green;
      case '中等':
        return Colors.orange;
      case '困难':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-一人一练'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _showPracticeDetail && _generatedPractice != null
                    ? _buildPracticeDetailView()
                    : (_isEditing ? _buildConfigView() : _buildFilterView()),
              ),
            ),
            SubmenuTabs(
              tabs: _currentTabs,
              selectedTab: _selectedTab,
              onTabSelected: _onTabSelected,
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() => _aiMessage = '正在处理...');
                _textController.clear();
              },
              hintText: '输入知识点生成练习题...',
            ),
          ],
        ),
      ),
    );
  }

  void _onTabSelected(String tab) {
    if (!_isEditing) {
      // 列表视图下
      if (tab == '新增') {
        _enterNew();
      } else {
        setState(() => _selectedTab = tab);
      }
    } else {
      // 编辑视图下
      setState(() => _selectedTab = tab);
      switch (tab) {
        case '取消':
          _cancelEdit();
          break;
        case '保存':
          _saveConfig();
          break;
        case '删除':
          _deleteRecord();
          break;
        case '生成':
          _generatePractice();
          break;
      }
    }
  }

  // ==================== 列表视图 ====================

  Widget _buildFilterView() {
    final data = _filteredData;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '共 ${data.length} 条记录',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            ElevatedButton.icon(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('列筛选'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BB3FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: const TextStyle(fontSize: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
        if (_filterSummary != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _filterSummary!,
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    _filterResult = null;
                    _filterSummary = null;
                  }),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: DataTableView(
            headers: const ['编号', '生成时间', '状态', '考点', '参与人'],
            rows: data
                .map(
                  (d) => [d['编号']!, d['生成时间']!, d['状态']!, d['考点']!, d['参与人']!],
                )
                .toList(),
            onRowTap: (index) {
              _enterEdit(data[index]['编号']!);
            },
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() async {
    final result = await FilterDialog.show(
      context,
      fields: _filterFields,
      initialResult: _filterResult,
    );
    if (result != null) {
      setState(() {
        _filterResult = result;
        final parts = <String>[];
        result.selectedValues.forEach((key, value) {
          if (value != null) parts.add('$key=$value');
        });
        result.rangeValues.forEach((key, value) {
          if (value != null)
            parts.add('$key: ${value.min ?? '*'} ~ ${value.max ?? '*'}');
        });
        _filterSummary = parts.isEmpty ? null : parts.join(' | ');
      });
    }
  }

  // ==================== 配置视图 ====================

  Widget _buildConfigView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingRecordId == null ? '新增练习配置' : '编辑练习配置',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // 生成方式切换
            const Text('生成方式', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Row(
              children: ['AI生成', '人工配置'].map((mode) {
                return Row(
                  children: [
                    Radio<String>(
                      value: mode,
                      groupValue: _generateMode,
                      onChanged: (v) => setState(() => _generateMode = v!),
                    ),
                    Text(mode),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // 根据模式显示不同配置
            if (_generateMode == 'AI生成')
              _buildAIConfig()
            else
              _buildManualConfig(),
          ],
        ),
      ),
    );
  }

  // --- AI生成配置 ---
  Widget _buildAIConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('难度选择'),
        Wrap(
          spacing: 8,
          children: ['更容易', '更难', '不变'].map((d) {
            final selected = _aiDifficulty == d;
            return ChoiceChip(
              label: Text(d),
              selected: selected,
              onSelected: (_) => setState(() => _aiDifficulty = d),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionTitle('考点扩散'),
        Wrap(
          spacing: 8,
          children: ['扩散', '不扩散'].map((d) {
            final selected = _topicDiffusion == d;
            return ChoiceChip(
              label: Text(d),
              selected: selected,
              onSelected: (_) => setState(() => _topicDiffusion = d),
            );
          }).toList(),
        ),
        if (_topicDiffusion == '扩散') ...[
          const SizedBox(height: 12),
          _sectionTitle('知识围栏'),
          Wrap(
            spacing: 8,
            children: _knowledgeOptions.map((k) {
              final selected = _selectedKnowledgeFence.contains(k);
              return FilterChip(
                label: Text(k),
                selected: selected,
                onSelected: (_) => setState(() {
                  if (selected) {
                    _selectedKnowledgeFence.remove(k);
                  } else {
                    _selectedKnowledgeFence.add(k);
                  }
                }),
              );
            }).toList(),
          ),
        ],
        const SizedBox(height: 16),
        _sectionTitle('时间（分钟）'),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              hintText: '分钟',
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('排除同学'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _excludeStudentController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText: '输入学号或姓名',
                ),
                onSubmitted: (val) => _addExcludedStudent(val),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () =>
                  _addExcludedStudent(_excludeStudentController.text),
              child: const Text('添加'),
            ),
          ],
        ),
        if (_excludedStudents.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: _excludedStudents
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _excludedStudents.remove(s)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _addExcludedStudent(String val) {
    val = val.trim();
    if (val.isNotEmpty && !_excludedStudents.contains(val)) {
      setState(() {
        _excludedStudents.add(val);
        _excludeStudentController.clear();
      });
    }
  }

  // --- 人工配置 ---
  Widget _buildManualConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('难度选择'),
        Wrap(
          spacing: 8,
          children: ['高', '中', '低'].map((d) {
            final selected = _manualDifficulty == d;
            return ChoiceChip(
              label: Text(d),
              selected: selected,
              onSelected: (_) => setState(() => _manualDifficulty = d),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionTitle('时间（分钟）'),
        SizedBox(
          width: 120,
          child: TextField(
            controller: _timeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              hintText: '分钟',
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionTitle('知识点选择'),
        Wrap(
          spacing: 8,
          children: _knowledgeOptions.map((k) {
            final selected = _selectedKnowledgePoints.contains(k);
            return FilterChip(
              label: Text(k),
              selected: selected,
              onSelected: (_) => setState(() {
                if (selected) {
                  _selectedKnowledgePoints.remove(k);
                } else {
                  _selectedKnowledgePoints.add(k);
                }
              }),
            );
          }).toList(),
        ),
        if (_selectedKnowledgePoints.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '已选知识点：${_selectedKnowledgePoints.join('、')}',
              style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
            ),
          ),
        ],
        const SizedBox(height: 16),
        _sectionTitle('参与同学'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addStudentController,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText: '输入学号或姓名',
                ),
                onSubmitted: (val) => _addParticipatingStudent(val),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () =>
                  _addParticipatingStudent(_addStudentController.text),
              child: const Text('添加'),
            ),
          ],
        ),
        if (_participatingStudents.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: _participatingStudents
                .map(
                  (s) => Chip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _participatingStudents.remove(s)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  void _addParticipatingStudent(String val) {
    val = val.trim();
    if (val.isNotEmpty && !_participatingStudents.contains(val)) {
      setState(() {
        _participatingStudents.add(val);
        _addStudentController.clear();
      });
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _timeController.dispose();
    _excludeStudentController.dispose();
    _addStudentController.dispose();
    super.dispose();
  }
}
