import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';

class CoursewarePage extends StatefulWidget {
  const CoursewarePage({super.key});

  @override
  State<CoursewarePage> createState() => _CoursewarePageState();
}

class _CoursewarePageState extends State<CoursewarePage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '欢迎使用课程研发功能！我可以帮你生成多认知模式的课件。';

  String _viewMode = 'list';
  String _selectedTab = '筛选';
  bool _isNew = false;

  final Set<String> _selectedIds = {};

  final TextEditingController _titleController = TextEditingController();
  String? _lessonTag;
  String? _categoryTag;
  final TextEditingController _richMediaController = TextEditingController();
  final List<String> _selectedKnowledge = [];
  String? _editingId;

  final List<Map<String, String>> _allData = [
    {'id': 'C001', '标题': '二次函数的图像与性质', '课内标签': '第1单元第2课', '类别标签': '图文', '知识点': '二次函数', '浏览人数': '128', '修订时间': '2026/5/14', '状态': '发布'},
    {'id': 'C002', '标题': '三角形全等的判定', '课内标签': '第2单元第1课', '类别标签': '视频', '知识点': '三角形全等', '浏览人数': '96', '修订时间': '2026/5/13', '状态': '未发布'},
    {'id': 'C003', '标题': '圆的切线性质', '课内标签': '第3单元第3课', '类别标签': '交互', '知识点': '圆的性质', '浏览人数': '45', '修订时间': '2026/5/12', '状态': '发布'},
  ];

  final List<Map<String, String>> _browseRecords = [
    {'时间': '2026/5/14 10:30', '姓名': '张三', '学号': '2024001', '认知特长': '逻辑推理'},
    {'时间': '2026/5/14 11:05', '姓名': '李四', '学号': '2024002', '认知特长': '空间想象'},
    {'时间': '2026/5/13 09:20', '姓名': '王五', '学号': '2024003', '认知特长': '运算能力'},
  ];

  final List<String> _knowledgeOptions = ['二次函数', '三角形全等', '圆的性质', '相似三角形', '实数运算'];

  static const _lessonTagOptions = [
    '第1单元第1课', '第1单元第2课', '第1单元第3课',
    '第2单元第1课', '第2单元第2课', '第2单元第3课',
    '第3单元第1课', '第3单元第2课', '第3单元第3课',
  ];

  static const _categoryOptions = ['图文', '视频', '交互'];

  @override
  Widget build(BuildContext context) {
    final tabs = _viewMode == 'edit'
        ? ['取消', '保存', '删除']
        : ['筛选', '新增', '编辑', '删除'];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-课程研发'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const DateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _viewMode == 'list' ? _buildListView() : _buildEditView(),
              ),
            ),
            SubmenuTabs(
              tabs: tabs,
              selectedTab: _selectedTab,
              onTabSelected: _onSubmenuTab,
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () { 
                setState(() => _aiMessage = '正在生成课件...'); 
                _textController.clear(); 
              },
              hintText: '输入知识点生成课件...',
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmenuTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
    
    switch (tab) {
      case '筛选':
        break;
      case '新增':
        _openEdit(isNew: true);
        break;
      case '编辑':
        if (_selectedIds.length == 1) {
          _openEdit(isNew: false);
        } else {
          setState(() => _aiMessage = '请先在列表中勾选一条记录再编辑');
        }
        break;
      case '删除':
        if (_selectedIds.isEmpty) {
          setState(() => _aiMessage = '请先勾选要删除的记录');
        } else {
          setState(() {
            _allData.removeWhere((d) => _selectedIds.contains(d['id']));
            _aiMessage = '已删除 ${_selectedIds.length} 条记录';
            _selectedIds.clear();
          });
        }
        break;
      case '取消':
        setState(() { _viewMode = 'list'; });
        break;
      case '保存':
        _saveEdit();
        break;
    }
  }

  void _openEdit({required bool isNew}) {
    _isNew = isNew;
    _editingId = null;
    _titleController.clear();
    _lessonTag = null;
    _categoryTag = null;
    _richMediaController.clear();
    _selectedKnowledge.clear();

    if (!isNew && _selectedIds.length == 1) {
      final item = _allData.firstWhere((d) => d['id'] == _selectedIds.first);
      _editingId = item['id'];
      _titleController.text = item['标题'] ?? '';
      _lessonTag = item['课内标签'];
      _categoryTag = item['类别标签'];
      final kps = item['知识点'] ?? '';
      if (kps.isNotEmpty) _selectedKnowledge.addAll(kps.split('、'));
    }

    setState(() { _viewMode = 'edit'; });
  }

  void _saveEdit() {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _aiMessage = '标题不能为空');
      return;
    }
    final knowledgeStr = _selectedKnowledge.join('、');
    final now = DateTime.now();
    final timeStr = '${now.year}/${now.month}/${now.day}';

    if (_isNew) {
      final newId = 'C${(_allData.length + 1).toString().padLeft(3, '0')}';
      setState(() {
        _allData.add({
          'id': newId,
          '标题': _titleController.text.trim(),
          '课内标签': _lessonTag ?? '',
          '类别标签': _categoryTag ?? '',
          '知识点': knowledgeStr,
          '浏览人数': '0',
          '修订时间': timeStr,
          '状态': '未发布',
        });
        _viewMode = 'list';
        _aiMessage = '课件已创建！';
      });
    } else if (_editingId != null) {
      setState(() {
        final idx = _allData.indexWhere((d) => d['id'] == _editingId);
        if (idx >= 0) {
          _allData[idx]['标题'] = _titleController.text.trim();
          _allData[idx]['课内标签'] = _lessonTag ?? '';
          _allData[idx]['类别标签'] = _categoryTag ?? '';
          _allData[idx]['知识点'] = knowledgeStr;
          _allData[idx]['修订时间'] = timeStr;
        }
        _viewMode = 'list';
        _selectedIds.clear();
        _aiMessage = '修改已保存！';
      });
    }
  }

  Widget _buildListView() {
    final data = _allData;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("共 ${data.length} 条记录", style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text("筛选"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6BB3FF), 
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), 
            textStyle: const TextStyle(fontSize: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))
          ),
        ),
      ]),
      const SizedBox(height: 8),
      Expanded(
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final isSelected = _selectedIds.contains(item['id']);
            return Card(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIds.remove(item['id']);
                    } else {
                      _selectedIds.add(item['id']!);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Checkbox(value: isSelected, onChanged: null),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['标题'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(item['课内标签'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(width: 12),
                                Text(item['类别标签'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(width: 12),
                                Text(item['状态'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('课件标题', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: '请输入课件标题',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          
          const Text('课内标签', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _lessonTagOptions.map((tag) {
              final isSelected = _lessonTag == tag;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _lessonTag = selected ? tag : null;
                  });
                },
                selectedColor: const Color(0xFF6BB3FF),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          
          const Text('类别标签', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _categoryOptions.map((tag) {
              final isSelected = _categoryTag == tag;
              return ChoiceChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _categoryTag = selected ? tag : null;
                  });
                },
                selectedColor: const Color(0xFF6BB3FF),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          
          const Text('知识点', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
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
                selectedColor: const Color(0xFF6BB3FF),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100], 
              border: Border.all(color: Colors.grey[300]!), 
              borderRadius: BorderRadius.circular(6)
            ),
            child: Text(
              _selectedKnowledge.isEmpty ? '未选择知识点' : _selectedKnowledge.join('、'),
              style: TextStyle(fontSize: 13, color: _selectedKnowledge.isEmpty ? Colors.grey : Colors.black87)
            ),
          ),
          const SizedBox(height: 16),
          
          const Text('浏览记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          DataTableView(
            headers: const ['时间', '姓名', '学号', '认知特长'],
            rows: _browseRecords.map((r) => [r['时间']!, r['姓名']!, r['学号']!, r['认知特长']!]).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _titleController.dispose();
    _richMediaController.dispose();
    super.dispose();
  }
}