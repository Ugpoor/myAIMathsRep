
import 'package:flutter/material.dart';
import '../database/models/chat_message.dart';
import '../services/app_service.dart';

class ChatScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onBack;

  const ChatScreen({
    super.key,
    this.lang = 'cn',
    required this.onBack,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final Map<int, bool> _showReasoning = {};

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await AppService().getChatMessages(lang: widget.lang);
    setState(() {
      _messages = messages;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    await AppService().sendMessage(text, lang: widget.lang);
    await _loadMessages();

    _controller.clear();
    setState(() {
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String getAiAvatarAsset(bool showReasoning) {
    if (widget.lang == 'cn') {
      return showReasoning
          ? 'assets/images/chinese_msg_brain.png'
          : 'assets/images/chinese_msg.png';
    } else {
      return showReasoning
          ? 'assets/images/english_msg_brain.png'
          : 'assets/images/english_msg.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final showReasoning = _showReasoning[message.id ?? index] ?? false;
                return _buildChatBubble(message, message.id ?? index, showReasoning);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFF69B4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          const SizedBox(width: 8),
          Text(
            widget.lang == 'cn' ? '聊天' : 'Chat',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(
    ChatMessage message,
    int index,
    bool showReasoning,
  ) {
    final isAi = !message.isUser;
    final displayText = showReasoning && message.reasoning.isNotEmpty
        ? message.reasoning
        : message.content;
    final bubbleColor = isAi
        ? (showReasoning ? const Color.fromRGBO(0, 122, 255, 0.8) : const Color(0xFF90EE90))
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isAi) ...[
            _buildUserAvatar(),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 15,
                  color: isAi ? Colors.black87 : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isAi) ...[
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showReasoning[index] = !(_showReasoning[index] ?? false);
                });
              },
              child: _buildAiAvatar(showReasoning),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFFE4E9),
        ),
        child: const Center(
          child: Icon(
            Icons.person,
            size: 28,
            color: Color(0xFFFF69B4),
          ),
        ),
      ),
    );
  }

  Widget _buildAiAvatar(bool showReasoning) {
    return SizedBox(
      width: 48,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFFFE4E9),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            getAiAvatarAsset(showReasoning),
            fit: BoxFit.cover,
            width: 48,
            height: 64,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFFFE4E9),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Color(0xFFFF69B4),
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFFFE4E9),
      ),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.lang == 'cn' ? '输入消息...' : 'Type a message...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _isLoading
              ? const CircularProgressIndicator()
              : IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFFF69B4), size: 28),
                  onPressed: _sendMessage,
                ),
        ],
      ),
    );
  }
}
