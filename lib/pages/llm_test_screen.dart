
import 'package:flutter/material.dart';
import '../services/app_service.dart';

class LlmTestScreen extends StatefulWidget {
  final String lang;
  final VoidCallback onBack;

  const LlmTestScreen({
    super.key,
    this.lang = 'cn',
    required this.onBack,
  });

  @override
  State<LlmTestScreen> createState() => _LlmTestScreenState();
}

class _LlmTestScreenState extends State<LlmTestScreen> {
  final TextEditingController _controller = TextEditingController();
  String _testResult = '';
  bool _isLoading = false;
  String _toolResult = '';
  bool _toolLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final result = await AppService().testLlmConnection();
      setState(() {
        _testResult = '✅ 连接成功!\n\n'
            'Response: ${result['response']}\n\n'
            'Reasoning: ${result['reasoning']}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ 连接失败!\n\nError: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testToolCall() async {
    setState(() {
      _toolLoading = true;
      _toolResult = '';
    });

    try {
      final prompt = _controller.text.trim();
      if (prompt.isEmpty) {
        setState(() {
          _toolResult = '请输入测试prompt';
          _toolLoading = false;
        });
        return;
      }

      final result = await AppService().testToolCall(prompt);
      
      setState(() {
        _toolResult = '✅ Tool Call 测试结果!\n\n'
            'Success: ${result['success']}\n\n'
            'Response: ${result['response']}\n\n'
            'Reasoning: ${result['reasoning']}\n\n'
            'Need Tool Call: ${result['need_tool_call']}\n\n'
            'Tool Call: ${result['tool_call']}';
      });
    } catch (e) {
      setState(() {
        _toolResult = '❌ Tool Call 失败!\n\nError: $e';
      });
    } finally {
      setState(() {
        _toolLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(widget.lang == 'cn' ? 'LLM测试' : 'LLM Test'),
        backgroundColor: const Color(0xFFFF69B4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildConnectionTest(),
            const SizedBox(height: 24),
            _buildToolCallTest(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionTest() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lang == 'cn' ? '1. 基础连接测试' : '1. Basic Connection Test',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF69B4),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.lang == 'cn' ? '测试连接' : 'Test Connection'),
            ),
            const SizedBox(height: 12),
            if (_testResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResult,
                    style: const TextStyle(fontFamily: 'Monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCallTest() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lang == 'cn' ? '2. Function Tool 测试' : '2. Function Tool Test',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.lang == 'cn' 
                    ? '输入测试prompt（如：北京天气怎么样？或：2+2等于几？）' 
                    : 'Enter test prompt (e.g., What is the weather in Beijing? or What is 2+2?)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _toolLoading ? null : _testToolCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: _toolLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.lang == 'cn' ? '测试Tool调用' : 'Test Tool Call'),
            ),
            const SizedBox(height: 12),
            if (_toolResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _toolResult,
                    style: const TextStyle(fontFamily: 'Monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
