import 'package:flutter/material.dart';

class AIReplyBar extends StatelessWidget {
  final String lastAiMessage;
  final VoidCallback onPullDown;
  final VoidCallback? onAvatarTap;
  final int maxLines;
  final int maxLength;

  const AIReplyBar({
    super.key,
    required this.lastAiMessage,
    required this.onPullDown,
    this.onAvatarTap,
    this.maxLines = 2,
    this.maxLength = 100,
  });

  String get avatarAsset {
    return 'assets/images/ai_maths.png';
  }

  String get truncatedMessage {
    if (lastAiMessage.length <= maxLength) {
      return lastAiMessage;
    }
    return lastAiMessage.substring(0, maxLength) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(128, 128, 128, 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90EE90),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        truncatedMessage,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        maxLines: maxLines,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 60,
                  height: 80,
                  child: GestureDetector(
                    onTap: onAvatarTap,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        avatarAsset,
                        fit: BoxFit.cover,
                        width: 36,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE3F2FD),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: Color(0xFF6BB3FF),
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPullDown,
            child: Container(
              height: 30,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: const Center(
                child: Icon(
                  Icons.expand_more,
                  color: Color(0xFF6BB3FF),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}