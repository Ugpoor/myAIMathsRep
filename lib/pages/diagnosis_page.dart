import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';
import '../components/pie_chart_view.dart';
import '../components/bar_chart_view.dart';
import '../data/fake_student_data.dart';

class DiagnosisPage extends StatefulWidget {
  const DiagnosisPage({super.key});

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _scoreMinController = TextEditingController();
  final TextEditingController _scoreMaxController = TextEditingController();
  final TextEditingController _knowledgeMinController = TextEditingController();
  final TextEditingController _knowledgeMaxController = TextEditingController();
  final TextEditingController _literacyMinController = TextEditingController();
  final TextEditingController _literacyMaxController = TextEditingController();
  String _aiMessage = '你好，我是你的AI数学课代表，全班的数学水平，尽在掌握。';
  String _selectedFilter = '成就';
  String _selectedView = '总览';
  String _selectedGrade = '六';
  String _selectedClass = '2';
  String _selectedAchievementIndicator = '全部';
  String _selectedRiskIndicator = '全部';
  String _selectedRiskLevel = '全部';
  
  bool _isPersonalView = false;
  List<String>? _selectedStudent;
  final Set<int> _selectedAchievementItems = {};
  final Set<int> _selectedRiskItems = {};
  
  String? _riskFilterField;
  String? _riskFilterLevel;

  List<List<String>> get _achievementDetailRows {
    return studentData.map((student) {
      return <String>[
        student['id'] as String,
        student['name'] as String,
        student['studentId'] as String,
        (student['score'] as int).toString(),
        (student['knowledge'] as int).toString(),
        (student['literacy'] as int).toString(),
        (student['overall'] as int).toString(),
      ];
    }).toList();
  }
  
  List<List<String>> get _riskDetailRows {
    return studentData.map((student) {
      return <String>[
        student['id'] as String,
        student['name'] as String,
        student['studentId'] as String,
        (student['trendRisk'] as int).toString(),
        (student['abilityRisk'] as int).toString(),
        (student['mindsetRisk'] as int).toString(),
        (student['behaviorRisk'] as int).toString(),
      ];
    }).toList();
  }
  
  Map<String, Map<String, int>> _calculateRiskCounts() {
    final counts = {
      '趋势': {'高': 0, '中': 0, '低': 0},
      '能力': {'高': 0, '中': 0, '低': 0},
      '心态': {'高': 0, '中': 0, '低': 0},
      '行为': {'高': 0, '中': 0, '低': 0},
    };
    
    for (final student in studentData) {
      final trendRisk = student['trendRisk'] as int;
      final abilityRisk = student['abilityRisk'] as int;
      final mindsetRisk = student['mindsetRisk'] as int;
      final behaviorRisk = student['behaviorRisk'] as int;
      
      _incrementRiskCount(counts['趋势']!, trendRisk);
      _incrementRiskCount(counts['能力']!, abilityRisk);
      _incrementRiskCount(counts['心态']!, mindsetRisk);
      _incrementRiskCount(counts['行为']!, behaviorRisk);
    }
    
    return counts;
  }
  
  void _incrementRiskCount(Map<String, int> countMap, int value) {
    if (value >= 70) {
      countMap['高'] = countMap['高']! + 1;
    } else if (value >= 40) {
      countMap['中'] = countMap['中']! + 1;
    } else {
      countMap['低'] = countMap['低']! + 1;
    }
  }

