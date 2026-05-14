import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputArea extends StatefulWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final Function(bool)? onVoiceStateChanged;
  final ValueChanged<String>? onTextChanged;

  const InputArea({
    super.key,
    this.controller,
    this.onSend,
    this.onVoiceStateChanged,
    this.onTextChanged,
  });

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  bool _isRecording = false;
  late TextEditingController _localController;

  String get hintText {
    return '你好，我要练习数学';
  }

  @override
  void initState() {
    super.initState();
    _localController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _localController.dispose();
    }
    super.dispose();
  }

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      widget.onSend?.call();
    }
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
      if (event.isMetaPressed || event.isControlPressed) {
        _localController.text += '\n';
      } else {
        if (_localController.text.trim().isNotEmpty) {
          widget.onSend?.call();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: const BoxDecoration(color: Color(0xFFE3F2FD)),
      child: Row(
        children: [
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            height: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/user_logo.png',
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF6BB3FF),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isRecording ? _buildVoiceButton() : _buildTextField(),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            height: 48,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  _isRecording = true;
                });
                widget.onVoiceStateChanged?.call(true);
              },
              onTapUp: (_) {
                setState(() {
                  _isRecording = false;
                });
                widget.onVoiceStateChanged?.call(false);
              },
              onTapCancel: () {
                setState(() {
                  _isRecording = false;
                });
                widget.onVoiceStateChanged?.call(false);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6BB3FF),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(107, 179, 255, 0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _localController,
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.send,
                maxLines: 1,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isCollapsed: false,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                onChanged: widget.onTextChanged,
                onSubmitted: _handleSubmitted,
                onTapOutside: (_) {},
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 122, 255, 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Icon(Icons.graphic_eq, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            '正在录音...',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}