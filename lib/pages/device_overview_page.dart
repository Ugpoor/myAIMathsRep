import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/pie_chart_view.dart';
import '../components/filter_dialog.dart';

/// 设备概览页面
/// 设计文档：SubmenuTabs = 筛选 | 总览 | 明细
class DeviceOverviewPage extends StatefulWidget {
  const DeviceOverviewPage({super.key});

  @override
  State<DeviceOverviewPage> createState() => _DeviceOverviewPageState();
}

class _DeviceOverviewPageState extends State<DeviceOverviewPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '设备概览功能已加载。';
  String _selectedTab = '总览';
  bool _isOverviewMode = true;

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  final List<String> _eventNames = ['意外断线', '考内切屏', '疑似抄袭', '频繁切题', '答题草率', '驻留过长', '未交卷', '白卷'];
  final List<int> _eventCounts = [18, 13, 8, 6, 17, 9, 1, 0];

  final List<List<String>> _allDetailRows = [
    ['PAD-001', '346001', '张三', '0', '1', '0', '0', '2', '0', '0', '0'],
    ['PAD-002', '346002', '李四', '3', '2', '1', '0', '1', '1', '0', '0'],
    ['PAD-003', '346003', '王五', '5', '4', '2', '3', '4', '2', '1', '0'],
    ['PAD-004', '346004', '赵六', '1', '0', '0', '0', '0', '0', '0', '0'],
    ['PAD-005', '346005', '钱七', '9', '6', '5', '3', '10', '6', '0', '0'],
  ];

  static const _filterFields = [
    FilterField(name: '意外断线', key: '意外断线', isNumeric: true),
    FilterField(name: '考内切屏', key: '考内切屏', isNumeric: true),
    FilterField(name: '疑似抄袭', key: '疑似抄袭', isNumeric: true),
    FilterField(name: '频繁切题', key: '频繁切题', isNumeric: true),
    FilterField(name: '答题草率', key: '答题草率', isNumeric: true),
    FilterField(name: '驻留过长', key: '驻留过长', isNumeric: true),
  ];

  // 事件名到列索引的映射 (0=设备号, 1=学号, 2=姓名, 3-10=8个事件)
  static const _eventColIndex = {
    '意外断线': 3, '考内切屏': 4, '疑似抄袭': 5, '频繁切题': 6,
    '答题草率': 7, '驻留过长': 8, '未交卷': 9, '白卷': 10,
  };

  List<List<String>> get _filteredDetailRows {
    if (_filterResult == null || _filterResult!.isEmpty) return _allDetailRows;
    return _allDetailRows.where((row) {
      for (final entry in _filterResult!.rangeValues.entries) {
        if (entry.value != null) {
          final colIdx = _eventColIndex[entry.key];
          if (colIdx == null) continue;
          final numVal = int.tryParse(row[colIdx]);
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
            AppTitleBar(title: 'AI数学课代表-设备概览'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
            SubmenuTabs(
              tabs: _isOverviewMode
                  ? const ['总览', '明细']
                  : const ['筛选', '总览', '明细'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) => setState(() {
                _selectedTab = tab;
                if (tab == '总览') _isOverviewMode = true;
                if (tab == '明细' || tab == '筛选') _isOverviewMode = false;
              }),
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () { setState(() => _aiMessage = '正在分析设备数据...'); },
              hintText: '输入设备查询要求...',
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
        return _buildDetailView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterView() {
    final rows = _filteredDetailRows;
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
        Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: 900,
          child: DataTableView(headers: ['设备号', '学号', '姓名', ..._eventNames], rows: rows),
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
        const Text('设备接通', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        Center(child: PieChartView(percentage: 80, activeColor: Colors.green, centerText: '接通', subtitle: '40/50台', size: 120)),
        const SizedBox(height: 20),
        const Text('异常事件', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
        GridView.count(crossAxisCount: 4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.75, crossAxisSpacing: 8, mainAxisSpacing: 8,
          children: List.generate(8, (i) {
            final count = _eventCounts[i];
            final color = count == 0 ? Colors.green : count > 10 ? Colors.red : Colors.orange;
            return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_eventNames[i], style: const TextStyle(fontSize: 11)), const SizedBox(height: 4),
                Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              ]));
          })),
        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _buildDetailView() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(width: 900, child: DataTableView(headers: ['设备号', '学号', '姓名', ..._eventNames], rows: _filteredDetailRows)));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
