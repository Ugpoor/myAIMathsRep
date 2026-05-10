
import 'package:flutter/material.dart';

class PullUpControl extends StatelessWidget {
  final VoidCallback onPullUp;
  final String label;

  const PullUpControl({
    super.key,
    required this.onPullUp,
    this.label = '收起聊天',
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onPullUp,
      child: Container(
        height: screenHeight * 0.05,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
