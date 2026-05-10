
import 'package:flutter/material.dart';

class ChatMessage {
  final String sender;
  final String text;
  final bool isAI;

  ChatMessage({
    required this.sender,
    required this.text,
    this.isAI = false,
  });
}

class ChatBubbleList extends StatelessWidget {
  final List<ChatMessage> messages;

  const ChatBubbleList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildChatBubble(message);
        },
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: message.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isAI) ...[
            _buildAvatar(isAI: true),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: message.isAI ? const Color(0xFF90EE90) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!message.isAI) ...[
            const SizedBox(width: 12),
            _buildAvatar(isAI: false),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isAI}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          isAI ? '🐼' : '👤',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
