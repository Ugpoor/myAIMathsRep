import 'package:flutter/material.dart';
import '../../components/app_title_bar.dart';
import '../../components/chat_bubble_list.dart';

class ChatBubbleListTest extends StatelessWidget {
  const ChatBubbleListTest({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChatMessage> messages = [
      ChatMessage(
        sender: 'AI',
        text: '你好！我是你的AI语言学习助手，有什么可以帮助你的吗？',
        isAI: true,
      ),
      ChatMessage(
        sender: '用户',
        text: '你好，我想学习中文。',
        isAI: false,
      ),
      ChatMessage(
        sender: 'AI',
        text: '太好了！我们可以从基础的拼音和词汇开始学习。',
        isAI: true,
      ),
      ChatMessage(
        sender: '用户',
        text: '好的，那我们现在就开始吧！',
        isAI: false,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFE4E9),
      body: Column(
        children: [
          const AppTitleBar(title: 'ChatBubbleList 测试'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('📐 基本信息'),
                  _buildInfoItem('名称', 'ChatBubbleList'),
                  _buildInfoItem('功能', '聊天气泡列表'),
                  _buildInfoItem('AI气泡', '左侧，绿色'),
                  _buildInfoItem('用户气泡', '右侧，白色'),
                  const SizedBox(height: 24),
                  _buildSection('🎨 实际效果'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    height: 300,
                    child: ChatBubbleList(messages: messages),
                  ),
                  const SizedBox(height: 24),
                  _buildSection('📝 使用示例'),
                  _buildCodeBlock('''
ChatBubbleList(
  messages: [
    ChatMessage(
      sender: 'AI',
      text: '你好！',
      isAI: true,
    ),
  ],
)
'''),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFFFF69B4),
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.lightGreenAccent,
          fontSize: 13,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
