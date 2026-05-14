import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/chat_bubble_list.dart';
import '../components/pull_up_control.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';

class ChatPage extends StatefulWidget {
  final VoidCallback onCollapse;
  final VoidCallback onHomeTap;
  final List<ChatMessage> messages;
  final String selectedTab;
  final Function(String) onTabSelected;
  final Future<void> Function(ChatMessage) onSendMessage;
  final bool isLoading;

  const ChatPage({
    super.key,
    required this.onCollapse,
    required this.onHomeTap,
    required this.messages,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      final message = ChatMessage(
        sender: '用户',
        text: text,
        isAI: false,
      );
      widget.onSendMessage(message);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    const chatTabs = ['筛选'];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(
              title: '我的数学课代表-聊天',
            ),
            Expanded(
              child: Stack(
                children: [
                  ChatBubbleList(messages: widget.messages),
                  if (widget.isLoading)
                    const Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF6BB3FF),
                                strokeWidth: 2,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'AI正在思考...',
                                style: TextStyle(
                                  color: Color(0xFF6BB3FF),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            PullUpControl(onPullUp: widget.onCollapse),
            SubmenuTabs(
              tabs: chatTabs,
              selectedTab: widget.selectedTab == chatTabs[0] ? widget.selectedTab : chatTabs[0],
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