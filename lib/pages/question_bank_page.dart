import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';
import '../data/fake_question_bank.dart';

/// 题库页面
class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _knowledgeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String _aiMessage = '题库功能已加载。共收录题目100道。';
  String _selectedTab = '错题库';

  bool _isEditing = false;
  bool _isDetailView = false;
  Map<String, dynamic>? _editingQuestion;

  FilterResult? _filterResult;
  String? _filterSummary;

  final Set<String> _selectedRows = {};

  static const _filterFields = [
    FilterField(
      name: '题目类型',
      key: 'questionType',
      options: ['选择题', '填空题', '解答题', '证明题', '计算题'],
    ),
    FilterField(name: '勘误情况', key: 'hasError', options: ['无', '有勘误']),
  ];

  List<Map<String, dynamic>> get _filteredData {
    if (_filterResult == null || _filterResult!.isEmpty)
      return questionBankData;
    return questionBankData.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null) {
          if (entry.key == 'hasError') {
            final hasError = entry.value == '有勘误';
            if (row['hasError'] != hasError) return false;
          } else if (row[entry.key] != entry.value) {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  void _openEditView([Map<String, dynamic>? question]) {
    setState(() {
      _isEditing = true;
      _isDetailView = false;
      _editingQuestion = question;
      if (question != null) {
        _knowledgeController.text = question['knowledgePoint'];
        _typeController.text = question['questionType'];
        _difficultyController.text = question['difficulty'];
        _contentController.text = question['content'];
        _answerController.text = question['answer'];
      } else {
        _knowledgeController.clear();
        _typeController.clear();
        _difficultyController.clear();
        _contentController.clear();
        _answerController.clear();
      }
    });
  }

  void _openDetailView(Map<String, dynamic> question) {
    setState(() {
      _isDetailView = true;
      _editingQuestion = question;
    });
  }

  void _closeDetailView() {
    setState(() {
      _isDetailView = false;
      _editingQuestion = null;
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingQuestion = null;
      _knowledgeController.clear();
      _typeController.clear();
      _difficultyController.clear();
      _contentController.clear();
      _answerController.clear();
    });
  }

  void _saveEditing() {
    if (_editingQuestion != null) {
      final index = questionBankData.indexWhere(
        (q) => q['questionId'] == _editingQuestion!['questionId'],
      );
      if (index >= 0) {
        setState(() {
          questionBankData[index] = {
            ...questionBankData[index],
            'knowledgePoint': _knowledgeController.text,
            'questionType': _typeController.text,
            'difficulty': _difficultyController.text,
            'content': _contentController.text,
            'answer': _answerController.text,
          };
        });
      }
    } else {
      final newId = questionBankData.length + 1;
      setState(() {
        questionBankData.add({
          'id': newId.toString().padLeft(4, '0'),
          'questionId': 'Q${newId.toString().padLeft(4, '0')}',
          'knowledgePoint': _knowledgeController.text,
          'questionType': _typeController.text,
          'difficulty': _difficultyController.text,
          'content': _contentController.text,
          'answer': _answerController.text,
          'hasError': false,
          'errorNote': '',
          'createdAt': DateTime.now().toString(),
        });
      });
    }
    _aiMessage = _editingQuestion != null ? '题目已更新' : '新题目已添加';
    _cancelEditing();
  }

  void _deleteQuestion() {
    if (_editingQuestion != null) {
      setState(() {
        questionBankData.removeWhere(
          (q) => q['questionId'] == _editingQuestion!['questionId'],
        );
      });
      _aiMessage = '题目已删除';
      _cancelEditing();
    }
  }

  void _deleteSelected() {
    setState(() {
      questionBankData.removeWhere(
        (q) => _selectedRows.contains(q['questionId']),
      );
      _selectedRows.clear();
    });
    _aiMessage = '已删除${_selectedRows.length}道题目';
  }

  void _clearFilter() {
    setState(() {
      _filterResult = null;
      _filterSummary = null;
    });
  }

  bool _showImportDialog = false;
  String? _importPreview;

  void _openImportDialog() {
    setState(() {
      _showImportDialog = true;
      _importPreview = null;
    });
  }

  void _importFromCSV() async {
    _openImportDialog();
  }

  Future<void> _parseAndImportCSV(String csvContent) async {
    try {
      final lines = csvContent
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        _aiMessage = 'CSV文件为空';
        setState(() => _showImportDialog = false);
        return;
      }

      final headers = lines[0].split(',');
      int importedCount = 0;

      for (int i = 1; i < lines.length; i++) {
        final values = lines[i].split(',');
        if (values.length >= 5) {
          final newId = questionBankData.length + 1;
          questionBankData.add({
            'id': newId.toString().padLeft(4, '0'),
            'questionId': 'Q${newId.toString().padLeft(4, '0')}',
            'knowledgePoint': values[0].trim(),
            'questionType': values[1].trim(),
            'difficulty': values[2].trim(),
            'content': values[3].trim(),
            'answer': values.length > 4 ? values[4].trim() : '',
            'hasError': false,
            'errorNote': '',
            'createdAt': DateTime.now().toString(),
          });
          importedCount++;
        }
      }

      _aiMessage = '成功导入$importedCount道题目';
      setState(() {
        _showImportDialog = false;
      });
    } catch (e) {
      _aiMessage = 'CSV导入失败: $e';
      setState(() => _showImportDialog = false);
    }
  }

  Widget _buildImportDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'CSV导入',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('请粘贴CSV格式的数据:'),
            const SizedBox(height: 8),
            const Text('格式: 知识点,题目类型,难度,题目内容,答案'),
            const SizedBox(height: 8),
            TextField(
              maxLines: 8,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '二次函数,选择题,简单,题目内容,答案A\n...',
              ),
              onChanged: (value) {
                setState(() => _importPreview = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _showImportDialog = false),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _importPreview != null && _importPreview!.isNotEmpty
                      ? () => _parseAndImportCSV(_importPreview!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB3FF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('导入'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-题库'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isEditing
                    ? _buildEditView()
                    : (_isDetailView && _editingQuestion != null
                          ? _buildDetailView()
                          : _buildContent()),
              ),
            ),
            SubmenuTabs(
              tabs: _isEditing
                  ? const ['取消', '保存', '删除']
                  : (_isDetailView
                        ? const ['返回', '编辑', '删除']
                        : (_selectedRows.isNotEmpty
                              ? const ['错题库', '新增', '删除', '导入']
                              : const ['错题库', '新增', '导入'])),
              selectedTab: _isEditing
                  ? ''
                  : (_isDetailView ? '返回' : _selectedTab),
              onTabSelected: (tab) {
                if (_isEditing) {
                  if (tab == '取消')
                    _cancelEditing();
                  else if (tab == '保存')
                    _saveEditing();
                  else if (tab == '删除')
                    _deleteQuestion();
                } else if (_isDetailView) {
                  if (tab == '返回')
                    _closeDetailView();
                  else if (tab == '编辑')
                    _openEditView(_editingQuestion);
                  else if (tab == '删除') {
                    _deleteQuestion();
                    _closeDetailView();
                  }
                } else {
                  setState(() => _selectedTab = tab);
                  if (tab == '新增')
                    _openEditView();
                  else if (tab == '删除')
                    _deleteSelected();
                  else if (tab == '导入')
                    _importFromCSV();
                }
              },
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() => _aiMessage = '正在搜索题目...');
                _textController.clear();
              },
              hintText: '搜索题目...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _filterResult != null && _filterResult!.isNotEmpty
                  ? Text(
                      _filterSummary ?? '',
                      style: const TextStyle(fontSize: 13),
                    )
                  : const SizedBox.shrink(),
            ),
            if (_filterResult != null && _filterResult!.isNotEmpty)
              TextButton(
                onPressed: _clearFilter,
                child: const Text(
                  '清空筛选',
                  style: TextStyle(color: Colors.blue, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const DataTableView(
          headers: ['', '题目编号', '知识点', '类型', '难度', '勘误'],
          rows: [],
          showHeaderOnly: true,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredData.length,
            itemBuilder: (context, index) {
              final question = _filteredData[index];
              final isSelected = _selectedRows.contains(question['questionId']);
              return Card(
                color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedRows.add(question['questionId']);
                              } else {
                                _selectedRows.remove(question['questionId']);
                              }
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openDetailView(question),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(
                                  question['questionId'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  question['knowledgePoint'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  question['questionType'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  question['difficulty'],
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  question['hasError'] ? '有勘误' : '无',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: question['hasError']
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
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

  Widget _buildDetailView() {
    final q = _editingQuestion!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(q['questionId']),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(q['knowledgePoint']),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(q['questionType']),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(q['difficulty']),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  q['difficulty'],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '题目内容',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(q['content']),
          ),
          const SizedBox(height: 16),
          const Text(
            '答案',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(q['answer']),
          ),
          if (q['hasError'] == true) ...[
            const SizedBox(height: 16),
            const Text(
              '勘误信息',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(q['errorNote'] ?? ''),
            ),
          ],
          const SizedBox(height: 16),
          Text('创建时间: ${q['createdAt']}'),
        ],
      ),
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

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingQuestion != null ? '编辑题目' : '新增题目',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '知识点',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _knowledgeController.text.isNotEmpty
                    ? _knowledgeController.text
                    : null,
                items:
                    [
                          '二次函数',
                          '三角形全等',
                          '圆的性质',
                          '相似三角形',
                          '实数运算',
                          '一元二次方程',
                          '反比例函数',
                          '勾股定理',
                          '三角函数',
                          '概率统计',
                        ]
                        .map(
                          (kp) => DropdownMenuItem(value: kp, child: Text(kp)),
                        )
                        .toList(),
                onChanged: (value) =>
                    setState(() => _knowledgeController.text = value ?? ''),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '题目类型',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _typeController.text.isNotEmpty
                    ? _typeController.text
                    : null,
                items: ['选择题', '填空题', '解答题', '证明题', '计算题']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _typeController.text = value ?? ''),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '难度',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _difficultyController.text.isNotEmpty
                    ? _difficultyController.text
                    : null,
                items: ['简单', '中等', '困难']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _difficultyController.text = value ?? ''),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '题目内容',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '答案',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _answerController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
