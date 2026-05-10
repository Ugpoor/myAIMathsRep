
import 'package:flutter/material.dart';
import '../../components/app_title_bar.dart';
import '../../components/pull_up_control.dart';

class PullUpControlTest extends StatelessWidget {
  const PullUpControlTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: Column(
        children: [
          const AppTitleBar(title: 'PullUpControl 测试'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('📐 基本信息'),
                  _buildInfoItem('名称', 'PullUpControl'),
                  _buildInfoItem('功能', '收起控制栏'),
                  _buildInfoItem('高度', 'screenHeight * 0.05'),
                  const SizedBox(height: 24),
                  _buildSection('🎨 实际效果'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('聊天内容区域'),
                        ),
                        const Divider(height: 1),
                        PullUpControl(
                          onPullUp: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('点击了收起！')),
                            );
                          },
                          label: '点击测试',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('📝 使用示例'),
                  _buildCodeBlock('''
PullUpControl(
  onPullUp: () {
    // 收起操作
  },
  label: '收起聊天',
)
'''),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFFFF69B4),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.lightGreenAccent,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
