import 'package:flutter/material.dart';

class AIReplyBar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const AIReplyBar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AIReplyBar> createState() => _AIReplyBarState();
}

class _AIReplyBarState extends State<AIReplyBar> {
  double _dragStartY = 0;

  void _onPanStart(DragStartDetails details) {
    _dragStartY = details.globalPosition.dy;
  }

  void _onPanEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy < -100) {
      widget.onToggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanEnd: _onPanEnd,
      onTap: widget.onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: widget.isExpanded ? 200 : 100,
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '语文助手',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.expand_more,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF90EE90),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '你好，我是你的语文学习助手，让我帮你进行语文学习规划。',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFFE4E9),
                      ),
                      child: const Center(
                        child: Text(
                          '🐼',
                          style: TextStyle(fontSize: 36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.isExpanded)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: const [
                        SizedBox(height: 8),
                        Divider(color: Color(0xFFE0E0E0)),
                        SizedBox(height: 8),
                        Text(
                          '聊天记录区域...',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}