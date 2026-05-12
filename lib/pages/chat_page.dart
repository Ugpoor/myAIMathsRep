import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/chat_bubble_list.dart';
import '../components/pull_up_control.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';

class ChatPage extends StatelessWidget {
  final VoidCallback onCollapse;
  final VoidCallback onHomeTap;
  final List<ChatMessage> messages;
  final String selectedTab;
  final Function(String) onTabSelected;
  final String lang;

  const ChatPage({
    super.key,
    required this.onCollapse,
    required this.onHomeTap,
    required this.messages,
    required this.selectedTab,
    required this.onTabSelected,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> chatTabs = lang == 'cn' ? ['筛选'] : ['Filter'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(
              title: lang == 'cn' ? '我的AI语言学习助理-聊天' : 'My AI Language Assistant - Chat',
              lang: lang,
            ),
            ChatBubbleList(messages: messages, lang: lang),
            PullUpControl(onPullUp: onCollapse),
            SubmenuTabs(
              tabs: chatTabs,
              selectedTab: selectedTab == chatTabs[0] ? selectedTab : chatTabs[0],
              onTabSelected: onTabSelected,
              onHomeTap: onHomeTap,
              lang: lang,
            ),
            InputArea(lang: lang),
          ],
        ),
      ),
    );
  }
}
