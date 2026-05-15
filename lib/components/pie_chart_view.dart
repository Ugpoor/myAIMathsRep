import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// 饼图组件
/// 用于设备概览等页面的数据可视化
class PieChartView extends StatelessWidget {
  final double percentage;
  final Color activeColor;
  final Color inactiveColor;
  final String centerText;
  final String subtitle;
  final double size;

  const PieChartView({
    super.key,
    required this.percentage,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.centerText = '',
    this.subtitle = '',
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: percentage,
                      color: activeColor,
                      title: '',
                      radius: size / 2,
                    ),
                    PieChartSectionData(
                      value: 100 - percentage,
                      color: inactiveColor.withOpacity(0.3),
                      title: '',
                      radius: size / 2,
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: size / 4,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerText.isEmpty ? '${percentage.toInt()}%' : centerText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
