
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum TextFormat {
  normal,
  h1,
  h2,
  h3,
  bold,
  italic,
  underline,
}

class RichMediaEditor extends StatefulWidget {
  final String? initialContent;
  final ValueChanged<String>? onContentChanged;
  final String lang;

  const RichMediaEditor({
    super.key,
    this.initialContent,
    this.onContentChanged,
    this.lang = 'cn',
  });

  @override
  State<RichMediaEditor> createState() => _RichMediaEditorState();
}

class _RichMediaEditorState extends State<RichMediaEditor> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialContent != null) {
      _controller.text = widget.initialContent!;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onContentChanged?.call(_controller.text);
  }

  void _insertFormat(TextFormat format) {
    final text = _controller.text;
    final selection = _controller.selection;
    final selectedText = selection.textInside(text);

    String prefix, suffix;
    switch (format) {
      case TextFormat.h1:
        prefix = '# ';
        suffix = '';
        break;
      case TextFormat.h2:
        prefix = '## ';
        suffix = '';
        break;
      case TextFormat.h3:
        prefix = '### ';
        suffix = '';
        break;
      case TextFormat.bold:
        prefix = '**';
        suffix = '**';
        break;
      case TextFormat.italic:
        prefix = '*';
        suffix = '*';
        break;
      case TextFormat.underline:
        prefix = '__';
        suffix = '__';
        break;
      default:
        return;
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '$prefix$selectedText$suffix',
    );

    _controller.text = newText;
    
    final newPosition = selection.start + prefix.length + selectedText.length + suffix.length;
    _controller.selection = TextSelection.collapsed(offset: newPosition);
    
    _focusNode.requestFocus();
  }

  Future<void> _insertImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final imagePath = pickedFile.path;
      final selection = _controller.selection;
      final imageMarkdown = '\n![image]($imagePath)\n';
      
      final newText = _controller.text.replaceRange(
        selection.start,
        selection.end,
        imageMarkdown,
      );
      
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: selection.start + imageMarkdown.length);
      _focusNode.requestFocus();
    }
  }

  Future<void> _insertVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final videoPath = pickedFile.path;
      final selection = _controller.selection;
      final videoMarkdown = '\n📹 Video: $videoPath\n';
      
      final newText = _controller.text.replaceRange(
        selection.start,
        selection.end,
        videoMarkdown,
      );
      
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: selection.start + videoMarkdown.length);
      _focusNode.requestFocus();
    }
  }

  Future<void> _insertAudio() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final audioPath = pickedFile.path;
      final selection = _controller.selection;
      final audioMarkdown = '\n🎙️ Audio: $audioPath\n';
      
      final newText = _controller.text.replaceRange(
        selection.start,
        selection.end,
        audioMarkdown,
      );
      
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(offset: selection.start + audioMarkdown.length);
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.lang == 'cn' 
                    ? '开始编辑内容...' 
                    : 'Start editing...',
                hintStyle: const TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFormatButton(Icons.title, TextFormat.h1, 'H1'),
            _buildFormatButton(Icons.title_outlined, TextFormat.h2, 'H2'),
            _buildFormatButton(Icons.subtitles, TextFormat.h3, 'H3'),
            const SizedBox(width: 8),
            _buildFormatButton(Icons.format_bold, TextFormat.bold, 'B'),
            _buildFormatButton(Icons.format_italic, TextFormat.italic, 'I'),
            _buildFormatButton(Icons.format_underline, TextFormat.underline, 'U'),
            const SizedBox(width: 8),
            const VerticalDivider(width: 1),
            const SizedBox(width: 8),
            _buildMediaButton(Icons.image, _insertImage),
            _buildMediaButton(Icons.video_library, _insertVideo),
            _buildMediaButton(Icons.mic, _insertAudio),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton(IconData icon, TextFormat format, String label) {
    return IconButton(
      onPressed: () => _insertFormat(format),
      icon: Icon(icon),
      tooltip: label,
    );
  }

  Widget _buildMediaButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
