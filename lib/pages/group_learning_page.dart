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
import 'student_management_page.dart';

class GroupLearningPage extends StatefulWidget {
  const GroupLearningPage({super.key});

  @override
  State<GroupLearningPage> createState() => _GroupLearningPageState();
}

class _GroupLearningPageState extends State<GroupLearningPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '小组导学功能已加载。';
  String _selectedTab = '筛选';
  bool _showGroupDetail = false;
  Map<String, dynamic>? _selectedGroup;

  FilterResult? _filterResult;
  String? _filterSummary;

  List<Map<String, dynamic>> get _groupData {
    final groupMap = <String, List<Map<String, dynamic>>>{};

    for (final student in studentData) {
      final groupName = student['group'] as String;
      if (!groupMap.containsKey(groupName)) {
        groupMap[groupName] = [];
      }
      groupMap[groupName]!.add(student);
    }

    final result = <Map<String, dynamic>>[];
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
        '队长学号': leader['id'] as String,
        '人数': members.length.toString(),
        '平均分': avgScore.toString(),
        '平均素养': avgKnowledge.toString(),
        '成员': members.map((m) => m['name'] as String).join('、'),
        '成员详情': members,
        '薄弱知识点': _getWeakKnowledgePoints(members),
        '易错点': _getErrorPoints(members),
        '学情风险': _getRiskLevel(avgScore),
        '点评次数': (index * 5 + 3).toString(),
        '互批试卷': (index * 2 + 1).toString(),
        'AI勘误': (index).toString(),
      });
      index++;
    });

    return result;
  }

  String _getWeakKnowledgePoints(List<Map<String, dynamic>> members) {
    final knowledgePoints = <String, int>{};
    for (final m in members) {
      final knowledge = m['knowledgePoint'] as String?;
      if (knowledge != null) {
        knowledgePoints[knowledge] = (knowledgePoints[knowledge] ?? 0) + 1;
      }
    }
    final sorted = knowledgePoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(2).map((e) => e.key).join('、');
  }

  String _getErrorPoints(List<Map<String, dynamic>> members) {
    final errorPoints = <String, int>{};
    for (final m in members) {
      final errors = m['errorPoints'] as List<dynamic>?;
      if (errors != null) {
        for (final e in errors) {
          errorPoints[e as String] = (errorPoints[e] ?? 0) + 1;
        }
      }
    }
    final sorted = errorPoints.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(2).map((e) => e.key).join('、');
  }

  String _getRiskLevel(int avgScore) {
    if (avgScore >= 85) return '低';
    if (avgScore >= 70) return '中';
    return '高';
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

  List<Map<String, dynamic>> get _filteredData {
    if (_filterResult == null || _filterResult!.isEmpty) return _groupData;
    return _groupData.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null && row[entry.key] != entry.value) return false;
      }
      for (final entry in _filterResult!.rangeValues.entries) {
        if (entry.value != null && row[entry.key] != null) {
          final numStr = row[entry.key].toString().replaceAll(
            RegExp(r'[^\d]'),
            '',
          );
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
    final tabs = _showGroupDetail ? const ['返回'] : const ['筛选', '总览', '新增'];

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
              tabs: tabs,
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                if (_showGroupDetail) {
                  if (tab == '返回') {
                    setState(() {
                      _showGroupDetail = false;
                      _selectedGroup = null;
                    });
                  }
                } else {
                  setState(() => _selectedTab = tab);
                  if (tab == '新增') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const StudentManagementPage(initialTab: '小组'),
                      ),
                    );
                  }
                }
              },
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
    if (_showGroupDetail && _selectedGroup != null) {
      return _buildGroupDetailView();
    }

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
                child: ListTile(
                  title: Text(group['组名'] ?? ''),
                  subtitle: Text(
                    '队长: ${group['队长']} | ${group['人数']}人 | 平均分: ${group['平均分']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    setState(() {
                      _selectedGroup = group;
                      _showGroupDetail = true;
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

  Widget _buildGroupDetailView() {
    final group = _selectedGroup!;
    final members = group['成员详情'] as List<dynamic>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group['组名'] ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),

          const SizedBox(height: 16),
          const Text(
            '小组长信息',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('学号: ${group['队长学号']}'),
                  Text('姓名: ${group['队长']}'),
                  const SizedBox(height: 8),
                  Text(
                    '组长强项知识点: 二次函数、一次函数',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                  Text(
                    '组长易错点: 无明显易错点',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            '小组共性',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text('薄弱知识点: ${group['薄弱知识点']}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Text('易错点: ${group['易错点']}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        group['学情风险'] == '高'
                            ? Icons.dangerous
                            : Icons.check_circle,
                        color: group['学情风险'] == '高' ? Colors.red : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text('学情风险: ${group['学情风险']}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            '小组互动统计',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          group['点评次数'] ?? '0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text('互相点评次数'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          group['互批试卷'] ?? '0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text('互批试卷数量'),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Text(
                          group['AI勘误'] ?? '0',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const Text('AI批阅勘误数'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text(
            '小组成员清单',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: members.map<Widget>((member) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            member['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text('学号: ${member['id']}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('薄弱知识点: ${member['knowledgePoint'] ?? '无'}'),
                      Text(
                        '易错点: ${(member['errorPoints'] as List?)?.join('、') ?? '无'}',
                      ),
                      Text('学情风险: ${_getRiskLevel(member['score'] as int)}'),
                      const Divider(),
                      Text(
                        '点评次数: ${(member['id'].hashCode % 10 + 1).toString()}',
                      ),
                      Text(
                        '互批试卷: ${(member['id'].hashCode % 5 + 1).toString()}',
                      ),
                      Text('AI勘误: ${(member['id'].hashCode % 3).toString()}'),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
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
        label: g['组名']?.toString().replaceAll('小组', '') ?? '',
        value: (int.tryParse(g['平均分'].toString()) ?? 0).toDouble(),
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
