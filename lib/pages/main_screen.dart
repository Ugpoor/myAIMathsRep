import 'package:flutter/material.dart';
import 'home_page.dart';
import 'chat_page.dart';
import 'inbox_page.dart';
import '../components/chat_bubble_list.dart';
import '../services/llm_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isChatMode = false;
  String _selectedTab = '收件箱';
  bool _isLoading = false;
  String _lastAiMessage = '你好，我是你的数学课代表！';
  String? _currentPage;

  final List<ChatMessage> _chatMessages = [];

  final LlmService _llmService = LlmService();

  @override
  void initState() {
    super.initState();
    _initLlmService();
  }

  Future<void> _initLlmService() async {
    await _llmService.init();

final welcomeMessage = ChatMessage(
      sender: 'AI',
      text: '你好，我是你的数学课代表，让我帮你进行数学学习规划。',
      reasoningText: '这是一数学学习助手，需要先介绍自己然后了解用户需求。',
      isAI: true,
    );

    setState(() {
      _chatMessages.add(welcomeMessage);
      _lastAiMessage = welcomeMessage.text;
    });


  void _toggleChatMode() {
    setState(() {
      _isChatMode = !_isChatMode;
      _currentPage = null;
    });
  }

  void _selectTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  void _updateLastAiMessage(String message) {
    setState(() {
      _lastAiMessage = message;
;
  }

  void _addMessage(ChatMessage messag) {
    setState(() {
                 
                 
      _chatMessages.add(message);
      if (message.isAI) {
        _lastAiMessage = message.text;
      }
    });
  }

  void _navigateToPage(String pageName) {
    setState(() {
      _currentPage = pageName;
    });
  }

  void _goBack() {
    setState(() {
      _currentPage = null;
    });
  }

  Future<void> _sendMessage(ChatMessage message) async {
    setState(() {
      _chatMessages.add(message);
      _isLoading = true;
    });

    try {
      final response = await _llmService.generateResponse(message.text);

      setState(() {
        _chatMessages.add(ChatMessage(
          sender: 'AI',
          text: response['response'] ?? '收到你的消息！',
          reasoningText: response['reasoning'] ?? '这是AI推理内容。',
          isAI: true,
        ));
        _lastAiMessage = _chatMessages.last.text;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _chatMessages.add(ChatMessage(
          sender: 'AI',
          text: '抱歉，网络连接失败，请稍后重试。',
          reasoningText: '网络请求失败。',
          isAI: true,
  ));
        _isLoading = false;
      });
          
    }  
  }  
               
               
  
               
               
  @overrid  e
  Widget   ,
        build(BuildContext context) {
    if (_currentPage != null) {
      if (_currentPage == 'inbox') {
        return InboxPage(
          lastAiMessage: _lastAiMessage,
          onHomeTap: _goBack,
        );
          
      }  
    }  
               
               
  
               
               
    return   AnimatedSwitcher(
      du  r,
        ation: const Duration(milliseconds: 300),
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
              onSendMessage: _sendMessage,
              isLoading: _isLoad) HomePage(    key: const ValueKey('home'),
              onExpandChat: _toggleChatMode,
              selectedTab: _selectedTab,
              onTabSelected: _selectTab,
              onHomeTap: () {
                setState(() {
                  _isChatMode = false;
                  _selectedTab = '收件箱';
                });
              },
              onMenuItemTap: (index) {
                const menuLabels = ['收件箱', '错误本', '知识点', '习题集', '作品集', '技能库'];

                if (index == 0) {
                  _navigateToPage('inbox');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('点击了 ${menuLabels[index]}')),
                  );
                }
              },
              lastAiMessage: _lastAiMessage,
              onAiMessageChanged: _updateLastAiMessage,
              onMessageAdded: _addMessage,
            ),
    );
  }
}
                        
                       
                       
                       
                       
                       ,
                      
                      
                        ,
                      ,
                    