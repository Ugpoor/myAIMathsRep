import 'package:flutter/material.dart';
import '../../components/app_title_bar.dart';
import '../../components/submenu_tabs.dart';

class SubmenuTabsTest extends StatefulWidget {
  const SubmenuTabsTest({super.key});

  @override
  State<SubmenuTabsTest> createState() => _SubmenuTabsTestState();
}

class _SubmenuTabsTestState extends State<SubmenuTabsTest> {
  String _selectedTab = '收件箱';
  final List<String> _tabs = ['收件箱', '错误本', '知识点', '习题集', '作品集', '技能库'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Column(
        children: [
          const AppTitleBar(title: 'SubmenuTabs 测试'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('📐 基本信息'),
                  _buildInfoItem('名称', 'SubmenuTabs'),
                  _buildInfoItem('功能', '可滚动的标签栏'),
                  _buildInfoItem('布局', '横向滚动'),
                  _buildInfoItem('选中状态', '高亮显示'),
                  const SizedBox(height: 24),
                  _buildSection('🎨 实际效果'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: SubmenuTabs(
                      tabs: _tabs,
                      selectedTab: _selectedTab,
                      onTabSelected: (tab) {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '当前选中: $_selectedTab',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('📝 使用示例'),
                  _buildCodeBlock('''
SubmenuTabs(
  tabs: ['收件箱', '错误本', '知识点'],
  selectedTab: _selectedTab,
  onTabSelected: (tab) {
    setState(() {
      _selectedTab = tab;
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
        backgroundColor: const Color(0xFF6BB3FF),
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