  List<List<String>> get _filteredRiskRows {
    if (_riskFilterField == null || _riskFilterLevel == null) {
      return _riskDetailRows;
    }
    
    final fieldMap = {
      '趋势': 'trendRisk',
      '能力': 'abilityRisk',
      '心态': 'mindsetRisk',
      '行为': 'behaviorRisk',
    };
    
    final fieldKey = fieldMap[_riskFilterField!];
    if (fieldKey == null) return _riskDetailRows;
    
    return studentData.where((student) {
      final value = student[fieldKey] as int;
      if (_riskFilterLevel == '高') {
        return value >= 70;
      } else if (_riskFilterLevel == '中') {
        return value >= 40 && value < 70;
      } else {
        return value < 40;
      }
    }).map((student) {
      return <String>[
        student['id'] as String,
        student['name'] as String,
        student['studentId'] as String,
        (student['trendRisk'] as int).toString(),
        (student['abilityRisk'] as int).toString(),
        (student['mindsetRisk'] as int).toString(),
        (student['behaviorRisk'] as int).toString(),
      ];
    }).toList();
  }

  final List<BarChartDataItem> _achievementBarData = [
    BarChartDataItem(label: '函数', value: 85),
    BarChartDataItem(label: '几何', value: 78),
    BarChartDataItem(label: '代数', value: 72),
    BarChartDataItem(label: '统计', value: 90),
    BarChartDataItem(label: '概率', value: 65),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-学情诊断'),
            AIReplyBar(lastAiMessage: _aiMessage, onPullDown: () {}),
            const CollapsibleDateHeader(),
            if (!_isPersonalView) _buildFilterTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildContent()),
            _buildSubmenuTabs(),
            InputArea(
              controller: _textController,
              onSend: () {
                setState(() => _aiMessage = '正在分析学情数据...');
                _textController.clear();
              },
              hintText: '输入诊断要求...',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = '成就'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: _selectedFilter == '成就'
                    ? BoxDecoration(
                        color: const Color(0xFF6BB3FF),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Text(
                  '成就',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedFilter == '成就' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = '风险'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: _selectedFilter == '风险'
                    ? BoxDecoration(
                        color: const Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Text(
                  '风险',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _selectedFilter == '风险' ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmenuTabs() {
    if (_isPersonalView) {
      return SubmenuTabs(
        tabs: const ['取消', '保存', '删除'],
        selectedTab: '',
        onTabSelected: (tab) {
          if (tab == '取消') {
            _backFromPersonalView();
          } else if (tab == '保存') {
            _saveChanges();
          } else if (tab == '删除') {
            _deleteSelected();
          }
        },
        onHomeTap: () => Navigator.pop(context),
      );
    } else if (_selectedView == '明细') {
      final hasSelection = _selectedFilter == '成就' 
          ? _selectedAchievementItems.isNotEmpty 
          : _selectedRiskItems.isNotEmpty;
      if (hasSelection) {
        return SubmenuTabs(
          tabs: const ['取消选择', '删除选中'],
          selectedTab: '',
          onTabSelected: (tab) {
            if (tab == '取消选择') {
              setState(() {
                _selectedAchievementItems.clear();
                _selectedRiskItems.clear();
              });
            } else if (tab == '删除选中') {
              _deleteSelectedItems();
            }
          },
          onHomeTap: () => Navigator.pop(context),
        );
      }
      return SubmenuTabs(
        tabs: const ['筛选', '总览', '明细'],
        selectedTab: _selectedView,
        onTabSelected: (tab) => setState(() => _selectedView = tab),
        onHomeTap: () => Navigator.pop(context),
      );
    } else {
      return SubmenuTabs(
        tabs: const ['筛选', '总览', '明细'],
        selectedTab: _selectedView,
        onTabSelected: (tab) => setState(() => _selectedView = tab),
        onHomeTap: () => Navigator.pop(context),
      );
    }
  }

  void _backFromPersonalView() {
    setState(() {
      _isPersonalView = false;
      _selectedStudent = null;
      _selectedView = '明细';
    });
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('保存成功')),
    );
    _backFromPersonalView();
  }

  void _deleteSelected() {
    if (_selectedStudent != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个学生的数据吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
                _backFromPersonalView();
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void _deleteSelectedItems() {
    if (_selectedFilter == '成就' ? _selectedAchievementItems.isNotEmpty : _selectedRiskItems.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除选中的 ${_selectedFilter == '成就' ? _selectedAchievementItems.length : _selectedRiskItems.length} 项数据吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedAchievementItems.clear();
                  _selectedRiskItems.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildContent() {
    if (_isPersonalView && _selectedStudent != null) {
      return _selectedFilter == '成就' 
          ? _buildPersonalAchievementView(_selectedStudent!)
          : _buildPersonalRiskView(_selectedStudent!);
    }

    if (_selectedView == '筛选') {
      return _buildFilterView();
    } else if (_selectedFilter == '成就') {
      return _selectedView == '总览' ? _buildAchievementOverview() : _buildAchievementDetail();
    } else {
      return _selectedView == '总览' ? _buildRiskOverview() : _buildRiskDetail();
    }
  }

  Widget _buildFilterView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('筛选条件', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          
          _buildInputField('姓名', _nameController),
          const SizedBox(height: 16),
          _buildInputField('学号', _studentIdController),
          const SizedBox(height: 16),
          
          _buildDropdownField('年级', ['六', '七', '八', '九'], _selectedGrade, (value) {
            setState(() => _selectedGrade = value!);
          }),
          const SizedBox(height: 16),
          
          _buildDropdownField('班级', ['1', '2', '3', '4'], _selectedClass, (value) {
            setState(() => _selectedClass = value!);
          }),
          const SizedBox(height: 24),
          
          const Text('成就指标', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRangeInput('成绩', _scoreMinController, _scoreMaxController),
          const SizedBox(height: 12),
          _buildRangeInput('知识', _knowledgeMinController, _knowledgeMaxController),
          const SizedBox(height: 12),
          _buildRangeInput('素养', _literacyMinController, _literacyMaxController),
          const SizedBox(height: 16),
          
          _buildDropdownField('选择指标', ['全部', '成绩', '知识', '素养'], _selectedAchievementIndicator, (value) {
            setState(() => _selectedAchievementIndicator = value!);
          }),
          const SizedBox(height: 24),
          
          const Text('风险指标', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          _buildDropdownField('选择风险', ['全部', '趋势风险', '能力风险', '心态风险', '行为风险'], _selectedRiskIndicator, (value) {
            setState(() => _selectedRiskIndicator = value!);
          }),
          const SizedBox(height: 16),
          
          _buildDropdownField('风险等级', ['全部', '高', '中', '低'], _selectedRiskLevel, (value) {
            setState(() => _selectedRiskLevel = value!);
          }),
          const SizedBox(height: 32),
          
          Center(
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _selectedView = '总览'),
              icon: const Icon(Icons.search),
              label: const Text('应用筛选'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BB3FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInputField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text('$label: ', style: const TextStyle(fontSize: 14))),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '请输入$label',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField(String label, List<String> options, String selectedValue, void Function(String?) onChanged) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text('$label: ', style: const TextStyle(fontSize: 14))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue,
                isDense: true,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                items: options.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(opt),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRangeInput(String label, TextEditingController minController, TextEditingController maxController) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text('$label: ', style: const TextStyle(fontSize: 14))),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: minController,
                  decoration: InputDecoration(
                    hintText: '最小',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('-', style: TextStyle(fontSize: 16)),
              ),
              Expanded(
                child: TextField(
                  controller: maxController,
                  decoration: InputDecoration(
                    hintText: '最大',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    isDense: true,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('成绩分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PieChartView(percentage: 33, activeColor: Colors.green, centerText: '优秀', subtitle: '2人', size: 100),
              PieChartView(percentage: 50, activeColor: Colors.blue, centerText: '良好', subtitle: '3人', size: 100),
              PieChartView(percentage: 17, activeColor: Colors.orange, centerText: '及格', subtitle: '1人', size: 100),
            ],
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('知识点掌握率', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 180,
            child: BarChartView(data: _achievementBarData, barColor: Colors.indigo, height: 180),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('素养得分分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PieChartView(percentage: 50, activeColor: Colors.purple, centerText: '优秀', subtitle: '3人', size: 90),
              PieChartView(percentage: 33, activeColor: Colors.blue, centerText: '良好', subtitle: '2人', size: 90),
              PieChartView(percentage: 17, activeColor: Colors.grey, centerText: '一般', subtitle: '1人', size: 90),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAchievementDetail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const DataTableView(
            headers: ['', '序号', '姓名', '学号', '成绩', '知识', '素养', '综评'],
            rows: [],
            showHeaderOnly: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _achievementDetailRows.length,
              itemBuilder: (context, index) {
                final row = _achievementDetailRows[index];
                final isSelected = _selectedAchievementItems.contains(index);
                return Card(
                  color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedAchievementItems.add(index);
                                } else {
                                  _selectedAchievementItems.remove(index);
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 20, child: Text(row[0], style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _openPersonalView(row),
                            child: Text(row[1], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(width: 60, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[2], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[3], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[4], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[5], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[6], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskOverview() {
    final riskCounts = _calculateRiskCounts();
    final total = studentData.length;
    
    // 计算整体风险等级分布（任一因素高则整体算高，依此类推）
    final highRiskCount = studentData.where((s) {
      return s['trendRisk'] >= 70 || s['abilityRisk'] >= 70 || s['mindsetRisk'] >= 70 || s['behaviorRisk'] >= 70;
    }).length;
    final mediumRiskCount = studentData.where((s) {
      if (s['trendRisk'] >= 70 || s['abilityRisk'] >= 70 || s['mindsetRisk'] >= 70 || s['behaviorRisk'] >= 70) {
        return false;
      }
      return (s['trendRisk'] >= 40) || (s['abilityRisk'] >= 40) || 
             (s['mindsetRisk'] >= 40) || (s['behaviorRisk'] >= 40);
    }).length;
    final lowRiskCount = total - highRiskCount - mediumRiskCount;
    
    final highPercent = total > 0 ? ((highRiskCount / total) * 100).round() : 0;
    final mediumPercent = total > 0 ? ((mediumRiskCount / total) * 100).round() : 0;
    final lowPercent = total > 0 ? ((lowRiskCount / total) * 100).round() : 0;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('四因素等级分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildRiskFactorStrip('趋势', riskCounts['趋势']!),
          const SizedBox(height: 8),
          _buildRiskFactorStrip('能力', riskCounts['能力']!),
          const SizedBox(height: 8),
          _buildRiskFactorStrip('心态', riskCounts['心态']!),
          const SizedBox(height: 8),
          _buildRiskFactorStrip('行为', riskCounts['行为']!),
          const SizedBox(height: 16),
          const Text('风险等级分布', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PieChartView(percentage: highPercent.toDouble(), activeColor: Colors.red, centerText: '高风险', subtitle: '$highRiskCount人', size: 90),
              PieChartView(percentage: mediumPercent.toDouble(), activeColor: Colors.orange, centerText: '中风险', subtitle: '$mediumRiskCount人', size: 90),
              PieChartView(percentage: lowPercent.toDouble(), activeColor: Colors.green, centerText: '低风险', subtitle: '$lowRiskCount人', size: 90),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _buildRiskFactorStrip(String factor, Map<String, int> counts) {
    final total = counts['高']! + counts['中']! + counts['低']!;
    var highFlex = total > 0 ? (counts['高']! / total * 100).round() : 0;
    var mediumFlex = total > 0 ? (counts['中']! / total * 100).round() : 0;
    var lowFlex = 100 - highFlex - mediumFlex;
    
    // 确保总和是100
    if (lowFlex < 0) {
      final diff = -lowFlex;
      if (highFlex >= diff) {
        highFlex -= diff;
      } else {
        mediumFlex -= (diff - highFlex);
        highFlex = 0;
      }
      lowFlex = 0;
    }
    
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${factor}风险筛选'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('高风险 (70-99)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _riskFilterField = factor;
                      _riskFilterLevel = '高';
                      _selectedView = '明细';
                    });
                  },
                ),
                ListTile(
                  title: const Text('中风险 (40-69)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _riskFilterField = factor;
                      _riskFilterLevel = '中';
                      _selectedView = '明细';
                    });
                  },
                ),
                ListTile(
                  title: const Text('低风险 (0-39)'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _riskFilterField = factor;
                      _riskFilterLevel = '低';
                      _selectedView = '明细';
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(factor, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('高${counts['高']} 中${counts['中']} 低${counts['低']}', style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: highFlex,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                    ),
                  ),
                ),
                Expanded(
                  flex: mediumFlex,
                  child: Container(
                    height: 24,
                    color: Colors.orange[400],
                  ),
                ),
                Expanded(
                  flex: lowFlex,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green[400],
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskDetail() {
    final rows = _filteredRiskRows;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const DataTableView(
            headers: ['', '序号', '姓名', '学号', '趋势', '能力', '心态', '行为'],
            rows: [],
            showHeaderOnly: true,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final row = rows[index];
                final isSelected = _selectedRiskItems.contains(index);
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
                                  _selectedRiskItems.add(index);
                                } else {
                                  _selectedRiskItems.remove(index);
                                }
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 25, child: Text(row[0], style: const TextStyle(fontSize: 14))),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => _openPersonalView(row),
                            child: Text(row[1], style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(width: 65, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[2], style: const TextStyle(fontSize: 14)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[3], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[4], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[5], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        SizedBox(width: 30, child: GestureDetector(
                          onTap: () => _openPersonalView(row),
                          child: Text(row[6], style: const TextStyle(fontSize: 12)),
                        )),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openPersonalView(List<String> student) {
    setState(() {
      _selectedStudent = student;
      _isPersonalView = true;
    });
  }

  Widget _buildPersonalAchievementView(List<String> student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user_logo.png'),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student[1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('学号: ${student[2]}', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('成就总览', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildScoreCard('成绩', student[3], Colors.blue),
              _buildScoreCard('知识', student[4], Colors.green),
              _buildScoreCard('素养', student[5], Colors.purple),
            ],
          ),
          const SizedBox(height: 20),
          const Text('知识点掌握详情', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChartView(data: _achievementBarData, barColor: Colors.indigo, height: 180),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPersonalRiskView(List<String> student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/user_logo.png'),
                  radius: 30,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student[1], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('学号: ${student[2]}', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: student[3] == '高' ? Colors.red[100]! : student[3] == '中' ? Colors.orange[100]! : Colors.green[100]!,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${student[3]}风险',
                    style: TextStyle(
                      color: student[3] == '高' ? Colors.red : student[3] == '中' ? Colors.orange : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('四因素风险分析', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildRiskDetailCard('趋势风险', student[3]),
          const SizedBox(height: 12),
          _buildRiskDetailCard('能力风险', student[4]),
          const SizedBox(height: 12),
          _buildRiskDetailCard('心态风险', student[5]),
          const SizedBox(height: 12),
          _buildRiskDetailCard('行为风险', student[6]),
          const SizedBox(height: 20),
          const Text('风险建议', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '建议针对该学生的薄弱环节进行专项辅导，重点关注知识点掌握和学习态度的提升。',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildRiskDetailCard(String title, String level) {
    Color color;
    switch (level) {
      case '高':
        color = Colors.red;
        break;
      case '中':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                level == '高' ? Icons.warning : level == '中' ? Icons.info : Icons.check,
                color: color,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(level, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRiskFactorCard(String title, String subtitle, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _scoreMinController.dispose();
    _scoreMaxController.dispose();
    _knowledgeMinController.dispose();
    _knowledgeMaxController.dispose();
    _literacyMinController.dispose();
    _literacyMaxController.dispose();
    super.dispose();
  }
}