import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/pie_chart_view.dart';
import '../components/bar_chart_view.dart';

/// 学情诊断页面
/// 设计文档要求：
/// - SubmenuTabs: 筛选 | 总览 | 明细 | 成就 | 发现
/// - 总览：学情得分分布、知识分布、素养分布饼图 + 学情风险分布图 + 报告
/// - 明细：班级同学明细（学号、姓名、综评）
/// - 成就：成绩、知识得分、素养得分、综评列视图
/// - 发现：趋势图、能力条形图、心态信息、风险行为
class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final TextEditingController _textController = TextEditingController();
  String _aiMessage =
      '你好，我是你的AI数学课代表，全班的数学水平，尽在掌握。';
  String _selectedTab = '总览';

  // 筛选状态
  String _selectedGrade = '六';
  String _selectedClass = '2';

  // Fake数据 - 班级学生列表（明细视图）
  final List<List<String>> _detailRows = [
    ['1', '张三', '346001', '优秀'],
    ['2', '李四', '346002', '优秀'],
    ['3', '王五', '346003', '良好'],
    ['4', '赵六', '346004', '及格'],
    ['5', '钱七', '346005', '良好'],
    ['6', '孙八', '346006', '优秀'],
  ];

  // Fake数据 - 成就视图
  final List<List<String>> _achievementRows = [
    ['1', '张三', '346001', '98', '95', '90', '94.3'],
    ['2', '李四', '346002', '97', '98', '88', '94.3'],
    ['3', '王五', '346003', '85', '82', '80', '82.3'],
    ['4', '赵六', '346004', '72', '70', '68', '70.0'],
    ['5', '钱七', '346005', '88', '85', '86', '86.3'],
    ['6', '孙八', '346006', '96', '93', '91', '93.3'],
  ];

  // 趋势数据（发现-趋势）
  final List<BarChartDataItem> _trendData = [
    BarChartDataItem(label: '', value: 75),
    BarChartDataItem(label: '', value: 80),
    BarChartDataItem(label: '', value: 84),
    BarChartDataItem(label: '', value: 81),
    BarChartDataItem(label: '', value: 71),
    BarChartDataItem(label: '', value: 65),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-学情诊断'),
            AIReplyBar(
              lastAiMessage: _aiMessage,
              onPullDown: () {},
            ),
            DateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: _buildTabContent(),
            ),
            SubmenuTabs(
              tabs: const ['筛选', '总览', '明细', '成就', '发现'],
              selectedTab: _selectedTab,
              onTabSelected: (tab) {
                setState(() => _selectedTab = tab);
              },
              onHomeTap: () => Navigator.pop(context),
            ),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() {
                  _aiMessage = '正在分析学情数据...';
                });
              },
              hintText: '输入诊断要求...',
            ),
          ],
        ),
      ),
    );
  }

  /// 根据选中tab构建内容区域
  Widget _buildTabContent() {
    switch (_selectedTab) {
      case '筛选':
        return _buildFilterView();
      case '总览':
        return _buildOverviewView();
      case '明细':
        return _buildDetailView();
      case '成就':
        return _buildAchievementView();
      case '发现':
        return _buildDiscoveryView();
      default:
        return _buildOverviewView();
    }
  }

  // ==================== 筛选视图 ====================
  Widget _buildFilterView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('筛选条件',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildFilterRow('年级', ['六', '七', '八', '九'], _selectedGrade,
              (v) => setState(() => _selectedGrade = v)),
          const SizedBox(height: 12),
          _buildFilterRow('班级', ['1', '2', '3', '4'], _selectedClass,
              (v) => setState(() => _selectedClass = v)),
          const SizedBox(height: 12),
          _buildRangeFilter('分数范围'),
          const SizedBox(height: 12),
          _buildRangeFilter('知识得分范围'),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _selectedTab = '总览');
              },
              icon: const Icon(Icons.search),
              label: const Text('应用筛选'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(String label, List<String> options,
      String selectedValue, ValueChanged<String> onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 15))),
        ...options.map((opt) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opt),
                selected: selectedValue == opt,
                onSelected: (_) => onChanged(opt),
                selectedColor: Colors.orange[100],
              ),
            )),
      ],
    );
  }

  Widget _buildRangeFilter(String label) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 15))),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '最小值',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~')),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '最大值',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== 总览视图 ====================
  Widget _buildOverviewView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 学情得分分布
          _buildSectionTitle('学情得分分布'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PieChartView(percentage: 33, activeColor: Colors.green, centerText: '优秀', subtitle: '2人', size: 100),
              PieChartView(percentage: 50, activeColor: Colors.blue, centerText: '良好', subtitle: '3人', size: 100),
              PieChartView(percentage: 17, activeColor: Colors.orange, centerText: '及格', subtitle: '1人', size: 100),
            ],
          ),
          const SizedBox(height: 20),

          // 知识点分布
          _buildSectionTitle('知识点分布'),
          SizedBox(
            height: 180,
            child: BarChartView(
              data: const [
                BarChartDataItem(label: '函数', value: 85),
                BarChartDataItem(label: '几何', value: 78),
                BarChartDataItem(label: '代数', value: 72),
                BarChartDataItem(label: '统计', value: 90),
                BarChartDataItem(label: '概率', value: 65),
              ],
              barColor: Colors.indigo,
              height: 180,
            ),
          ),
          const SizedBox(height: 20),

          // 学情风险分布
          _buildSectionTitle('学情风险分布'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildRiskRow('高风险', 1, Colors.red),
                const Divider(),
                _buildRiskRow('中风险', 2, Colors.orange),
                const Divider(),
                _buildRiskRow('低风险', 3, Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ==================== 明细视图 ====================
  Widget _buildDetailView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTableView(
        headers: const ['序号', '姓名', '学号', '综评'],
        rows: _detailRows,
      ),
    );
  }

  // ==================== 成就视图 ====================
  Widget _buildAchievementView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DataTableView(
        headers: const ['序号', '姓名', '学号', '成绩', '知识', '素养', '综评'],
        rows: _achievementRows,
      ),
    );
  }

  // ==================== 发现视图（核心设计）====================
  Widget _buildDiscoveryView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 学生选择栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('346023 王五',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text('高风险',
                      style: TextStyle(color: Colors.redAccent, fontSize: 15, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = '总览'),
                  child: const Text('<< 回到班级',
                      style: TextStyle(
                          color: Colors.blue, fontSize: 15)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 趋势 — 左右布局：图表 + 说明卡片
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiscoverySectionTitle('趋势'),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 140,
                      child: BarChartView(
                        data: const [
                          const BarChartDataItem(label: '', value: 75),
                          const BarChartDataItem(label: '', value: 80),
                          const BarChartDataItem(label: '', value: 84),
                          const BarChartDataItem(label: '', value: 81),
                          const BarChartDataItem(label: '', value: 71),
                          const BarChartDataItem(label: '', value: 65),
                        ],
                        barColor: Colors.indigo,
                        height: 140,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelBadge('下滑3级'),
                    const SizedBox(height: 6),
                    _buildDescCard('波动大，近期下滑明显，接近及格线。'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 能力 — 左右布局：条形图 + 说明卡片
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiscoverySectionTitle('能力'),
                    const SizedBox(height: 4),
                    _buildAbilityBars(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelBadge('特困3级'),
                    const SizedBox(height: 6),
                    _buildDescCard('学习效率低，重复出错率高。'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 心态 — 左右布局：信息列表 + 说明卡片
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiscoverySectionTitle('心态'),
                    const SizedBox(height: 4),
                    _buildMindsetInfo(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelBadge('畏难厌学3级'),
                    const SizedBox(height: 6),
                    _buildDescCard('答题回避难题，听不懂课堂效率低。'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 行为 — 左右布局：信息列表 + 说明卡片
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiscoverySectionTitle('行为'),
                    const SizedBox(height: 4),
                    _buildBehaviorInfo(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLevelBadge('敷衍2级'),
                    const SizedBox(height: 6),
                    _buildDescCard('解题习惯莽撞，敷衍不认真。'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ---- 发现视图子组件 ----

  /// 发现视图 - 维度标题（趋势/能力/心态/行为）
  Widget _buildDiscoverySectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  /// 发现视图 - 等级标签（如"下滑3级"）
  Widget _buildLevelBadge(String level) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(level, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 15)),
          const Icon(Icons.arrow_drop_down, color: Colors.orange, size: 20),
        ],
      ),
    );
  }

  /// 发现视图 - 右侧描述卡片
  Widget _buildDescCard(String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(desc, style: const TextStyle(fontSize: 15, height: 1.4)),
    );
  }

  Widget _buildAbilityBars() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildAbilityBar('前置知识', 0.35),
          const SizedBox(height: 8),
          _buildAbilityBar('修正率', 0.45),
          const SizedBox(height: 8),
          _buildAbilityBar('知识留存', 0.25),
        ],
      ),
    );
  }

  Widget _buildAbilityBar(String label, double ratio) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(label, style: const TextStyle(fontSize: 14))),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: Colors.purple[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMindsetInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('主观留白: 5次/0次'),
          _buildInfoRow('回避难题: 4次/0次'),
          _buildInfoRow('上课开小差: 12次'),
        ],
      ),
    );
  }

  Widget _buildBehaviorInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('交卷时间: 30分钟/45分钟'),
          _buildInfoRow('缺步骤: 22次/5次'),
          _buildInfoRow('字体潦草: 12次/5次'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );
  }

  // ---- 通用组件 ----

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child:
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRiskRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text('$count人', style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
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
