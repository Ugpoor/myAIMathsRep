import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'widget_tests/app_title_bar_test.dart';
import 'widget_tests/ai_reply_bar_test.dart';
import 'widget_tests/menu_grid_test.dart';
import 'widget_tests/efficiency_section_test.dart';
import 'widget_tests/submenu_tabs_test.dart';
import 'widget_tests/input_area_test.dart';
import 'widget_tests/chat_bubble_list_test.dart';
import 'widget_tests/pull_up_control_test.dart';

class WidgetGallery extends StatelessWidget {
  const WidgetGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF6BB3FF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '🎨 部件测试中心',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '选择一个部件进行测试',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _buildSectionTitle('🚀 进入主程序'),
                    _buildMainCard(context),
                    const SizedBox(height: 24),
                    _buildSectionTitle('📦 部件测试'),
                    _buildWidgetButton(
                      context,
                      'AppTitleBar',
                      '通用标题栏',
                      Icons.title,
                      const AppTitleBarTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'AIReplyBar',
                      'AI信息栏',
                      Icons.chat_bubble,
                      const AIReplyBarTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'MenuGrid',
                      '功能菜单网格',
                      Icons.grid_view,
                      const MenuGridTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'EfficiencySection',
                      '效率展示区',
                      Icons.show_chart,
                      const EfficiencySectionTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'SubmenuTabs',
                      '子菜单标签',
                      Icons.tab,
                      const SubmenuTabsTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'InputArea',
                      '用户输入栏',
                      Icons.keyboard,
                      const InputAreaTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'ChatBubbleList',
                      '聊天气泡列表',
                      Icons.chat,
                      const ChatBubbleListTest(),
                    ),
                    _buildWidgetButton(
                      context,
                      'PullUpControl',
                      '收起控制栏',
                      Icons.expand_less,
                      const PullUpControlTest(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF6BB3FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.phone_iphone,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '进入主程序',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '体验完整的我的数学课代表',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF6BB3FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetButton(
    BuildContext context,
    String name,
    String description,
    IconData icon,
    Widget testPage,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => testPage),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(107, 179, 255, 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF6BB3FF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18),
          ],
        ),
      ),
    );
  }
}