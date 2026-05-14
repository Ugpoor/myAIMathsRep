import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WysiwygEditor extends StatefulWidget {
  final String? initialContent;
  final Function(String)? onContentChanged;
  final String lang;

  const WysiwygEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    this.lang = 'cn',
  });

  @override
  State<WysiwygEditor> createState() => WysiwygEditorState();
}

class WysiwygEditorState extends State<WysiwygEditor> with SingleTickerProviderStateMixin {
  String _content = '';
  String _lastValidContent = '';
  bool _hasError = false;
  late TabController _tabController;
  late WebViewController _webViewController;
  final List<Tab> _tabs = [];

  @override
  void initState() {
    super.initState();
    _content = widget.initialContent ?? '';
    _lastValidContent = _content;
    _tabs.add(const Tab(text: '预览'));
    _tabs.add(const Tab(text: '编辑'));
    _tabController = TabController(length: 2, vsync: this);
    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_buildHtmlContent(_content));
  }

  String _buildHtmlContent(String content) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
      font-size: 16px;
      line-height: 1.6;
      color: #333;
      padding: 16px;
      margin: 0;
    }
    h1 {
      font-size: 24px;
      font-weight: bold;
      margin: 16px 0;
      color: #1a1a1a;
    }
    h2 {
      font-size: 20px;
      font-weight: bold;
      margin: 12px 0;
      color: #2a2a2a;
    }
    h3 {
      font-size: 18px;
      font-weight: bold;
      margin: 10px 0;
      color: #3a3a3a;
    }
    p {
      margin: 10px 0;
    }
    img {
      max-width: 100%;
      height: auto;
      margin: 8px 0;
      border-radius: 4px;
    }
    video {
      max-width: 100%;
      height: auto;
      margin: 8px 0;
      border-radius: 4px;
    }
  </style>
</head>
<body>
  $content
</body>
</html>
''';
  }

  void _onContentChanged(String text) {
    setState(() {
      _content = text;
      _hasError = false;
      _lastValidContent = text;
    });
    _webViewController.loadHtmlString(_buildHtmlContent(text));
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(text);
    }
  }

  void _restoreLastValid() {
    setState(() {
      _content = _lastValidContent;
      _hasError = false;
    });
    _webViewController.loadHtmlString(_buildHtmlContent(_content));
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(_content);
    }
  }

  void _insertHeading(int level) {
    setState(() {
      _content += '<h$level>标题</h$level>';
      _lastValidContent = _content;
    });
    _webViewController.loadHtmlString(_buildHtmlContent(_content));
    if (widget.onContentChanged != null) {
      widget.onContentChanged!(_content);
    }
  }

  Future<void> _insertImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _content += '<img src="${pickedFile.path}">';
        _lastValidContent = _content;
      });
      _webViewController.loadHtmlString(_buildHtmlContent(_content));
      if (widget.onContentChanged != null) {
        widget.onContentChanged!(_content);
      }
    }
  }

  Future<void> _insertVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _content += '<video src="${pickedFile.path}" controls></video>';
        _lastValidContent = _content;
      });
      _webViewController.loadHtmlString(_buildHtmlContent(_content));
      if (widget.onContentChanged != null) {
        widget.onContentChanged!(_content);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_hasError) _buildErrorBar(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPreview(),
              _buildEditor(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: _tabs,
        indicatorColor: const Color(0xFF6BB3FF),
        labelColor: const Color(0xFF6BB3FF),
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  Widget _buildErrorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: Colors.red[100],
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(widget.lang == 'cn' ? '渲染错误，请恢复到上一个正确版本' : 'Render error, please restore to last valid version'),
          const Spacer(),
          TextButton(
            onPressed: _restoreLastValid,
            child: Text(widget.lang == 'cn' ? '恢复' : 'Restore'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          _buildTagButton('H1', () => _insertHeading(1)),
          _buildTagButton('H2', () => _insertHeading(2)),
          _buildTagButton('H3', () => _insertHeading(3)),
          const SizedBox(width: 8),
          _buildTagButton('📷', _insertImage),
          _buildTagButton('🎬', _insertVideo),
        ],
      ),
    );
  }

  Widget _buildTagButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8),
            child: _HtmlEditorView(
              key: ValueKey(_content),
              htmlContent: _content,
              onContentChanged: _onContentChanged,
              lang: widget.lang,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return WebViewWidget(controller: _webViewController);
  }
}

class _HtmlEditorView extends StatefulWidget {
  final String htmlContent;
  final Function(String) onContentChanged;
  final String lang;

  const _HtmlEditorView({
    super.key,
    required this.htmlContent,
    required this.onContentChanged,
    required this.lang,
  });

  @override
  State<_HtmlEditorView> createState() => _HtmlEditorViewState();
}

class _HtmlEditorViewState extends State<_HtmlEditorView> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _focusNodes.values.forEach((node) => node.dispose());
    super.dispose();
  }

  void _updateTagContent(String tagKey, String newText) {
    final parts = tagKey.split('-');
    final tagName = parts[0];
    final index = int.parse(parts[1]);

    String html = widget.htmlContent;
    int count = 0;

    html = html.replaceAllMapped(
      RegExp(r'<(\w+)([^>]*)>(.*?)</\1>', caseSensitive: false, dotAll: true),
      (match) {
        final matchedTagName = match.group(1)?.toLowerCase() ?? '';
        if (matchedTagName == tagName) {
          if (count == index) {
            count++;
            return '<$tagName${match.group(2) ?? ''}>$newText</$tagName>';
          }
          count++;
        }
        return match.group(0) ?? '';
      },
    );

    widget.onContentChanged(html);
  }

  Widget _buildEditableField(String tagKey, String initialText) {
    if (_controllers[tagKey] == null) {
      _controllers[tagKey] = TextEditingController(text: initialText);
      _focusNodes[tagKey] = FocusNode();
    }

    return TextField(
      key: ObjectKey(tagKey),
      controller: _controllers[tagKey],
      focusNode: _focusNodes[tagKey],
      onChanged: (text) => _updateTagContent(tagKey, text),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        isDense