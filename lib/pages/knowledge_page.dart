import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/bar_chart_view.dart';
import '../components/pie_chart_view.dart';
import '../components/filter_dialog.dart';

/// 知识点页面
/// 设计文档：SubmenuTabs = 筛选 | 总览 | 明细 | 大纲
class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '知识点管理功能已加载。共收录知识点358个。';
  String _selectedTab = '明细';

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  // Fake数据
  final List<List<String>> _allRows = [
    ['1', '二次函数', '代数·第3章', '60%', '12', '35%'],
    ['2', '三角形全等', '几何·第4章', '80%', '8', '28%'],
    ['3', '圆的性质', '几何·第5章', '45%', '15', '52%'],
    ['4', '相似三角形', '几何·第6章', '70%', '10', '18%'],
    ['5', '实数运算', '代数·第1章', '90%', '5', '8%'],
    ['6', '一元二次方程', '代数·第2章', '55%', '14', '42%'],
  ];

  static const _filterFields = [
    FilterField(name: '章节', key: '章节', options: ['代数', '几何', '统计']),
    FilterField(name: '错误率', key: '错误率', isNumeric: true),
    FilterField(name: '进度', key: '进度', isNumeric: true),
  ];

  List<List<String>> get _filteredRows {
    if (_filterResult == null || _filterResult!.isEmpty) return _allRows;
    return _allRows.where((row) {
      // 章节筛选 (index 2)
      final chapterVal = _filterResult!.selectedValues['章节'];
      if (chapterVal != null && !row[2].contains(chapterVal)) return false;
      // 错误率范围筛选 (index 5, percentage string)
      final errRange = _filterResult!.rangeValues['错误率'];
      if (errRange != null) {
        final errVal = int.tryParse(row[5].replaceAll('%', ''));
        if (errVal != null) {
          if (errRange.min != null) { final min = int.tryParse(errRange.min!); if (min != null && errVal < min) return false; }
          if (errRange.max != null) { final max = int.tryParse(errRange.max!); if (max != null && errVal > max) return false; }
        }
      }
      // 进度范围筛选 (index 3, percentage string)
      final progRange = _filterResult!.rangeValues['进度'];
      if (progRange != null) {
        final progVal = int.tryParse(row[3].replaceAll('%', ''));
        if (progVal != null) {
          if (progRange.min != null) { final min = int.tryParse(progRange.min!); if (min != null && progVal < min) return false; }
          if (progRange.max != null) { final max = int.tryParse(progRange.max!); if (max != null && progVal > max) return false; }
        }
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
            AppTitleBar(title: 'AI数学课代表-知识点'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const DateHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
            SubmenuTabs(
              tabs: const ['筛选', '总览', '明细', '大纲'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () { setState(() => _aiMessage = '正在搜索知识点...'); },
              hintText: '搜索知识点...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case '筛选':
        return _buildFilterView();
      case '总览':
        return _buildOverviewView();
      case '明细':
        return _buildFilterView(); // 明细也用带筛选的表格
      case '大纲':
        return _buildOutlineView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterView() {
    final rows = _filteredRows;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('共 ${rows.length} 条记录', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: 520,
          child: DataTableView(headers: const ['ID', '描述', '章节', '进度', '分值', '错误率'], rows: rows),
        ))),
      ]),
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

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('错误率排名 Top5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        BarChartView(data: const [
          BarChartDataItem(label: '圆的性质', value: 52), BarChartDataItem(label: '一元二次方程', value: 42),
          BarChartDataItem(label: '二次函数', value: 35), BarChartDataItem(label: '三角形全等', value: 28),
          BarChartDataItem(label: '相似三角形', value: 18),
        ], barColor: Colors.red, height: 200),
        const SizedBox(height: 24),
        const Text('考点分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          PieChartView(percentage: 50, activeColor: Colors.indigo, centerText: '代数', subtitle: '3个', size: 100),
          PieChartView(percentage: 50, activeColor: Colors.teal, centerText: '几何', subtitle: '3个', size: 100),
        ]),
        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _buildOutlineView() {
    return Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('大纲管理（版本控制）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
          child: const Text('⚠️ 重新导入大纲会重新计算：课堂章节归类、试卷考点归类、错误率归类，请谨慎操作。')),
        const SizedBox(height: 16),
        _buildVersionItem('v2.1', '2026/5/10', '当前版本'),
        _buildVersionItem('v2.0', '2026/4/20', ''),
        _buildVersionItem('v1.0', '2026/3/15', ''),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () => setState(() => _aiMessage = '请选择大纲文件进行导入...'),
            icon: const Icon(Icons.upload_file), label: const Text('导入新大纲'))),
      ]))));
  }

  Widget _buildVersionItem(String version, String date, String badge) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
      Text(version, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12),
      Text(date, style: const TextStyle(color: Colors.grey)),
      if (badge.isNotEmpty) ...[const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
          child: Text(badge, style: TextStyle(color: Colors.green[800], fontSize: 12)))],
      const Spacer(),
      TextButton(onPressed: () => setState(() => _aiMessage = '已恢复到 $version'), child: const Text('恢复')),
    ]));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
