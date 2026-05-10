
import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/chat_bubble_list.dart';
import '../components/pull_up_control.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';

class ChatPage extends StatelessWidget {
  final VoidCallback onCollapse;
  final List<ChatMessage> messages;
  final String selectedTab;
  final Function(String) onTabSelected;

  const ChatPage({
    super.key,
    required this.onCollapse,
    required this.messages,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> chatTabs = ['筛选'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: SafeArea(
        child: Column(
          children: [
            const AppTitleBar(
              title: '我的AI语言学习助理-聊天',
            ),
            ChatBubbleList(messages: messages),
            PullUpControl(onPullUp: onCollapse),
            SubmenuTabs(
              tabs: chatTabs,
              selectedTab: selectedTab == '筛选' ? selectedTab : chatTabs[0],
              onTabSelected: onTabSelected,
            ),
            const InputArea(),
          ],
        ),
      ),
    );
  }
}
