import 'package:flutter/material.dart';
import '../services/student_service.dart';

class DashboardCards extends StatefulWidget {
  final VoidCallback? onDeviceOnlineTap;
  const DashboardCards({super.key, this.onDeviceOnlineTap});

  @override
  State<DashboardCards> createState() => _DashboardCardsState();
}

class _DashboardCardsState extends State<DashboardCards> {
  final StudentService _studentService = StudentService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _studentService.calculateClassStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final dashboardItems = [
      {
        'title': '平均分',
        'value': _stats['averageScore']?.toString() ?? '0',
        'change': '+4',
        'percentage': '',
        'bgColor': const Color(0xFFFFFFFF),
        'valueColor': const Color(0xFFFF5252),
        'changeColor': Colors.green,
      },
      {
        'title': '风险学情',
        'value': _stats['riskCount']?.toString() ?? '0',
        'change': '',
        'percentage': '${_stats['riskPercentage'] ?? 0}%',
        'bgColor': const Color(0xFF9C27B0),
        'valueColor': Colors.white,
        'changeColor': Colors.white,
      },
      {
        'title': '未交作业',
        'value': _stats['homeworkNotSubmitted']?.toString() ?? '0',
        'change': '',
        'percentage': '${_stats['homeworkPercentage'] ?? 0}%',
        'bgColor': const Color(0xFF9C27B0),
        'valueColor': Colors.white,
        'changeColor': Colors.white,
      },
      {
        'title': '小组完成',
        'value': _stats['groupCompletion']?.toString() ?? '0',
        'change': '',
        'percentage': '${_stats['groupPercentage'] ?? 0}%',
        'bgColor': const Color(0xFF9C27B0),
        'valueColor': Colors.white,
        'changeColor': const Color(0xFF8BC34A),
      },
      {
        'title': '薄弱知识',
        'value': _stats['weakKnowledgeCount']?.toString() ?? '0',
        'change': '',
        'percentage': '${_stats['weakKnowledgePercentage'] ?? 0}%',
        'bgColor': const Color(0xFF9C27B0),
        'valueColor': const Color(0xFFCDDC39),
        'changeColor': Colors.white,
      },
      {
        'title': '中考进度',
        'value': _stats['examProgress']?.toString() ?? '0',
        'change': '',
        'percentage': '%',
        'bgColor': const Color(0xFFFFFFFF),
        'valueColor': Colors.black,
        'changeColor': Colors.black,
      },
      {
        'title': '待办',
        'value': _stats['todoCount']?.toString() ?? '0',
        'change': '',
        'percentage': '',
        'bgColor': const Color(0xFF9C27B0),
        'valueColor': Colors.white,
        'changeColor': Colors.white,
      },
      {
        'title': '设备在线',
        'value': _stats['deviceOnline']?.toString() ?? '0',
        'change': '',
        'percentage': '${_stats['devicePercentage'] ?? 0}%',
        'bgColor': const Color(0xFFFFFFFF),
        'valueColor': const Color(0xFF4CAF50),
        'changeColor': Colors.black,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.25,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: dashboardItems.asMap().entries.map((entry) {
        final item = entry.value;
        final index = entry.key;
        final isDeviceOnline = item['title'] == '设备在线';
        final card = _buildDashboardCard(
          item['title'] as String,
          item['value'] as String,
          item['change'] as String,
          item['percentage'] as String,
          item['bgColor'] as Color,
          item['valueColor'] as Color,
          item['changeColor'] as Color,
        );
        if (isDeviceOnline && widget.onDeviceOnlineTap != null) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDeviceOnlineTap,
            child: card,
          );
        }
        return card;
      }).toList(),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    String change,
    String percentage,
    Color bgColor,
    Color valueColor,
    Color changeColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: bgColor == Colors.white
                  ? Colors.grey[600]
                  : Colors.white70,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 1),
          if (change.isNotEmpty)
            Row(
              children: [
                Icon(Icons.trending_up, size: 10, color: changeColor),
                Text(change, style: TextStyle(fontSize: 9, color: changeColor)),
              ],
            ),
          if (percentage.isNotEmpty)
            Text(
              percentage,
              style: TextStyle(
                fontSize: 9,
                color: bgColor == Colors.white
                    ? Colors.grey[500]
                    : Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}
