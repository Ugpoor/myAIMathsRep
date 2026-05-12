import 'package:flutter/material.dart';

class PullUpControl extends StatelessWidget {
  final VoidCallback onPullUp;

  const PullUpControl({
    super.key,
    required this.onPullUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPullUp,
      child: Container(
        height: 40,
        color: Colors.transparent,
        child: const Center(
          child: Icon(
            Icons.expand_less,
            color: Colors.grey,
            size: 28,
          ),
        ),
      ),
    );
  }
}
