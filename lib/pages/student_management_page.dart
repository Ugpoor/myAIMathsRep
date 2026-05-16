import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';

/// 学籍管理页面
/// 设计文档：
/// 1. 列表视图：ID、姓名、学号、设备、小组
/// 2. 小组视图的SubmenuTabs：取消、保存
/// 3. 小组视图可增加小组名条目，有取消/保存操作
class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '学籍管理功能已加载。';
  String _selectedTab = '筛选';

  // 筛选状态
  FilterResult? _filterResult;
  String? _filterSummary;

  // 小组编辑状态
  bool _isGroupEditing = false;
  late List<String> _editingGroups;
  final TextEditingController _newGroupController = TextEditingController();

  final List<List<String>> _allRows = [
    ['1', '张三', '346001', 'PAD-001', '雏鹰小队'],
    ['2', '李四', '346002', 'PAD-002', '雏鹰小队'],
    ['3', '王五', '346003', 'PAD-003', '小海豚队'],
    ['4', '赵六', '346004', 'PAD-004', '小海豚队'],
    ['5', '钱七', '346005', 'PAD-005', '星辰小队'],
  ];

  final List<String> _groups = ['雏鹰小队', '小海豚队', '星辰小队', '火箭队'];

  static const _filterFields = [
    FilterField(name: '小组', key: '小组', options: ['雏鹰小队', '小海豚队', '星辰小队', '火箭队']),
    FilterField(name: '设备', key: '设备', isNumeric: false, options: ['PAD-001', 'PAD-002', 'PAD-003', 'PAD-004', 'PAD-005']),
  ];

  List<List<String>> get _filteredRows {
    if (_filterResult == null || _filterResult!.isEmpty) return _allRows;
    return _allRows.where((row) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null) {
          final colIndex = {'小组': 4, '设备': 3}[entry.key];
          if (colIndex != null && row[colIndex] != entry.value) return false;
        }
      }
      return true;
    }).toList();
  }

  void _enterGroupEditing() {
    setState(() {
      _isGroupEditing = true;
      _editingGroups = List.from(_groups);
      _newGroupController.clear();
    });
  }

  void _cancelGroupEditing() {
    setState(() {
      _isGroupEditing = false;
      _editingGroups = [];
      _newGroupController.clear();
    });
  }

  void _saveGroupEditing() {
    setState(() {
      _groups
        ..clear()
        ..addAll(_editingGroups);
      _isGroupEditing = false;
      _editingGroups = [];
      _newGroupController.clear();
      _aiMessage = '小组设置已保存，共 ${_groups.length} 个小组。';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-学籍管理'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
            // 小组编辑模式时，SubmenuTabs显示取消/保存
            if (_isGroupEditing)
              SubmenuTabs(
                tabs: const ['取消', '保存'],
                selectedTab: '',
                onTabSelected: (tab) {
                  if (tab == '取消') _cancelGroupEditing();
                  if (tab == '保存') _saveGroupEditing();
                },
                onHomeTap: _cancelGroupEditing,
              )
            else
              SubmenuTabs(
                tabs: const ['筛选', '新增', '编辑', '小组'],
                selectedTab: _selectedTab,
                onTabSelected: (tab) {
                  if (tab == '小组') {
                    _enterGroupEditing();
                  } else {
                    setState(() => _selectedTab = tab);
                  }
                },
                onHomeTap: () => Navigator.pop(context),
              ),
            InputArea(
              controller: _textController,
              onSend: () { setState(() => _aiMessage = '正在处理学籍信息...'); },
              hintText: '输入学籍管理指令...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // 小组编辑模式
    if (_isGroupEditing) return _buildGroupEditView();

    switch (_selectedTab) {
      case '筛选':
        return _buildFilterView();
      case '新增':
        return _buildFormView('新增学生');
      case '编辑':
        return _buildFormView('编辑学生');
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
        Expanded(child: DataTableView(headers: const ['ID', '姓名', '学号', '设备', '小组'], rows: rows)),
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

  Widget _buildFormView(String title) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        TextField(decoration: const InputDecoration(labelText: '姓名', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: '学号', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(decoration: const InputDecoration(labelText: '设备号', border: OutlineInputBorder(), hintText: '如 PAD-006')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(decoration: const InputDecoration(labelText: '小组', border: OutlineInputBorder()),
          items: _groups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(), onChanged: (_) {}),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => setState(() => _aiMessage = '$title成功！'),
            child: Text(title.startsWith('新增') ? '添加' : '保存修改'))),
      ])));
  }

  /// 小组编辑视图：可增删小组名条目，底部有取消/保存(SubmenuTabs)
  Widget _buildGroupEditView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('小组设置', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _editingGroups.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.group, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: _editingGroups[index]),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 15),
                            onChanged: (val) => _editingGroups[index] = val,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                          onPressed: () => setState(() => _editingGroups.removeAt(index)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            // 新增小组输入行
            Row(
              children: [
                const Icon(Icons.add, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _newGroupController,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: '输入新小组名称',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 15),
                    onSubmitted: _addNewGroup,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                  onPressed: () => _addNewGroup(_newGroupController.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _editingGroups.add(trimmed);
      _newGroupController.clear();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _newGroupController.dispose();
    super.dispose();
  }
}
