
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'chat_page.dart';
import '../components/chat_bubble_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isChatMode = false;
  String _selectedTab = '收件箱';

  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      sender: 'AI',
      text: '你好，我是你的语文学习助手，让我帮你进行语文学习规划。',
      isAI: true,
    ),
    ChatMessage(
      sender: '用户',
      text: '你好，我想看一下最近有哪些知识点没有掌握好。',
      isAI: false,
    ),
    ChatMessage(
      sender: 'AI',
      text: '通过"错误本"中的知识点视图，就可以看到知识点易错点。',
      isAI: true,
    ),
  ];

  void _toggleChatMode() {
    setState(() {
      _isChatMode = !_isChatMode;
    });
  }

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.3),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _isChatMode
          ? ChatPage(
              key: const ValueKey('chat'),
              onCollapse: _toggleChatMode,
              messages: _chatMessages,
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
            )
          : HomePage(
              key: const ValueKey('home'),
              onExpandChat: _toggleChatMode,
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
            ),
    );
  }
}
