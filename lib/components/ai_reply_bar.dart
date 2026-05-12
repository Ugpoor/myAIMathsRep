
import 'package:flutter/material.dart';

class AIReplyBar extends StatelessWidget {
  final String lang;
  final String lastAiMessage;
  final VoidCallback onPullDown;
  final VoidCallback? onAvatarTap;

  const AIReplyBar({
    super.key,
    this.lang = 'cn',
    required this.lastAiMessage,
    required this.onPullDown,
    this.onAvatarTap,
  });

  String get avatarAsset {
    return lang == 'cn'
        ? 'assets/images/chinese_msg.png'
        : 'assets/images/english_msg.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E9),
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
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF90EE90),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lastAiMessage,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
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
                            color: const Color(0xFFFFE4E9),
                            child: const Icon(
                              Icons.chat_bubble,
                              color: Color(0xFFFF69B4),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: const Center(
                child: Icon(
                  Icons.expand_more,
                  color: Color(0xFFFF69B4),
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
