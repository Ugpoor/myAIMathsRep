import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/bar_chart_view.dart';
import '../components/filter_dialog.dart';

/// 小组导学页面
class GroupLearningPage extends StatefulWidget {
  const GroupLearningPage({super.key});

  @override
  State<GroupLearningPage> createState() => _GroupLearningPageState();
}

class _GroupLearningPageState extends State<GroupLearningPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '小组导学功能已加载。';
  String _selectedTab = '筛选';

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  final List<Map<String, String>> _allData = [
    {'序号': '1', '组名': '雏鹰小队', '队长': '张三', '任务目标': '实数计算', '完成度': '85%', '帮扶记录': '3次', '建立时间': '2026/4/1', '完成时间': '2026/5/10', '知识点': '实数运算'},
    {'序号': '2', '组名': '小海豚队', '队长': '薛八', '任务目标': '三角形', '完成度': '60%', '帮扶记录': '7次', '建立时间': '2026/4/5', '完成时间': '-', '知识点': '三角形全等'},
    {'序号': '3', '组名': '星辰小队', '队长': '王五', '任务目标': '圆的性质', '完成度': '100%', '帮扶记录': '2次', '建立时间': '2026/3/20', '完成时间': '2026/5/8', '知识点': '圆的性质'},
  ];

  static const _filterFields = [
    FilterField(name: '任务目标', key: '任务目标', options: ['实数计算', '三角形', '圆的性质', '二次函数']),
    FilterField(name: '完成度', key: '完成度', isNumeric: true),
    FilterField(name: '帮扶记录', key: '帮扶记录', isNumeric: true),
  ];

  List<Map<String, String>> get _filteredData {
    if (_filterResult == null || _filterResult!.isEmpty) return _allData;
    return _allData.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null && row[entry.key] != entry.value) return false;
      }
      for (final entry in _filterResult!.rangeValues.entries) {
        if (entry.value != null && row[entry.key] != null) {
          final numStr = row[entry.key]!.replaceAll(RegExp(r'[^\d]'), '');
          final numVal = int.tryParse(numStr);
          if (numVal == null) continue;
          if (entry.value!.min != null) { final min = int.tryParse(entry.value!.min!); if (min != null && numVal < min) return false; }
          if (entry.value!.max != null) { final max = int.tryParse(entry.value!.max!); if (max != null && numVal > max) return false; }
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
            AppTitleBar(title: 'AI数学课代表-小组导学'),
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
              tabs: const ['筛选', '总览'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() => _selectedTab = tab),
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () { setState(() => _aiMessage = '正在分析小组学习情况...'); _textController.clear(); },
              hintText: '输入导学要求...',
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
      Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: 800,
        child: DataTableView(headers: const ['序号', '组名', '队长', '任务目标', '完成度', '帮扶记录', '建立时间', '完成时间', '知识点'],
          rows: data.map((d) => [d['序号']!, d['组名']!, d['队长']!, d['任务目标']!, d['完成度']!, d['帮扶记录']!, d['建立时间']!, d['完成时间']!, d['知识点']!]).toList(),
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

  Widget _buildOverviewView() {
    return SingleChildScrollView(child: Column(children: [
      BarChartView(title: '完成度',
        data: _allData.map((d) => BarChartDataItem(label: d['组名']!, value: double.parse(d['完成度']!.replaceAll('%', '')), color: Colors.blue)).toList(),
        height: 200),
      const SizedBox(height: 24),
      BarChartView(title: '帮扶次数',
        data: _allData.map((d) => BarChartDataItem(label: d['组名']!, value: double.parse(d['帮扶记录']!.replaceAll('次', '')), color: Colors.orange)).toList(),
        height: 200),
    ]));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
