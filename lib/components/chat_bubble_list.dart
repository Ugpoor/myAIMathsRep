import 'package:flutter/material.dart';

class ChatMessage {
  final String sender;
  final String text;
  final String? reasoningText;
  final bool isAI;

  ChatMessage({
    required this.sender,
    required this.text,
    this.reasoningText,
    this.isAI = false,
  });
}

class ChatBubbleList extends StatefulWidget {
  final List<ChatMessage> messages;

  const ChatBubbleList({
    super.key,
    required this.messages,
  });

  @override
  State<ChatBubbleList> createState() => _ChatBubbleListState();
}

class _ChatBubbleListState extends State<ChatBubbleList> {
  final Map<int, bool> _showReasoning = {};

  String getAiAvatarAsset(bool showReasoning) {
    return showReasoning
        ? 'assets/images/ai_maths_brain.png'
        : 'assets/images/ai_maths.png';
  }

  @override
  Widget build(BuildContext context) {
    final reversedMessages = widget.messages.reversed.toList();
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final originalIndex = widget.messages.length - 1 - index;
        final message = reversedMessages[index];
        final showReasoning = _showReasoning[originalIndex] ?? false;
        return _buildChatBubble(message, originalIndex, showReasoning);
      },
    );
  }

  Widget _buildChatBubble(
    ChatMessage message,
    int originalIndex,
    bool showReasoning,
  ) {
    final isAi = message.isAI;
    final displayText = showReasoning && message.reasoningText != null
        ? message.reasoningText!
        : message.text;
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
                  _showReasoning[originalIndex] = !(_showReasoning[originalIndex] ?? false);
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/user_logo.png',
          fit: BoxFit.cover,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE3F2FD),
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: Color(0xFF6BB3FF),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAiAvatar(bool showReasoning) {
    return SizedBox(
      width: 48,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          getAiAvatarAsset(showReasoning),
          fit: BoxFit.cover,
          width: 48,
          height: 64,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFE3F2FD),
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Color(0xFF6BB3FF),
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }
}