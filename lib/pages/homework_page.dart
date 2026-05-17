import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';

/// 作业试卷页面
class HomeworkPage extends StatefulWidget {
  const HomeworkPage({super.key});

  @override
  State<HomeworkPage> createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '作业试卷管理功能已加载。';
  String _selectedTab = '筛选';

  // 选中行（编号集合）
  final Set<String> _selectedRows = {};

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  // 新增：题库选题相关
  String _generateMode = 'AI生成';
  String _difficulty = '中等';
  final List<String> _selectedKnowledge = [];
  final List<String> _selectedQuestions = [];

  // 当前视图层级
  String _currentView = 'paper'; // paper, answer, single

  // 当前选中的试卷
  String? _currentPaperId;

  // 当前选中的答卷
  String? _currentAnswerId;

  final List<Map<String, String>> _allData = [
    {
      '编号': 'H001',
      '生成时间': '2026/5/14 14:30',
      '状态': '未批阅',
      '类型': '二次函数练习题',
      '题目数': '10',
      '总分': '100',
    },
    {
      '编号': 'H002',
      '生成时间': '2026/5/13 10:15',
      '状态': '未完成',
      '类型': '三角形全等测试',
      '题目数': '20',
      '总分': '100',
    },
    {
      '编号': 'H003',
      '生成时间': '2026/5/12 09:00',
      '状态': '未订正',
      '类型': '圆与相似形',
      '题目数': '15',
      '总分': '100',
    },
    {
      '编号': 'H004',
      '生成时间': '2026/5/11 08:45',
      '状态': '已批改',
      '类型': '实数运算单元卷',
      '题目数': '25',
      '总分': '100',
    },
  ];

  final List<String> _knowledgeOptions = [
    '二次函数',
    '三角形全等',
    '圆的性质',
    '相似三角形',
    '实数运算',
  ];

  // 模拟题库
  final List<Map<String, String>> _questionBank = [
    {'题号': 'Q001', '知识点': '二次函数', '难度': '中等', '题型': '解答题'},
    {'题号': 'Q002', '知识点': '二次函数', '难度': '困难', '题型': '证明题'},
    {'题号': 'Q003', '知识点': '三角形全等', '难度': '简单', '题型': '选择题'},
    {'题号': 'Q004', '知识点': '圆的性质', '难度': '中等', '题型': '填空题'},
    {'题号': 'Q005', '知识点': '相似三角形', '难度': '困难', '题型': '解答题'},
    {'题号': 'Q006', '知识点': '实数运算', '难度': '简单', '题型': '计算题'},
  ];

  // 答卷数据（包含批阅状态）
  List<Map<String, dynamic>> _answerData = [
    {
      '编号': 'A001',
      '试卷编号': 'H001',
      '学号': '2026001',
      '姓名': '张三',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'false',
      '错题数': '2',
      '未答题': '0',
      '得分': '80',
    },
    {
      '编号': 'A002',
      '试卷编号': 'H001',
      '学号': '2026002',
      '姓名': '李四',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'true',
      '错题数': '5',
      '未答题': '0',
      '得分': '65',
    },
    {
      '编号': 'A003',
      '试卷编号': 'H001',
      '学号': '2026003',
      '姓名': '王五',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'false',
      '错题数': '1',
      '未答题': '0',
      '得分': '92',
    },
    {
      '编号': 'A004',
      '试卷编号': 'H001',
      '学号': '2026004',
      '姓名': '赵六',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'false',
      '错题数': '3',
      '未答题': '0',
      '得分': '75',
    },
    {
      '编号': 'A005',
      '试卷编号': 'H001',
      '学号': '2026005',
      '姓名': '钱七',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'true',
      '错题数': '4',
      '未答题': '0',
      '得分': '70',
    },
    {
      '编号': 'A006',
      '试卷编号': 'H001',
      '学号': '2026006',
      '姓名': '孙八',
      '状态': '已完成',
      'AI批阅': 'true',
      '需修订': 'false',
      '错题数': '2',
      '未答题': '0',
      '得分': '88',
    },
  ];

  // 单题批阅数据（可编辑）
  Map<String, Map<String, dynamic>> _questionReviews = {};

