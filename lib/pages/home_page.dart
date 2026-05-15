import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../services/llm_service.dart';
import '../components/chat_bubble_list.dart';
import '../components/dashboard_cards.dart';
import '../components/function_buttons.dart';
import '../components/date_header.dart';
import 'practice_page.dart';
import 'homework_page.dart';
import 'diagnosis_page.dart';
import 'courseware_page.dart';
import 'question_bank_page.dart';
import 'group_learning_page.dart';
import 'knowledge_page.dart';
import 'student_management_page.dart';
import 'device_overview_page.dart';

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
      final userMessage = ChatMessage(sender: '用户', text: text, isAI: false);
      widget.onMessageAdded?.call(userMessage);

      final response = await _llmService.generateResponse(text);
      final aiMessage = ChatMessage(
        sender: 'AI',
        text: response['response'] ?? '收到你的消息！',
        reasoningText: response['reasoning'] ?? '这是AI推理内容。',
        isAI: true,
      );
      widget.onMessageAdded?.call(aiMessage);
      widget.onAiMessageChanged?.call(aiMessage.text);
      _textController.clear();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleFunctionTap(int index) {
    final pages = [
      const DiagnosisPage(),
      const HomeworkPage(),
      const PracticePage(),
      const KnowledgePage(),
      const StudentManagementPage(),
      const QuestionBankPage(),
      const CoursewarePage(),
      const GroupLearningPage(),
      const DeviceOverviewPage(),
    ];

    if (index < pages.length) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pages[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const homeTabs = ['收件箱', '错误本', '知识点', '习题集', '作品集', '技能库'];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表'),
            AIReplyBar(
              lastAiMessage: widget.lastAiMessage,
              onPullDown: widget.onExpandChat,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  children: [
                    const DateHeader(),
                    const SizedBox(height: 4),
                    DashboardCards(
                      onDeviceOnlineTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DeviceOverviewPage(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    FunctionButtons(onItemTap: _handleFunctionTap),
                  ],
                ),
              ),
            ),
            SubmenuTabs(
              tabs: const [],
              selectedTab: '',
              onTabSelected: (tab) {},
              onHomeTap: widget.onHomeTap,
            ),
            InputArea(controller: _textController, onSend: _handleSend),
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
