import 'package:flutter/material.dart';

class EfficiencySection extends StatelessWidget {
  const EfficiencySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '我的效率',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              flex: 6,
              child: _buildEfficiencyWidget(
                title: '效率记录',
                color: const Color(0xFF651FFF),
                children: const [
                  Text(
                    '书写速度: 20字/分钟',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '阅读速度: 280字/分钟',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '正确率: 85%',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '学习时长: 45分钟/天',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: _buildEfficiencyWidget(
                title: '日程安排',
                color: const Color(0xFFC2185B),
                children: const [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '19:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '每天一篇阅读',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '每周一次写作',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '每月测评一次',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEfficiencyWidget({
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(
              (color.r * 255.0).round().clamp(0, 255),
              (color.g * 255.0).round().clamp(0, 255),
              (color.b * 255.0).round().clamp(0, 255),
              0.3,
            ),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
