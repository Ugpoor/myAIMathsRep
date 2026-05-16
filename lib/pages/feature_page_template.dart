import 'package:flutter/material.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/collapsible_date_header.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/data_table_view.dart';

/// 功能页面模板
/// 所有功能页面的基础结构
class FeaturePageTemplate extends StatefulWidget {
  final String title;
  final String aiMessage;
  final List<String> headers;
  final List<List<String>> rows;
  final List<String> tabs;
  final Function(String)? onTabSelected;
  final Function(String)? onSendMessage;

  const FeaturePageTemplate({
    super.key,
    required this.title,
    this.aiMessage = '欢迎使用AI数学课代表！',
    required this.headers,
    required this.rows,
    this.tabs = const [],
    this.onTabSelected,
    this.onSendMessage,
  });

  @override
  State<FeaturePageTemplate> createState() => _FeaturePageTemplateState();
}

class _FeaturePageTemplateState extends State<FeaturePageTemplate> {
  final TextEditingController _textController = TextEditingController();
  String _selectedTab = '';

  @override
  void initState() {
    super.initState();
    if (widget.tabs.isNotEmpty) {
      _selectedTab = widget.tabs.first;
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage?.call(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(title: 'AI数学课代表-${widget.title}'),
            AIReplyBar(
              lastAiMessage: widget.aiMessage,
              onPullDown: () {
                // 展开聊天记录
              },
            ),
            const CollapsibleDateHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DataTableView(
                  headers: widget.headers,
                  rows: widget.rows,
                ),
              ),
            ),
            if (widget.tabs.isNotEmpty)
              SubmenuTabs(
                tabs: widget.tabs,
                selectedTab: _selectedTab,
                onTabSelected: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                  widget.onTabSelected?.call(tab);
                },
                onHomeTap: () {
                  Navigator.pop(context);
                },
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
