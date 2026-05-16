
import 'package:flutter/material.dart';

class CollapsibleDateHeader extends StatefulWidget {
  const CollapsibleDateHeader({super.key});

  @override
  State<CollapsibleDateHeader> createState() => _CollapsibleDateHeaderState();
}

class _CollapsibleDateHeaderState extends State<CollapsibleDateHeader> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Text('年级'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Text('六', style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Text('班级'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Text('2', style: TextStyle(fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_drop_down, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('2026年5月10日'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _toggleExpand,
                      child: Text(
                        _isExpanded ? '<<' : '>>',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('今日课表'),
                const Spacer(),
                const Text('第'),
                const Text(
                  '15',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const Text('周'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Row(
                            children: [
                              Text('上午', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Expanded(child: Text('六2')),
                            Expanded(child: Text('六2')),
                          ],
                        ),
                        const Row(
                          children: [
                            Expanded(child: Text('初二1')),
                            Expanded(child: Text('初一2')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Container(
                          color: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: const Row(
                            children: [
                              Text('下午', style: TextStyle(color: Colors.white, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Expanded(child: Text('初一3')),
                            Expanded(child: Text('')),
                          ],
                        ),
                        const Row(
                          children: [
                            Expanded(child: Text('')),
                            Expanded(child: Text('')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}