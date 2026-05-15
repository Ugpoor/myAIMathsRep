import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 条形图/柱状图组件
/// 用于学情诊断、设备概览等页面的数据可视化
class BarChartView extends StatelessWidget {
  final List<BarChartDataItem> data;
  final String title;
  final Color barColor;
  final double height;
  final bool showHorizontal;

  const BarChartView({
    super.key,
    required this.data,
    this.title = '',
    this.barColor = Colors.blue,
    this.height = 200,
    this.showHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(),
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < data.length) {
                        return Text(
                          data[value.toInt()].label,
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: data.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: entry.value.value,
                      color: entry.value.color ?? barColor,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final maxValue = data.map((item) => item.value).reduce(
          (a, b) => a > b ? a : b,
        );
    return (maxValue * 1.2).ceilToDouble();
  }
}

class BarChartDataItem {
  final String label;
  final double value;
  final Color? color;
  final String? displayValue;

  const BarChartDataItem({
    required this.label,
    required this.value,
    this.color,
    this.displayValue,
  });
}
