import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/bar_chart_view.dart';
import '../components/filter_dialog.dart';
import '../data/fake_student_data.dart';

class GroupLearningPage extends StatefulWidget {
  const GroupLearningPage({super.key});

  @override
  State<GroupLearningPage> createState() => _GroupLearningPageState();
}

class _GroupLearningPageState extends State<GroupLearningPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '小组导学功能已加载。';
  String _selectedTab = '筛选';

  FilterResult? _filterResult;
  String? _filterSummary;

  List<Map<String, String>> get _groupData {
    final groupMap = <String, List<Map<String, dynamic>>>{};

    for (final student in studentData) {
      final groupName = student['group'] as String;
      if (!groupMap.containsKey(groupName)) {
        groupMap[groupName] = [];
      }
      groupMap[groupName]!.add(student);
    }

    final result = <Map<String, String>>[];
    int index = 1;

    groupMap.forEach((groupName, members) {
      final leader = members.first;
      final avgScore =
          (members.fold(0, (sum, m) => sum + (m['score'] as int)) /
                  members.length)
              .round();
      final avgKnowledge =
          (members.fold(0.0, (sum, m) => sum + (m['knowledge'] as int)) /
                  members.length)
              .round();

      result.add({
        '序号': index.toString(),
        '组名': groupName,
        '队长': leader['name'] as String,
        '人数': members.length.toString(),
        '平均分': avgScore.toString(),
        '平均素养': avgKnowledge.toString(),
        '成员': members.map((m) => m['name'] as String).join('、'),
      });
      index++;
    });

    return result;
  }

  static const _filterFields = [
    FilterField(
      name: '组名',
      key: '组名',
      options: [
        '小组01',
        '小组02',
        '小组03',
        '小组04',
        '小组05',
        '小组06',
        '小组07',
        '小组08',
        '小组09',
        '小组10',
        '小组11',
        '小组12',
      ],
    ),
    FilterField(name: '平均分', key: '平均分', isNumeric: true),
  ];

  List<Map<String, String>> get _filteredData {
    if (_filterResult == null || _filterResult!.isEmpty) return _groupData;
    return _groupData.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null && row[entry.key] != entry.value) return false;
      }
      for (final entry in _filterResult!.rangeValues.entries) {
        if (entry.value != null && row[entry.key] != null) {
          final numStr = row[entry.key]!.replaceAll(RegExp(r'[^\d]'), '');
          final numVal = int.tryParse(numStr);
          if (numVal == null) continue;
          if (entry.value!.min != null) {
            final min = int.tryParse(entry.value!.min!);
            if (min != null && numVal < min) return false;
          }
          if (entry.value!.max != null) {
            final max = int.tryParse(entry.value!.max!);
            if (max != null && numVal > max) return false;
          }
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
              onSend: () {
                setState(() => _aiMessage = '正在分析小组学习情况...');
                _textController.clear();
              },
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '共 ${data.length} 个小组',
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
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final group = data[index];
              return Card(
                child: ExpansionTile(
                  title: Text(group['组名'] ?? ''),
                  subtitle: Text(
                    '队长: ${group['队长']} | ${group['人数']}人 | 平均分: ${group['平均分']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('成员列表: ${group['成员']}'),
                          const SizedBox(height: 8),
                          Text('平均素养: ${group['平均素养']}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
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

  Widget _buildOverviewView() {
    final avgScores = _groupData.map((g) {
      return BarChartDataItem(
        label: g['组名']?.replaceAll('小组', '') ?? '',
        value: (int.tryParse(g['平均分'] ?? '0') ?? 0).toDouble(),
      );
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '各小组平均分对比',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BarChartView(
            data: avgScores,
            barColor: const Color(0xFF6BB3FF),
            height: 200,
          ),
          const SizedBox(height: 24),
          const Text(
            '小组统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('总小组数: ${_groupData.length}个'),
          Text('每组人数: 3人'),
          Text('班级总人数: ${studentData.length}人'),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
