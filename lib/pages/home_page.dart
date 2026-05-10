
import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/submenu_tabs.dart';
import '../components/menu_grid.dart';
import '../components/efficiency_section.dart';
import '../components/input_area.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onExpandChat;
  final String selectedTab;
  final Function(String) onTabSelected;

  const HomePage({
    super.key,
    required this.onExpandChat,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> homeTabs = [
      '收件箱',
      '错误本',
      '知识点',
      '习题集',
      '作品集',
      '技能库'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: SafeArea(
        child: Column(
          children: [
            const AppTitleBar(
              title: '我的AI语言学习助理',
            ),
            AIReplyBar(
              isExpanded: false,
              onToggle: onExpandChat,
            ),
            SubmenuTabs(
              tabs: homeTabs,
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    MenuGrid(),
                    SizedBox(height: 24),
                    EfficiencySection(),
                  ],
                ),
              ),
            ),
            const InputArea(),
          ],
        ),
      ),
    );
  }
}
