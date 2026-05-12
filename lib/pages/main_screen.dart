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
  String _lang = 'cn';

  final List<ChatMessage> _chatMessages = [
    ChatMessage(
      sender: 'AI',
      text: '你好，我是你的语文学习助手，让我帮你进行语文学习规划。',
      reasoningText: '这是一个语言学习助手，需要先介绍自己然后了解用户需求。',
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
      reasoningText: '用户问的是知识点，应该引导他们去查看错误本。',
      isAI: true,
    ),
  ];

  void _toggleChatMode() {
    setState(() {
      _isChatMode = !_isChatMode;
    });
  }

  void _toggleLang() {
    setState(() {
      _lang = _lang == 'cn' ? 'en' : 'cn';
      _selectedTab = _lang == 'cn' ? '收件箱' : 'Inbox';
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
              onHomeTap: () {
                setState(() {
                  _isChatMode = false;
                });
              },
              messages: _chatMessages,
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
              lang: _lang,
            )
          : HomePage(
              key: const ValueKey('home'),
              onExpandChat: _toggleChatMode,
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
              lang: _lang,
              onAvatarTap: _toggleLang,
              onHomeTap: () {
                setState(() {
                  _isChatMode = false;
                  _selectedTab = _lang == 'cn' ? '收件箱' : 'Inbox';
                });
              },
              onMenuItemTap: (index) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_lang == 'cn' ? '点击了菜单 $index' : 'Clicked menu $index')),
                );
              },
              lastAiMessage: _lang == 'cn'
                  ? '你好，我是你的语文学习助手！'
                  : 'Hello, I\'m your English learning assistant!',
            ),
    );
  }
}
