import 'package:flutter/material.dart';
import '../database/models/inbox_item.dart';
import '../services/inbox_service.dart';
import '../components/app_title_bar.dart';
import '../components/ai_reply_bar.dart';
import '../components/submenu_tabs.dart';
import '../components/input_area.dart';
import '../components/wysiwyg_editor.dart';

class InboxDetailPage extends StatefulWidget {
  final InboxItem item;
  final VoidCallback onUpdate;

  const InboxDetailPage({
    super.key,
    required this.item,
    required this.onUpdate,
  });

  @override
  State<InboxDetailPage> createState() => _InboxDetailPageState();
}

class _InboxDetailPageState extends State<InboxDetailPage> {
  final InboxService _inboxService = InboxService();
  bool _isLoading = false;
  String _currentContent = '';
  bool _hasRepairableState = false;

  final List<String> _categories = [
    '知识点',
    '错题本',
    '习题',
    '作品集',
    '未知归类',
  ];

  final List<String> _statuses = ['未处理', '已处理'];

  late String _selectedCategory;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _currentContent = widget.item.content;
    _selectedCategory = widget.item.category;
    _selectedStatus = widget.item.status;
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedItem = widget.item.copyWith(
        content: _currentContent,
        category: _selectedCategory,
        status: _selectedStatus,
      );

      await _inboxService.updateInboxItem(updatedItem);

      if (mounted) {
        widget.onUpdate();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _inboxService.deleteInboxItem(widget.item.id!);
        if (mounted) {
          widget.onUpdate();
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除失败')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            AppTitleBar(
              title: '我的数学课代表-收件箱条目编辑',
            ),
            AIReplyBar(
              lastAiMessage: '你好，我来帮你编辑这条记录。',
              onPullDown: () {},
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '来源',
                                          style: TextStyle(color: Color(0xFF6BB3FF), fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE3F2FD),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: Text(widget.item.source, style: const TextStyle(fontSize: 12)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '归类',
                                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 4),
                                        DropdownButton<String>(
                                          value: _selectedCategory,
                                          items: _categories
                                              .map((cat) => DropdownMenuItem(
                                                    value: cat,
                                                    child: Text(cat),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedCategory = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: WysiwygEditor(
                              initialContent: widget.item.content,
                              onContentChanged: (content) {
                                setState(() {
                                  _currentContent = content;
                                  _hasRepairableState = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SubmenuTabs(
              tabs: const ['取消', '保存', '删除'],
              selectedTab: '保存',
              onTabSelected: (tab) async {
                if (tab == '取消') {
                  Navigator.of(context).pop();
                } else if (tab == '保存') {
                  await _saveChanges();
                } else if (tab == '删除') {
                  await _deleteItem();
                }
              },
              onHomeTap: () => Navigator.of(context).pop(),
            ),
            InputArea(
              onTextChanged: (text) {},
            ),
          ],
        ),
      ),
    );
  }
}