  // 单题数据
  List<Map<String, String>> _questionDetails = [
    {
      'id': '1',
      '题目': '已知二次函数y=ax²+bx+c经过点(1,0)、(2,0)、(3,6)，求a、b、c的值。',
      '解答': 'a=3, b=-10, c=7',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '解答正确',
    },
    {
      'id': '2',
      '题目': '求二次函数y=x²-4x+3的顶点坐标和对称轴。',
      '解答': '顶点(2,-1)，对称轴x=2',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '3',
      '题目': '若二次函数y=ax²+bx+c的图像开口向下，且顶点在原点，求a、b、c满足的条件。',
      '解答': 'a<0, b=0',
      'AI得分': '5',
      'AI结果': '错误',
      'AI批注': '缺少c=0的条件',
    },
    {
      'id': '4',
      '题目': '已知二次函数y=2x²-4x+1，求其在x=3处的函数值。',
      '解答': 'y=2*9-12+1=7',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '5',
      '题目': '二次函数y=x²-mx+4与x轴有两个交点，求m的取值范围。',
      '解答': 'm>4或m<-4',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '6',
      '题目': '画出二次函数y=x²-2x-3的图像草图。',
      '解答': '顶点(1,-4)，与x轴交点(-1,0)(3,0)',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '7',
      '题目': '求函数y=|x²-4|的单调区间。',
      '解答': '(-∞,-2)减，(-2,0)增，(0,2)减，(2,+∞)增',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '8',
      '题目': '已知二次函数图像过点(0,3)，且对称轴为x=1，最小值为2，求函数解析式。',
      '解答': 'y=(x-1)²+2',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
    {
      'id': '9',
      '题目': '解方程：x²-5x+6=0',
      '解答': 'x=2',
      'AI得分': '5',
      'AI结果': '错误',
      'AI批注': '漏解x=3',
    },
    {
      'id': '10',
      '题目': '用配方法解方程：x²+4x-5=0',
      '解答': '(x+2)²=9，x=1或x=-5',
      'AI得分': '10',
      'AI结果': '正确',
      'AI批注': '',
    },
  ];

  void _initQuestionReviews() {
    _questionReviews.clear();
    for (var q in _questionDetails) {
      _questionReviews[q['id']!] = {
        'AI得分': q['AI得分'],
        'AI结果': q['AI结果'],
        'AI批注': q['AI批注'],
        '得分': q['AI得分'],
        '结果': q['AI结果'],
        '批注': q['AI批注'],
        '需修订': (q['AI结果'] == '错误').toString(),
      };
    }
  }

  static const _filterFields = [
    FilterField(
      name: '状态',
      key: '状态',
      options: ['未生成', '未完成', '未批阅', '未订正', '已批改', '进行中', '完成', '未开始', '订正完成'],
    ),
    FilterField(
      name: '类型',
      key: '类型',
      options: ['练习题', '测试', '单元卷', '期中考试', '期末考试'],
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

  List<Map<String, String>> get _pendingReviewData {
    return _allData.where((row) {
      return row['状态'] == '已完成';
    }).toList();
  }

  bool _canEdit(String status) => status == '未生成';
  bool _canDelete(String status) => status == '未生成';

  @override
  Widget build(BuildContext context) {
    final isReviewable =
        _currentView == 'answer' &&
        _answerData.any((a) => a['状态'] == '已完成' && a['AI批阅'] == 'true');

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-作业试卷'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(),
              ),
            ),
            SubmenuTabs(
              tabs: _currentView == 'paper'
                  ? (_selectedTab == '批阅'
                        ? const ['批阅', '筛选', '新增', '编辑']
                        : const ['批阅', '筛选', '新增', '编辑'])
                  : (_currentView == 'answer'
                        ? (isReviewable
                              ? const ['返回', '保存', '提交', '导出']
                              : const ['返回', '导出'])
                        : (_currentView == 'review'
                              ? const ['返回']
                              : const ['返回'])),
              selectedTab: _currentView == 'paper' ? _selectedTab : '',
              onTabSelected: (tab) {
                if (_currentView == 'paper') {
                  setState(() => _selectedTab = tab);
                } else if (_currentView == 'answer') {
                  if (tab == '返回') {
                    setState(() {
                      _currentView = 'paper';
                      _currentPaperId = null;
                    });
                  } else if (tab == '提交') {
                    _submitReviews();
                  } else if (tab == '保存') {
                    _saveReviews();
                  }
                } else {
                  if (tab == '返回') {
                    setState(() {
                      _currentView = 'answer';
                      _currentAnswerId = null;
                    });
                  }
                }
              },
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() => _aiMessage = '正在处理...');
                _textController.clear();
              },
              hintText: '输入作业要求...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_currentView == 'paper') {
      switch (_selectedTab) {
        case '批阅':
          return _buildReviewFilterView();
        case '筛选':
          return _buildFilterView();
        case '新增':
          return _buildAddView();
        case '编辑':
          return _buildEditView();
        case '删除':
          return _buildDeleteView();
        default:
          return const SizedBox.shrink();
      }
    } else if (_currentView == 'answer') {
      return _buildAnswerView();
    } else if (_currentView == 'review') {
      return _buildReviewView();
    } else {
      return _buildSingleQuestionView();
    }
  }

  Widget _buildReviewFilterView() {
    final data = _pendingReviewData;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '共 ${data.length} 份待批阅试卷',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final isSelected = _selectedRows.contains(item['编号']);
              return Card(
                child: ListTile(
                  leading: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedRows.add(item['编号']!);
                        } else {
                          _selectedRows.remove(item['编号']);
                        }
                      });
                    },
                  ),
                  title: Text(item['类型'] ?? ''),
                  subtitle: Text(
                    '${item['编号']} | ${item['题目数']}题 | ${item['总分']}分',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '待批阅',
                      style: TextStyle(color: Colors.orange[800], fontSize: 12),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _currentView = 'answer';
                      _currentPaperId = item['编号'];
                      _initQuestionReviews();
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

  Widget _buildAnswerView() {
    final paper = _allData.firstWhere(
      (p) => p['编号'] == _currentPaperId,
      orElse: () => {},
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (paper.isNotEmpty)
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
                  '试卷: ${paper['类型']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '编号: ${paper['编号']} | 题目数: ${paper['题目数']} | 总分: ${paper['总分']}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          '答卷列表',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _answerData.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6BB3FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      _answerHeaderCell('学号', flex: 2),
                      _answerHeaderCell('姓名', flex: 1),
                      _answerHeaderCell('状态', flex: 1),
                      _answerHeaderCell('错题', flex: 1),
                      _answerHeaderCell('未答', flex: 1),
                      _answerHeaderCell('得分', flex: 1),
                    ],
                  ),
                );
              }
              final row = _answerData[index - 1];
              final needsReview = row['状态'] == '已完成' && row['AI批阅'] == 'true';
              return GestureDetector(
                onTap: () {
                  if (needsReview) {
                    setState(() {
                      _currentView = 'review';
                      _currentAnswerId = row['编号'];
                      _initQuestionReviews();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: needsReview
                        ? Colors.orange[50]
                        : (index % 2 == 0 ? Colors.white : Colors.grey[50]),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[200] ?? Colors.grey,
                      ),
                      left: needsReview
                          ? BorderSide(color: Colors.orange[400]!, width: 3)
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    children: [
                      _answerCell(row['学号'].toString(), flex: 2),
                      _answerCell(row['姓名'].toString(), flex: 1),
                      _answerStatusCell(row['状态'].toString(), flex: 1),
                      _answerCell(row['错题数'].toString(), flex: 1),
                      _answerCell(row['未答题'].toString(), flex: 1),
                      _answerCell(row['得分'].toString(), flex: 1),
                      if (needsReview)
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            '待批',
                            style: TextStyle(fontSize: 10, color: Colors.red),
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

  Widget _answerHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _answerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _answerStatusCell(String status, {int flex = 1}) {
    Color color;
    switch (status) {
      case '已批改':
        color = Colors.green;
        break;
      case '订正完成':
        color = Colors.blue;
        break;
      case '完成':
        color = Colors.orange;
        break;
      case '进行中':
        color = Colors.yellow;
        break;
      case '未开始':
        color = Colors.grey;
        break;
      default:
        color = Colors.black;
    }
    return Expanded(
      flex: flex,
      child: Text(
        status,
        style: TextStyle(fontSize: 13, color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _submitReviews() {
    setState(() {
      _aiMessage = '已提交所有批阅，状态已更新为已批阅';
      for (var i = 0; i < _answerData.length; i++) {
        if (_answerData[i]['状态'] == '已完成' && _answerData[i]['AI批阅'] == 'true') {
          _answerData[i]['状态'] = '已批阅';
        }
      }
    });
  }

  void _saveReviews() {
    setState(() {
      _aiMessage = '批阅已保存';
    });
  }

  Widget _buildReviewView() {
    final answer = _answerData.firstWhere(
      (a) => a['编号'] == _currentAnswerId,
      orElse: () => {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_document, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Text(
                    '批阅模式',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('AI已预批阅', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('学生: ${answer['姓名']} (${answer['学号']})'),
              Text('当前状态: ${answer['状态']}'),
              const Text(
                '请检查并修订AI批阅结果',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '题目批阅',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _questionDetails.length,
            itemBuilder: (context, index) {
              final q = _questionDetails[index];
              final qId = q['id']!;
              final review = _questionReviews[qId];
              final aiResult = q['AI结果'];
              final currentResult = review?['结果'] ?? aiResult;
              final isCorrect = currentResult == '正确';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '第${q['id']}题',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: aiResult == '正确'
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'AI: $aiResult',
                              style: TextStyle(
                                color: aiResult == '正确'
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Radio<String>(
                                value: '正确',
                                groupValue: currentResult,
                                onChanged: (value) {
                                  setState(() {
                                    _questionReviews[qId]!['结果'] = value;
                                  });
                                },
                              ),
                              const Text(
                                '✓',
                                style: TextStyle(color: Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Radio<String>(
                                value: '错误',
                                groupValue: currentResult,
                                onChanged: (value) {
                                  setState(() {
                                    _questionReviews[qId]!['结果'] = value;
                                  });
                                },
                              ),
                              const Text(
                                '✗',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q['题目']!, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '学生解答: ${q['解答']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('得分: ', style: TextStyle(fontSize: 13)),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              controller: TextEditingController(
                                text: review?['得分'] ?? q['AI得分'],
                              ),
                              onChanged: (value) {
                                _questionReviews[qId]!['得分'] = value;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                isDense: true,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'AI预设: ${q['AI得分']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '批示:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow[50],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.yellow[200]!),
                        ),
                        child: TextField(
                          controller: TextEditingController(
                            text: review?['批注'] ?? q['AI批注'],
                          ),
                          onChanged: (value) {
                            _questionReviews[qId]!['批注'] = value;
                          },
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: '输入批示内容...',
                            border: InputBorder.none,
                            isDense: true,
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (aiResult != currentResult)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '已修订: AI判定为$aiResult，您改为$currentResult',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
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

  Widget _buildSingleQuestionView() {
    final answer = _answerData.firstWhere(
      (a) => a['编号'] == _currentAnswerId,
      orElse: () => {},
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (answer.isNotEmpty)
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
                  '学生: ${answer['姓名']} (${answer['学号']})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '状态: ${answer['状态']} | 得分: ${answer['得分']}',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Text(
          '答题详情',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _questionDetails.length,
            itemBuilder: (context, index) {
              final q = _questionDetails[index];
              final isCorrect = q['结果'] == '正确';
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
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green[100]
                                  : Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              q['结果']!,
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '第${q['id']}题',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '得分: ${q['得分']}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(q['题目']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '学生解答:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q['解答']!,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (q['批注'] != null && q['批注']!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.yellow[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '批注:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                q['批注']!,
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

  // ==================== 筛选视图 ====================
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
        Expanded(child: _buildDataTable(data, showCheckbox: true)),
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

  // ==================== 带复选框的数据表格 ====================
  Widget _buildDataTable(
    List<Map<String, String>> data, {
    bool showCheckbox = false,
  }) {
    return ListView.builder(
      itemCount: data.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildTableHeader(showCheckbox);
        final row = data[index - 1];
        final rowId = row['编号']!;
        final isSelected = _selectedRows.contains(rowId);
        return _buildTableRow(row, isSelected, showCheckbox);
      },
    );
  }

  Widget _buildTableHeader(bool showCheckbox) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF6BB3FF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          if (showCheckbox) const SizedBox(width: 40),
          _headerCell('编号', flex: 1),
          _headerCell('生成时间', flex: 2),
          _headerCell('状态', flex: 1),
          _headerCell('类型', flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(
    Map<String, String> row,
    bool isSelected,
    bool showCheckbox,
  ) {
    final isEven = _allData.indexOf(row) % 2 == 0;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentView = 'answer';
          _currentPaperId = row['编号'];
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isEven ? Colors.white : const Color(0xFFF5F5F5),
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            if (showCheckbox)
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selectedRows.add(row['编号']!);
                    } else {
                      _selectedRows.remove(row['编号']!);
                    }
                  }),
                ),
              ),
            _dataCell(row['编号']!, flex: 1),
            _dataCell(row['生成时间']!, flex: 2),
            _statusCell(row['状态']!, flex: 1),
            _dataCell(row['类型']!, flex: 2),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _statusCell(String status, {int flex = 1}) {
    Color color;
    switch (status) {
      case '未生成':
        color = Colors.grey;
        break;
      case '未完成':
        color = Colors.orange;
        break;
      case '未批阅':
        color = Colors.blue;
        break;
      case '未订正':
        color = Colors.red;
        break;
      default:
        color = Colors.black;
    }
    return Expanded(
      flex: flex,
      child: Text(
        status,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==================== 新增视图（可选题库题目） ====================
  Widget _buildAddView() {
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
            const Text(
              '新增作业/试卷',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('生成方式', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: ['AI生成', '人工配置']
                  .map(
                    (mode) => Row(
                      children: [
                        Radio<String>(
                          value: mode,
                          groupValue: _generateMode,
                          onChanged: (v) => setState(() => _generateMode = v!),
                        ),
                        Text(mode),
                      ],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('难度', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: ['简单', '中等', '困难']
                  .map(
                    (d) => ChoiceChip(
                      label: Text(d),
                      selected: _difficulty == d,
                      onSelected: (_) => setState(() => _difficulty = d),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            const Text('知识点', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _knowledgeOptions.map((k) {
                final selected = _selectedKnowledge.contains(k);
                return FilterChip(
                  label: Text(k),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    if (selected) {
                      _selectedKnowledge.remove(k);
                    } else {
                      _selectedKnowledge.add(k);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '从题库选题',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '已选 ${_selectedQuestions.length} 题',
                  style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._questionBank.map((q) {
              final qid = q['题号']!;
              final selected = _selectedQuestions.contains(qid);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: selected,
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedQuestions.add(qid);
                      } else {
                        _selectedQuestions.remove(qid);
                      }
                    }),
                  ),
                  title: Text(
                    '${q['题号']} - ${q['知识点']}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    '${q['难度']} | ${q['题型']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final now = DateTime.now();
                  setState(() {
                    _allData.add({
                      '编号':
                          'H${(_allData.length + 1).toString().padLeft(3, '0')}',
                      '生成时间':
                          '${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                      '状态': '未生成',
                      '类型': '$_difficulty${_selectedKnowledge.join("")}作业',
                    });
                    _aiMessage = '新增成功！已选 ${_selectedQuestions.length} 道题。';
                    _selectedQuestions.clear();
                    _selectedKnowledge.clear();
                  });
                },
                child: const Text('创建'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 编辑视图（仅未生成状态） ====================
  Widget _buildEditView() {
    final editableItems = _allData.where((d) => _canEdit(d['状态']!)).toList();
    if (editableItems.isEmpty) {
      return const Center(
        child: Text('无可编辑的记录（仅未生成状态可编辑）', style: TextStyle(color: Colors.grey)),
      );
    }
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
            const Text(
              '编辑作业',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '仅显示未生成状态的记录',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            ...editableItems.map(
              (row) => Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            row['编号']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          _statusCell(row['状态']!),
                          const Spacer(),
                          Text(
                            row['生成时间']!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('类型: ${row['类型']!}'),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => setState(
                            () => _aiMessage = '正在编辑 ${row['编号']}...',
                          ),
                          child: const Text('编辑'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 删除视图（仅未生成状态可删除） ====================
  Widget _buildDeleteView() {
    final deletableItems = _allData.where((d) => _canDelete(d['状态']!)).toList();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '可删除 ${deletableItems.length} 条（仅未生成状态）',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            if (_selectedRows.isNotEmpty)
              Text(
                '已选 ${_selectedRows.length} 项',
                style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: deletableItems.isEmpty
              ? const Center(
                  child: Text('无可删除的记录', style: TextStyle(color: Colors.grey)),
                )
              : _buildDataTable(deletableItems, showCheckbox: true),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _selectedRows.isEmpty
                ? null
                : () {
                    setState(() {
                      _allData.removeWhere(
                        (d) => _selectedRows.contains(d['编号']),
                      );
                      _aiMessage = '已删除 ${_selectedRows.length} 条记录';
                      _selectedRows.clear();
                    });
                  },
            child: const Text('确认删除选中项', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
