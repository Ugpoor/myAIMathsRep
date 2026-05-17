import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/bar_chart_view.dart';
import '../components/pie_chart_view.dart';
import '../components/filter_dialog.dart';
import '../models/curriculum_outline.dart';
import '../data/fake_curriculum_data.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage = '知识点管理功能已加载。共收录知识点358个。';
  String _selectedTab = '明细';

  bool _showImportDialog = false;
  final TextEditingController _importCsvController = TextEditingController();

  List<CurriculumOutline> _curriculumData = FakeCurriculumData.getAll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppTitleBar(title: 'AI数学课代表-知识点'),
                AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
                const CollapsibleDateHeader(),
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
                  onSend: () {
                    setState(() => _aiMessage = '正在搜索知识点...');
                  },
                  hintText: '搜索知识点...',
                ),
              ],
            ),
            if (_showImportDialog) _buildImportDialog(),
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
      case '大纲':
        return _buildOutlineView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFilterView() {
    final rows = _allRows;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${rows.length} 条记录',
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
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 520,
                child: DataTableView(
                  headers: const ['ID', '描述', '章节', '进度', '分值', '错误率'],
                  rows: rows,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    setState(() => _aiMessage = '列筛选对话框即将打开');
  }

  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '错误率排名 Top5',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          BarChartView(
            data: const [
              BarChartDataItem(label: '圆的性质', value: 52),
              BarChartDataItem(label: '一元二次方程', value: 42),
              BarChartDataItem(label: '二次函数', value: 35),
              BarChartDataItem(label: '三角形全等', value: 28),
              BarChartDataItem(label: '相似三角形', value: 18),
            ],
            barColor: Colors.red,
            height: 200,
          ),
          const SizedBox(height: 24),
          const Text(
            '考点分布',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PieChartView(
                percentage: 50,
                activeColor: Colors.indigo,
                centerText: '代数',
                subtitle: '3个',
                size: 100,
              ),
              PieChartView(
                percentage: 50,
                activeColor: Colors.teal,
                centerText: '几何',
                subtitle: '3个',
                size: 100,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildDetailView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '共 ${_curriculumData.length} 条考纲记录',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _curriculumData.length,
              itemBuilder: (context, index) {
                final outline = _curriculumData[index];
                return Card(
                  child: ListTile(
                    title: Text(outline.knowledgePoint),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${outline.grade} · ${outline.difficulty}'),
                        const SizedBox(height: 4),
                        Text(
                          outline.requirement,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '大纲管理（版本控制）',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('⚠️ 重新导入大纲会重新计算：课堂章节归类、试卷考点归类、错误率归类，请谨慎操作。'),
              ),
              const SizedBox(height: 16),
              const Text(
                '考纲记录',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _curriculumData.length,
                  itemBuilder: (context, index) {
                    final outline = _curriculumData[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        '${outline.id} · ${outline.knowledgePoint}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        '${outline.grade} · ${outline.requirement}',
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildVersionItem('v2.1', '2026/5/10', '当前版本'),
              _buildVersionItem('v2.0', '2026/4/20', ''),
              _buildVersionItem('v1.0', '2026/3/15', ''),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showImportDialogMethod,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('导入新大纲'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionItem(String version, String date, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(version, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Text(date, style: const TextStyle(color: Colors.grey)),
          if (badge.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: TextStyle(color: Colors.green[800], fontSize: 12),
              ),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _aiMessage = '已恢复到 $version'),
            child: const Text('恢复'),
          ),
        ],
      ),
    );
  }

  void _showImportDialogMethod() {
    setState(() {
      _showImportDialog = true;
      _importCsvController.text = FakeCurriculumData.getCsvTemplate();
    });
  }

  Widget _buildImportDialog() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_file, color: Color(0xFF6BB3FF)),
                    const SizedBox(width: 12),
                    const Text(
                      '导入考纲CSV',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          setState(() => _showImportDialog = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('粘贴CSV内容（或从文件导入）：', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: _importCsvController,
                  maxLines: 8,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'ID,知识点,年级,难度,考纲要求,描述,相关主题\nC001,二次函数,九年级,中等,...',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('下载模板'),
                      onPressed: () {
                        _importCsvController.text =
                            FakeCurriculumData.getCsvTemplate();
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Container()),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showImportDialog = false),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB3FF),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _importCsv,
                      child: const Text('导入'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _importCsv() {
    final csvContent = _importCsvController.text;
    if (csvContent.trim().isEmpty) {
      setState(() => _aiMessage = '请输入CSV内容');
      return;
    }

    try {
      final newData = FakeCurriculumData.parseCsv(csvContent);
      if (newData.isNotEmpty) {
        setState(() {
          _curriculumData = newData;
          _showImportDialog = false;
          _aiMessage = '成功导入 ${newData.length} 条考纲记录';
        });
      } else {
        setState(() => _aiMessage = '未解析到有效考纲记录');
      }
    } catch (e) {
      setState(() => _aiMessage = '导入失败：$e');
    }
  }

  final List<List<String>> _allRows = [
    ['1', '二次函数', '代数·第3章', '60%', '12', '35%'],
    ['2', '三角形全等', '几何·第4章', '80%', '8', '28%'],
    ['3', '圆的性质', '几何·第5章', '45%', '15', '52%'],
    ['4', '相似三角形', '几何·第6章', '70%', '10', '18%'],
    ['5', '实数运算', '代数·第1章', '90%', '5', '8%'],
    ['6', '一元二次方程', '代数·第2章', '55%', '14', '42%'],
  ];

  @override
  void dispose() {
    _textController.dispose();
    _importCsvController.dispose();
    super.dispose();
  }
}
