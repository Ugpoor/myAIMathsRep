import 'package:flutter/material.dart';
import 'dart:math';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/filter_dialog.dart';
import '../data/fake_student_data.dart';

/// 学籍管理页面
class StudentManagementPage extends StatefulWidget {
  final String initialTab;

  const StudentManagementPage({super.key, this.initialTab = '筛选'});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _newGroupNameController = TextEditingController();
  String _aiMessage = '学籍管理功能已加载。共管理36名学生。';
  late String _selectedTab;

  bool _isEditing = false;
  bool _isGroupView = false;
  Map<String, dynamic>? _editingStudent;
  final Random _random = Random();

  FilterResult? _filterResult;
  String? _filterSummary;

  final Set<String> _selectedRows = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    if (widget.initialTab == '小组') {
      _isGroupView = true;
    }
  }

  static const _filterFields = [
    FilterField(
      name: '小组',
      key: 'group',
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
    FilterField(name: '设备', key: 'deviceId', options: []),
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    if (_filterResult == null || _filterResult!.isEmpty) return studentData;
    return studentData.where((student) {
      for (final entry in _filterResult!.selectedValues.entries) {
        if (entry.value != null && student[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _openEditView([Map<String, dynamic>? student]) {
    setState(() {
      _isEditing = true;
      _editingStudent = student;
      if (student != null) {
        _nameController.text = student['name'];
        _studentIdController.text = student['studentId'];
        _deviceIdController.text = student['deviceId'];
        _groupController.text = student['group'];
      } else {
        _nameController.clear();
        _studentIdController.clear();
        _deviceIdController.clear();
        _groupController.clear();
      }
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _editingStudent = null;
      _nameController.clear();
      _studentIdController.clear();
      _deviceIdController.clear();
      _groupController.clear();
    });
  }

  void _saveEditing() {
    if (_editingStudent != null) {
      final index = studentData.indexWhere(
        (s) => s['studentId'] == _editingStudent!['studentId'],
      );
      if (index >= 0) {
        setState(() {
          studentData[index] = {
            ...studentData[index],
            'name': _nameController.text,
            'studentId': _studentIdController.text,
            'deviceId': _deviceIdController.text,
            'group': _groupController.text,
          };
        });
      }
    } else {
      final newId = studentData.length + 1;
      setState(() {
        studentData.add({
          'id': newId.toString().padLeft(2, '0'),
          'name': _nameController.text,
          'studentId': _studentIdController.text,
          'deviceId': _deviceIdController.text,
          'group': _groupController.text,
          'score': 60 + _random.nextInt(41),
          'knowledge': 60 + _random.nextInt(41),
          'literacy': 60 + _random.nextInt(41),
          'overall': 60 + _random.nextInt(41),
          'trendRisk': _random.nextInt(100),
          'abilityRisk': _random.nextInt(100),
          'mindsetRisk': _random.nextInt(100),
          'behaviorRisk': _random.nextInt(100),
        });
      });
    }
    _aiMessage = _editingStudent != null ? '学生信息已更新' : '新学生已添加';
    _cancelEditing();
  }

  List<Map<String, dynamic>> get _groupData {
    final groups = <String, int>{};
    for (final student in studentData) {
      final groupName = student['group'] as String;
      groups[groupName] = (groups[groupName] ?? 0) + 1;
    }
    return groups.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList();
  }

  void _toggleView() {
    setState(() {
      _isGroupView = !_isGroupView;
    });
  }

  void _addNewGroup() {
    final newGroupName = _newGroupNameController.text.trim();
    if (newGroupName.isNotEmpty && !groupNames.contains(newGroupName)) {
      setState(() {
        groupNames.add(newGroupName);
      });
      _aiMessage = '已添加新小组：$newGroupName';
      _newGroupNameController.clear();
    }
  }

  Widget _buildGroupView() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newGroupNameController,
                decoration: InputDecoration(
                  hintText: '输入新小组名称',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (val) => _addNewGroup(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addNewGroup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BB3FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('添加小组'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            SizedBox(width: 80, child: Text('小组名称')),
            SizedBox(width: 60, child: Text('人数')),
            SizedBox(width: 80, child: Text('平均分')),
            SizedBox(width: 80, child: Text('平均素养')),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: _groupData.length,
            itemBuilder: (context, index) {
              final group = _groupData[index];
              final groupStudents = studentData
                  .where((s) => s['group'] == group['name'])
                  .toList();
              final avgScore = groupStudents.isNotEmpty
                  ? (groupStudents.fold(
                              0,
                              (sum, s) => sum + (s['score'] as int),
                            ) /
                            groupStudents.length)
                        .round()
                  : 0;
              final avgLiteracy = groupStudents.isNotEmpty
                  ? (groupStudents.fold(
                              0,
                              (sum, s) => sum + (s['literacy'] as int),
                            ) /
                            groupStudents.length)
                        .round()
                  : 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(width: 80, child: Text(group['name'])),
                      SizedBox(
                        width: 60,
                        child: Text(group['count'].toString()),
                      ),
                      SizedBox(width: 80, child: Text(avgScore.toString())),
                      SizedBox(width: 80, child: Text(avgLiteracy.toString())),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
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

  void _deleteSelected() {
    setState(() {
      studentData.removeWhere((s) => _selectedRows.contains(s['studentId']));
      _selectedRows.clear();
    });
    _aiMessage = '已删除${_selectedRows.length}名学生';
  }

  void _clearFilter() {
    setState(() {
      _filterResult = null;
      _filterSummary = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _isEditing
        ? const ['取消', '保存']
        : (_selectedRows.isNotEmpty
              ? [_isGroupView ? '个人' : '小组', '新增', '删除']
              : [_isGroupView ? '个人' : '小组', '新增']);
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-学籍管理'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isEditing ? _buildEditView() : _buildFilterView(),
              ),
            ),
            SubmenuTabs(
              tabs: tabs,
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                if (_isEditing) {
                  if (tab == '取消')
                    _cancelEditing();
                  else if (tab == '保存')
                    _saveEditing();
                } else {
                  setState(() => _selectedTab = tab);
                  if (tab == '个人') {
                    _toggleView();
                  } else if (tab == '小组') {
                    _toggleView();
                  } else if (tab == '新增') {
                    _openEditView();
                  } else if (tab == '删除') {
                    _deleteSelected();
                  }
                }
              },
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() => _aiMessage = '正在搜索...');
                _textController.clear();
              },
              hintText: '搜索学生...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterView() {
    if (_isGroupView) {
      return _buildGroupView();
    }

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
          headers: ['', 'ID', '姓名', '学号', '设备', '小组'],
          rows: [],
          showHeaderOnly: true,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredStudents.length,
            itemBuilder: (context, index) {
              final student = _filteredStudents[index];
              final isSelected = _selectedRows.contains(student['studentId']);
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
                                _selectedRows.add(student['studentId']);
                              } else {
                                _selectedRows.remove(student['studentId']);
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 25,
                        child: Text(
                          student['id'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => _openEditView(student),
                          child: Text(
                            student['name'],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 80,
                        child: Text(
                          student['studentId'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 60,
                        child: Text(
                          student['deviceId'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 50,
                        child: Text(
                          student['group'],
                          style: const TextStyle(fontSize: 14),
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _editingStudent != null ? '编辑学生信息' : '新增学生',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildEditField('姓名', _nameController),
          const SizedBox(height: 16),
          _buildEditField('学号', _studentIdController),
          const SizedBox(height: 16),
          _buildEditField('设备号', _deviceIdController),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '小组',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _groupController.text.isNotEmpty
                    ? _groupController.text
                    : null,
                items: groupNames
                    .map(
                      (group) =>
                          DropdownMenuItem(value: group, child: Text(group)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _groupController.text = value ?? ''),
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

  Widget _buildEditField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}
