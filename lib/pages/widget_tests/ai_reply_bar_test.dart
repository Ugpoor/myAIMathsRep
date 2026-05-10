
import 'package:flutter/material.dart';
import '../../components/ai_reply_bar.dart';
import '../../components/app_title_bar.dart';

class AIReplyBarTest extends StatefulWidget {
  const AIReplyBarTest({super.key});

  @override
  State<AIReplyBarTest> createState() => _AIReplyBarTestState();
}

class _AIReplyBarTestState extends State<AIReplyBarTest> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: Column(
        children: [
          const AppTitleBar(title: 'AIReplyBar 测试'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('📐 基本信息'),
                  _buildInfoItem('名称', 'AIReplyBar'),
                  _buildInfoItem('功能', 'AI信息栏，支持收起/展开'),
                  _buildInfoItem('收起高度', '100'),
                  _buildInfoItem('展开高度', '200'),
                  const SizedBox(height: 24),
                  _buildSection('🎨 实际效果'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        AIReplyBar(
                          isExpanded: _isExpanded,
                          onToggle: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF69B4),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(_isExpanded ? '点击收起' : '点击展开'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('📝 使用示例'),
                  _buildCodeBlock('''
AIReplyBar(
  isExpanded: _isExpanded,
  onToggle: () {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  },
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
