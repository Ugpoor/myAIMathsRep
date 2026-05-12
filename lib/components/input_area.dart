import 'package:flutter/material.dart';

class InputArea extends StatefulWidget {
  final String lang;
  final TextEditingController? controller;
  final VoidCallback? onSend;
  final Function(bool)? onVoiceStateChanged;

  const InputArea({
    super.key,
    this.lang = 'cn',
    this.controller,
    this.onSend,
    this.onVoiceStateChanged,
  });

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  bool _isRecording = false;

  String get hintText {
    return widget.lang == 'cn' ? '你好，我要练习' : 'Hello, I want to practice';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: const BoxDecoration(color: Color(0xFFFFE4E9)),
      child: Row(
        children: [
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            height: 40,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFFF69B4),
              ),
              child: const Icon(Icons.person, color: Colors.white),
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
                  color: const Color(0xFFFF69B4),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(255, 105, 180, 0.3),
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
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: widget.controller,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 122, 255, 0.1),
        borderRadius: BorderRadius.circular(20),
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
          Text(
            widget.lang == 'cn' ? '正在录音...' : 'Recording...',
            style: const TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
