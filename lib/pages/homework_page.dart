import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/date_header.dart';
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

  final List<Map<String, String>> _allData = [
    {'编号': 'H001', '生成时间': '2026/5/14 14:30', '状态': '未批阅', '类型': '二次函数练习题'},
    {'编号': 'H002', '生成时间': '2026/5/13 10:15', '状态': '未完成', '类型': '三角形全等测试'},
    {'编号': 'H003', '生成时间': '2026/5/12 09:00', '状态': '未订正', '类型': '圆与相似形'},
    {'编号': 'H004', '生成时间': '2026/5/11 08:45', '状态': '未生成', '类型': '实数运算单元卷'},
  ];

  final List<String> _knowledgeOptions = ['二次函数', '三角形全等', '圆的性质', '相似三角形', '实数运算'];

  // 模拟题库
  final List<Map<String, String>> _questionBank = [
    {'题号': 'Q001', '知识点': '二次函数', '难度': '中等', '题型': '解答题'},
    {'题号': 'Q002', '知识点': '二次函数', '难度': '困难', '题型': '证明题'},
    {'题号': 'Q003', '知识点': '三角形全等', '难度': '简单', '题型': '选择题'},
    {'题号': 'Q004', '知识点': '圆的性质', '难度': '中等', '题型': '填空题'},
    {'题号': 'Q005', '知识点': '相似三角形', '难度': '困难', '题型': '解答题'},
    {'题号': 'Q006', '知识点': '实数运算', '难度': '简单', '题型': '计算题'},
  ];

  static const _filterFields = [
    FilterField(name: '状态', key: '状态', options: ['未生成', '未完成', '未批阅', '未订正']),
    FilterField(name: '类型', key: '类型', options: ['练习题', '测试', '单元卷', '期中考试', '期末考试']),
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

  bool _canEdit(String status) => status == '未生成';
  bool _canDelete(String status) => status == '未生成';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-作业试卷'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const DateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(),
              ),
            ),
            SubmenuTabs(
              tabs: const ['筛选', '新增', '编辑', '删除'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
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
    switch (_selectedTab) {
      case '筛选': return _buildFilterView();
      case '新增': return _buildAddView();
      case '编辑': return _buildEditView();
      case '删除': return _buildDeleteView();
      default: return const SizedBox.shrink();
    }
  }

  // ==================== 筛选视图 ====================
  Widget _buildFilterView() {
    final data = _filteredData;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('共 ${data.length} 条记录', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ElevatedButton.icon(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list, size: 18),
              label: const Text('列筛选'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BB3FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
        if (_filterSummary != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                Expanded(child: Text(_filterSummary!, style: TextStyle(fontSize: 12, color: Colors.blue.shade700))),
                GestureDetector(
                  onTap: () => setState(() { _filterResult = null; _filterSummary = null; }),
                  child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
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
    final result = await FilterDialog.show(context, fields: _filterFields, initialResult: _filterResult);
    if (result != null) {
      setState(() {
        _filterResult = result;
        final parts = <String>[];
        result.selectedValues.forEach((key, value) { if (value != null) parts.add('$key=$value'); });
        result.rangeValues.forEach((key, value) { if (value != null) parts.add('$key: ${value.min ?? '*'} ~ ${value.max ?? '*'}'); });
        _filterSummary = parts.isEmpty ? null : parts.join(' | ');
      });
    }
  }

  // ==================== 带复选框的数据表格 ====================
  Widget _buildDataTable(List<Map<String, String>> data, {bool showCheckbox = false}) {
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
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center));
  }

  Widget _buildTableRow(Map<String, String> row, bool isSelected, bool showCheckbox) {
    final isEven = _allData.indexOf(row) % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : const Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        children: [
          if (showCheckbox)
            SizedBox(
              width: 40,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) => setState(() {
                  if (v == true) { _selectedRows.add(row['编号']!); } else { _selectedRows.remove(row['编号']!); }
                }),
              ),
            ),
          _dataCell(row['编号']!, flex: 1),
          _dataCell(row['生成时间']!, flex: 2),
          _statusCell(row['状态']!, flex: 1),
          _dataCell(row['类型']!, flex: 2),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(fontSize: 13), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis));
  }

  Widget _statusCell(String status, {int flex = 1}) {
    Color color;
    switch (status) {
      case '未生成': color = Colors.grey; break;
      case '未完成': color = Colors.orange; break;
      case '未批阅': color = Colors.blue; break;
      case '未订正': color = Colors.red; break;
      default: color = Colors.black;
    }
    return Expanded(flex: flex, child: Text(status, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600), textAlign: TextAlign.center));
  }

  // ==================== 新增视图（可选题库题目） ====================
  Widget _buildAddView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('新增作业/试卷', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('生成方式', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: ['AI生成', '人工配置'].map((mode) =>
              Row(children: [Radio<String>(value: mode, groupValue: _generateMode, onChanged: (v) => setState(() => _generateMode = v!)), Text(mode)])).toList()),
            const SizedBox(height: 12),
            const Text('难度', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 8, children: ['简单', '中等', '困难'].map((d) =>
              ChoiceChip(label: Text(d), selected: _difficulty == d, onSelected: (_) => setState(() => _difficulty = d))).toList()),
            const SizedBox(height: 12),
            const Text('知识点', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(spacing: 8, children: _knowledgeOptions.map((k) {
              final selected = _selectedKnowledge.contains(k);
              return FilterChip(label: Text(k), selected: selected, onSelected: (_) => setState(() {
                if (selected) { _selectedKnowledge.remove(k); } else { _selectedKnowledge.add(k); }
              }));
            }).toList()),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('从题库选题', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text('已选 ${_selectedQuestions.length} 题', style: TextStyle(fontSize: 13, color: Colors.blue.shade700)),
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
                      if (v == true) { _selectedQuestions.add(qid); } else { _selectedQuestions.remove(qid); }
                    }),
                  ),
                  title: Text('${q['题号']} - ${q['知识点']}', style: const TextStyle(fontSize: 13)),
                  subtitle: Text('${q['难度']} | ${q['题型']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                final now = DateTime.now();
                setState(() {
                  _allData.add({
                    '编号': 'H${(_allData.length + 1).toString().padLeft(3, '0')}',
                    '生成时间': '${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                    '状态': '未生成',
                    '类型': '$_difficulty${_selectedKnowledge.join("")}作业',
                  });
                  _aiMessage = '新增成功！已选 ${_selectedQuestions.length} 道题。';
                  _selectedQuestions.clear();
                  _selectedKnowledge.clear();
                });
              },
              child: const Text('创建'),
            )),
          ],
        ),
      ),
    );
  }

  // ==================== 编辑视图（仅未生成状态） ====================
  Widget _buildEditView() {
    final editableItems = _allData.where((d) => _canEdit(d['状态']!)).toList();
    if (editableItems.isEmpty) {
      return const Center(child: Text('无可编辑的记录（仅未生成状态可编辑）', style: TextStyle(color: Colors.grey)));
    }
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('编辑作业', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('仅显示未生成状态的记录', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ...editableItems.map((row) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(row['编号']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      _statusCell(row['状态']!),
                      const Spacer(),
                      Text(row['生成时间']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ]),
                    const SizedBox(height: 8),
                    Text('类型: ${row['类型']!}'),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _aiMessage = '正在编辑 ${row['编号']}...'),
                        child: const Text('编辑'),
                      ),
                    ),
                  ],
                ),
              ),
            )),
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
            Text('可删除 ${deletableItems.length} 条（仅未生成状态）', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            if (_selectedRows.isNotEmpty)
              Text('已选 ${_selectedRows.length} 项', style: TextStyle(fontSize: 13, color: Colors.blue.shade700)),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: deletableItems.isEmpty
              ? const Center(child: Text('无可删除的记录', style: TextStyle(color: Colors.grey)))
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
                      _allData.removeWhere((d) => _selectedRows.contains(d['编号']));
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
