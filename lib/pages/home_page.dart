import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/submenu_tabs.dart';
import '../components/menu_grid.dart';
import '../components/efficiency_section.dart';
import '../components/input_area.dart';
import '../services/llm_service.dart';
import '../components/chat_bubble_list.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onExpandChat;
  final String selectedTab;
  final Function(String) onTabSelected;
  final VoidCallback? onHomeTap;
  final void Function(int)? onMenuItemTap;
  final String lastAiMessage;
  final ValueChanged<String>? onAiMessageChanged;
  final ValueChanged<ChatMessage>? onMessageAdded;

  const HomePage({
    super.key,
    required this.onExpandChat,
    required this.selectedTab,
    required this.onTabSelected,
    this.onHomeTap,
    this.onMenuItemTap,
    required this.lastAiMessage,
    this.onAiMessageChanged,
    this.onMessageAdded,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final LlmService _llmService = LlmService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _llmService.init();
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userMessage = ChatMessage(
        sender: '用户',
        text: text,
        isAI: false,
      );dget.onMessaginal respons
      final aiMessage = ChatMessage(
        sender: 'AI',
        text: response['response'] ?? '收到你的消息！',
  reasoningText: response['reasoning'] ?? '这是AI推理内容。',
        isAI: true,
      );
      widget.
           onMessageAdded?.call(aiM
           essage);

           
           
      widget.onAiMessageChanged?.call(aiMessage.text);
      _textController.clear();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const homeTabs = ['收件箱', '错误本', '知识点', '习题集', '作品集', '技能库'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(
              title: '我的数学课代表',
            ),
            AIReplyBar(
              lastAiMessage: widget.lastAiMessage,
              onPullDown: widget.onExpandChat,
            ),
            Expanded(
                 
                 
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuGrid(
                      onItemTap: widget.onMenuItemTap,
                    ),
                    const SizedBox(height: 24),
                    const EfficiencySection(),
                  ],
                ),
              ),
            ),
            SubmenuTabs(
              tabs: homeTabs,
              selectedTab: widget.selectedTab,
              onTabSelected: widget.onTabSelected,
              onHomeTap: widget.onHomeTap,
            ),
            InputArea(
              controller: _textController,
              onSend: _handleSend,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}