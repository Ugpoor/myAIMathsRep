
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
  final String lang;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onHomeTap;
  final void Function(int)? onMenuItemTap;
  final String lastAiMessage;

  const HomePage({
    super.key,
    required this.onExpandChat,
    required this.selectedTab,
    required this.onTabSelected,
    this.lang = 'cn',
    this.onAvatarTap,
    this.onHomeTap,
    this.onMenuItemTap,
    required this.lastAiMessage,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> homeTabs = lang == 'cn'
        ? ['收件箱', '错误本', '知识点', '习题集', '作品集', '技能库']
        : ['Inbox', 'Errors', 'Knowledge', 'Exercises', 'Portfolio', 'Skills'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(
              title: lang == 'cn' ? '我的AI语言学习助理' : 'My AI Language Tutor',
            ),
            AIReplyBar(
              lang: lang,
              lastAiMessage: lastAiMessage,
              onPullDown: onExpandChat,
              onAvatarTap: onAvatarTap,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuGrid(
                      lang: lang,
                      onItemTap: onMenuItemTap,
                    ),
                    const SizedBox(height: 24),
                    const EfficiencySection(),
                  ],
                ),
              ),
            ),
            SubmenuTabs(
              tabs: homeTabs,
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
              onHomeTap: onHomeTap,
              lang: lang,
            ),
            InputArea(
              lang: lang,
            ),
          ],
        ),
      ),
    );
  }
}
