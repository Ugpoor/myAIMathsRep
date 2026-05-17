import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../services/llm_service.dart';

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
  bool _isDetail = false;

  final Set<String> _selectedIds = {};

  final TextEditingController _titleController = TextEditingController();
  String? _lessonTag;
  String? _categoryTag;
  final TextEditingController _richMediaController = TextEditingController();
  final List<String> _selectedKnowledge = [];
  String? _editingId;

  List<Map<String, String>> _allData = [
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

  List<Map<String, dynamic>> _attachments = [];
  bool _isPlayingVideo = false;
  bool _showPromptDialog = false;
  bool _isGenerating = false;

  final LlmService _llmService = LlmService();

  String get aiCoursewarePrompt {
    final knowledge = _selectedKnowledge.isNotEmpty ? _selectedKnowledge.join(', ') : '二次函数';
    return '''你是一位专业的数学课件生成专家。请根据以下要求生成三种不同类型的课件：

1. Python演示交互课件
主要包含以下四个方面：
- 历史渊源：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。
- 前置知识与原理：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？
- 核心公式与可视化：核心公式是什么？请使用Python代码和matplotlib绘制图表来演示不同参数变化时的特性。
- 生活应用案例：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 使用Jupyter Notebook格式
- 包含多个代码单元格，每个单元格有清晰的注释
- 使用matplotlib进行可视化
- 代码要清晰易懂，适合教学
- 最后有一个练习题

2. 传统图文课件
主要包含以下四个方面：
- 历史渊源：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。
- 前置知识与原理：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？
- 核心公式与可视化：核心公式是什么？请描述不同参数变化时的特性，以及如何通过图表展示这些变化。
- 生活应用案例：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 使用Markdown格式
- 结构清晰，层次分明
- 包含定义、原理、示例和练习
- 适合打印和阅读
- 包含适当的表情符号增加趣味性

3. 视频课件（60秒讲稿）
主要包含以下四个方面：
- 历史渊源：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。
- 前置知识与原理：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？
- 核心公式与可视化：核心公式是什么？请描述不同参数变化时的特性，以及如何通过动画演示这些变化。
- 生活应用案例：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 总时长：60秒
- 包含时间戳（每秒标记）
- 画面描述（描述动画、图表、场景）
- 解说词（口语化、生动有趣）
- 标注关键知识点

当前知识点：$knowledge
难度：中等
要求：内容准确，表述清晰，适合中学生学习。''';
  }

  void _generateAICourseware() {
    setState(() {
      _showPromptDialog = true;
    });
    _aiMessage = '正在生成AI课件...';
  }

  Future<void> _confirmGenerateCourseware() async {
    setState(() {
      _showPromptDialog = false;
      _isGenerating = true;
    });
    _aiMessage = '正在调用AI生成课件，请稍候...';

    try {
      final knowledge = _selectedKnowledge.isNotEmpty 
          ? _selectedKnowledge.join(', ') 
          : '二次函数';
      
      // 生成Python交互课件 - 与主提示语一致
      final pythonPrompt = '''你是一位专业的数学课件生成专家。请生成一个Jupyter Notebook格式的Python演示课件，主要包含以下四个方面：

1. **历史渊源**：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。

2. **前置知识与原理**：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？

3. **核心公式与可视化**：核心公式是什么？请使用Python代码和matplotlib绘制图表来演示不同参数变化时的特性。

4. **生活应用案例**：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 使用Jupyter Notebook格式
- 包含多个代码单元格，每个单元格有清晰的注释
- 使用matplotlib进行可视化
- 代码要清晰易懂，适合教学
- 最后有一个练习题

当前知识点：$knowledge

请直接输出完整的Jupyter Notebook代码（.ipynb格式的JSON内容），包含代码和markdown说明。''';

      // 生成图文课件 - 与主提示语一致
      final documentPrompt = '''你是一位专业的数学课件生成专家。请生成一个传统图文课件，主要包含以下四个方面：

1. **历史渊源**：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。

2. **前置知识与原理**：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？

3. **核心公式与可视化**：核心公式是什么？请描述不同参数变化时的特性，以及如何通过图表展示这些变化。

4. **生活应用案例**：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 使用Markdown格式
- 结构清晰，层次分明
- 包含定义、原理、示例和练习
- 适合打印和阅读
- 包含适当的表情符号增加趣味性

当前知识点：$knowledge

请直接输出完整的Markdown文档内容。''';

      // 生成视频课件脚本（60秒讲稿）- 与主提示语一致
      final videoPrompt = '''你是一位专业的数学教学视频脚本专家。请为"$knowledge"生成一个60秒的视频讲稿，主要包含以下四个方面：

1. **历史渊源**：这个知识是因解决哪些实际问题而逐步总结出来的？简要介绍其发现和发展历程。

2. **前置知识与原理**：学习这个知识需要哪些前置知识？它与哪些数学原理相关联？

3. **核心公式与可视化**：核心公式是什么？请描述不同参数变化时的特性，以及如何通过动画演示这些变化。

4. **生活应用案例**：列举2-3个生活中的实际应用案例，让学生能够联系实际理解。

输出格式要求：
- 总时长：60秒
- 包含时间戳（每秒标记）
- 画面描述（描述动画、图表、场景）
- 解说词（口语化、生动有趣）
- 标注关键知识点

请直接输出完整的视频脚本。''';

      // 并行调用LLM生成三种课件
      final results = await Future.wait([
        _llmService.generateResponse(pythonPrompt),
        _llmService.generateResponse(documentPrompt),
        _llmService.generateResponse(videoPrompt),
      ]);

      setState(() {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Python交互课件
        _attachments.add({
          'id': 'A$timestamp',
          'name': 'Python演示交互课件.ipynb',
          'type': 'python',
          'size': '256 KB',
          'preview': results[0]['success'] == true 
              ? results[0]['response'] 
              : 'import numpy as np\nimport matplotlib.pyplot as plt\n\nx = np.linspace(0, 10, 100)\ny = np.sin(x)\n\nplt.plot(x, y)\nplt.show()',
        });

        // 图文课件
        _attachments.add({
          'id': 'B$timestamp',
          'name': '传统图文课件.md',
          'type': 'document',
          'size': '1.2 MB',
          'preview': results[1]['success'] == true 
              ? results[1]['response'] 
              : '## 二次函数的图像与性质\n\n### 知识点概述\n\n二次函数的一般形式为：y = ax² + bx + c',
        });

        // 视频课件
        _attachments.add({
          'id': 'C$timestamp',
          'name': '视频课件脚本.md',
          'type': 'video',
          'size': '15.6 KB',
          'preview': results[2]['success'] == true 
              ? results[2]['response'] 
              : '视频课件脚本\n时长：约5-10分钟\n\n1. 开场白 (0:00-0:30)\n2. 引入概念 (0:30-2:00)\n3. 详细讲解 (2:00-7:00)\n4. 课堂练习 (7:00-9:00)\n5. 总结回顾 (9:00-10:00)',
          'duration': results[2]['success'] == true ? '05:00-10:00' : '待生成',
        });

        _isGenerating = false;
        
        if (results[0]['success'] == true || 
            results[1]['success'] == true || 
            results[2]['success'] == true) {
          _aiMessage = 'AI课件生成成功！已生成3个附件（部分内容由AI真实生成）';
        } else {
          _aiMessage = 'AI课件生成中（演示模式）';
        }
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _aiMessage = 'AI课件生成失败：$e（演示模式）';
      });
    }
  }

  void _cancelGenerateCourseware() {
    setState(() {
      _showPromptDialog = false;
    });
  }

  Widget _buildPromptDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 500,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI课件生成提示语',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _cancelGenerateCourseware,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    aiCoursewarePrompt,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _cancelGenerateCourseware,
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isGenerating ? null : _confirmGenerateCourseware,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BB3FF),
                    foregroundColor: Colors.white,
                  ),
                  child: _isGenerating 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('确认生成'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAttachment(String id) {
    setState(() {
      _attachments.removeWhere((a) => a['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _viewMode == 'edit'
        ? (_isDetail 
            ? const ['返回']
            : (_isNew ? const ['取消', '保存', 'AI课件'] : const ['取消', '保存', '删除']))
        : const ['筛选', '新增'];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppTitleBar(title: 'AI数学课代表-课程研发'),
                AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
                const CollapsibleDateHeader(),
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
            if (_showPromptDialog) _buildPromptDialog(),
            if (_isGenerating)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('正在调用AI生成课件...'),
                          SizedBox(height: 8),
                          Text(
                            'Python交互课件 | 图文课件 | 视频课件',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
      case '取消':
        setState(() { 
          _viewMode = 'list'; 
          _isDetail = false;
          _attachments.clear();
        });
        break;
      case '返回':
        setState(() { 
          _viewMode = 'list'; 
          _isDetail = false;
          _attachments.clear();
        });
        break;
      case '保存':
        _saveEdit();
        break;
      case '删除':
        if (_editingId != null) {
          setState(() {
            _allData.removeWhere((d) => d['id'] == _editingId);
            _aiMessage = '课件已删除';
            _viewMode = 'list';
            _isDetail = false;
            _attachments.clear();
          });
        }
        break;
      case 'AI课件':
        _generateAICourseware();
        break;
    }
  }

  void _openEdit({required bool isNew}) {
    _isNew = isNew;
    _isDetail = false;
    _editingId = null;
    _titleController.clear();
    _lessonTag = null;
    _categoryTag = null;
    _richMediaController.clear();
    _selectedKnowledge.clear();
    _attachments.clear();

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

  void _openDetail(Map<String, String> item) {
    _isNew = false;
    _isDetail = true;
    _editingId = item['id'];
    _titleController.text = item['标题'] ?? '';
    _lessonTag = item['课内标签'];
    _categoryTag = item['类别标签'];
    final kps = item['知识点'] ?? '';
    _selectedKnowledge.clear();
    if (kps.isNotEmpty) _selectedKnowledge.addAll(kps.split('、'));
    _attachments.clear();

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
        _attachments.clear();
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
        _attachments.clear();
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
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedIds.add(item['id']!);
                          } else {
                            _selectedIds.remove(item['id']);
                          }
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDetail(item),
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
    ]);
  }

  Widget _buildEditView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editingId != null ? '编辑课件' : '新增课件',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            const Text('课件标题', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '请输入课件标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const Text('课内标签', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _lessonTag,
              items: _lessonTagOptions
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) => setState(() => _lessonTag = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('请选择课内标签'),
            ),
            const SizedBox(height: 16),
            
            const Text('类别标签', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _categoryTag,
              items: _categoryOptions
                  .map((tag) => DropdownMenuItem(value: tag, child: Text(tag)))
                  .toList(),
              onChanged: (value) => setState(() => _categoryTag = value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('请选择类别标签'),
            ),
            const SizedBox(height: 16),
            
            const Text('知识点', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedKnowledge.isNotEmpty ? _selectedKnowledge.first : null,
              items: _knowledgeOptions
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKnowledge.clear();
                  if (value != null) _selectedKnowledge.add(value);
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              hint: const Text('请选择知识点'),
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
            const SizedBox(height: 20),
            
            const Text('课件附件', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (_attachments.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.upload_file, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('暂无附件'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB3FF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('上传附件'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Column(
                children: _attachments.map((attachment) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            attachment['type'] == 'video' ? Icons.video_file :
                            attachment['type'] == 'python' ? Icons.code :
                            Icons.picture_as_pdf,
                            color: attachment['type'] == 'video' ? Colors.red :
                            attachment['type'] == 'python' ? Colors.blue :
                            Colors.orange,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(attachment['name']),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(attachment['size'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    if (attachment['duration'] != null) ...[
                                      const SizedBox(width: 12),
                                      Text(attachment['duration'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAttachment(attachment['id']),
                          ),
                          if (attachment['type'] == 'video')
                            IconButton(
                              icon: Icon(_isPlayingVideo ? Icons.pause : Icons.play_arrow),
                              onPressed: () {
                                setState(() => _isPlayingVideo = !_isPlayingVideo);
                                _showVideoPreview(attachment);
                              },
                            ),
                          if (attachment['type'] != 'video')
                            IconButton(
                              icon: const Icon(Icons.preview),
                              onPressed: () => _showAttachmentPreview(attachment),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            
            const Text('浏览记录', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            DataTableView(
              headers: const ['时间', '姓名', '学号', '认知特长'],
              rows: _browseRecords.map((r) => [r['时间']!, r['姓名']!, r['学号']!, r['认知特长']!]).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentPreview(Map<String, dynamic> attachment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 500,
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(attachment['name']),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(attachment['preview'] ?? ''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVideoPreview(Map<String, dynamic> attachment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 500,
          height: 400,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(attachment['name']),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _isPlayingVideo = false);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlayingVideo ? Icons.pause_circle : Icons.play_circle,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        const Text('视频预览区域', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(_isPlayingVideo ? Icons.pause : Icons.play_arrow, size: 32),
                    onPressed: () => setState(() => _isPlayingVideo = !_isPlayingVideo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 16),
                  Text(attachment['duration'] ?? '00:00'),
                ],
              ),
            ],
          ),
        ),
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
