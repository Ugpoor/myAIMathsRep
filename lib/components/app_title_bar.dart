import 'package:flutter/material.dart';

class AppTitleBar extends StatelessWidget {
  final String title;
  final String lang;

  const AppTitleBar({super.key, required this.title, this.lang = 'cn'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF6BB3FF),
        borderRadius: BorderRadius.zero,
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
