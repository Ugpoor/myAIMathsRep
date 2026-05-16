import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';

/// 题库页面
class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '题库功能已加载。共收录题目1256道。';
  String _selectedTab = '错题库';

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  final List<Map<String, String>> _allData = [
    {'题目编号': 'Q1001', '生成时间': '2026/5/14 10:30', '题目标题': '二次函数图像对称轴求解', '题目类型': '选择题', '勘误情况': '无'},
    {'题目编号': 'Q1002', '生成时间': '2026/5/13 15:20', '题目标题': '三角形全等判定综合', '题目类型': '解答题', '勘误情况': '有勘误'},
    {'题目编号': 'Q1003', '生成时间': '2026/5/12 09:45', '题目标题': '圆的切线证明', '题目类型': '证明题', '勘误情况': '无'},
  ];

  static const _filterFields = [
    FilterField(name: '题目类型', key: '题目类型', options: ['选择题', '填空题', '解答题', '证明题']),
    FilterField(name: '勘误情况', key: '勘误情况', options: ['无', '有勘误']),
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
                child: _buildContent(),
              ),
            ),
            SubmenuTabs(
              tabs: const ['错题库', '新增', '删除', '导入'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () { setState(() => _aiMessage = '正在搜索题目...'); _textController.clear(); },
              hintText: '搜索题目...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case '错题库':
        return _buildFilterView();
      case '新增':
        return _buildAddView();
      case '删除':
        return _buildDeleteView();
      case '导入':
        return _buildImportView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterView() {
    final data = _filteredData;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('共 ${data.length} 条记录', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ElevatedButton.icon(onPressed: _showFilterDialog, icon: const Icon(Icons.filter_list, size: 18), label: const Text('列筛选'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6BB3FF), foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))),
      ]),
      if (_filterSummary != null)
        Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            Icon(Icons.filter_alt, size: 16, color: Colors.blue.shade700), const SizedBox(width: 6),
            Expanded(child: Text(_filterSummary!, style: TextStyle(fontSize: 12, color: Colors.blue.shade700))),
            GestureDetector(onTap: () => setState(() { _filterResult = null; _filterSummary = null; }),
                child: Icon(Icons.close, size: 16, color: Colors.grey.shade500)),
          ])),
      const SizedBox(height: 10),
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: 600,
        child: DataTableView(headers: const ['题目编号', '生成时间', '题目标题', '题目类型', '勘误情况'],
          rows: data.map((d) => [d['题目编号']!, d['生成时间']!, d['题目标题']!, d['题目类型']!, d['勘误情况']!]).toList(),
        )))),
    ]);
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

  Widget _buildAddView() {
    return SingleChildScrollView(child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('新增题目', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: '题目标题', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: '题目类型', border: OutlineInputBorder()),
          items: ['选择题', '填空题', '解答题', '证明题'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(), onChanged: (_) {}),
        const SizedBox(height: 12), TextField(maxLines: 4, decoration: const InputDecoration(labelText: '题目内容', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _aiMessage = '题目已添加！'), child: const Text('添加题目'))),
      ])));
  }

  Widget _buildDeleteView() {
    return Column(children: [
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: 600,
        child: DataTableView(headers: const ['题目编号', '生成时间', '题目标题', '题目类型', '勘误情况'],
          rows: _fakeData.map((d) => [d['题目编号']!, d['生成时间']!, d['题目标题']!, d['题目类型']!, d['勘误情况']!]).toList(),
        )))),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => setState(() => _aiMessage = '请选择要删除的题目'),
          child: const Text('确认删除选中项', style: TextStyle(color: Colors.white)))),
    ]);
  }

  Widget _buildImportView() {
    return SingleChildScrollView(child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('导入题目', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        const Text('支持的格式：Excel(.xlsx)、CSV、JSON'), const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () => setState(() => _aiMessage = '请选择文件...'),
            icon: const Icon(Icons.upload_file), label: const Text('选择文件'))),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _aiMessage = '导入完成！'), child: const Text('开始导入'))),
      ])));
  }

  List<Map<String, String>> get _fakeData => _filteredData;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
