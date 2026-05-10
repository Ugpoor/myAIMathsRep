import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'title': '收件箱', 'icon': Icons.inbox, 'color': const Color(0xFF2196F3)},
      {'title': '错误本', 'icon': Icons.error_outline, 'color': const Color(0xFFFF5252)},
      {'title': '知识点', 'icon': Icons.lightbulb_outline, 'color': const Color(0xFFFFC107)},
      {'title': '习题集', 'icon': Icons.book_outlined, 'color': const Color(0xFFFF7043)},
      {'title': '作品集', 'icon': Icons.folder_open, 'color': const Color(0xFF4CAF50)},
      {'title': '技能库', 'icon': Icons.code, 'color': const Color(0xFF9C27B0)},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems.map((item) {
        return _buildMenuItem(
          item['title'] as String,
          item['icon'] as IconData,
          item['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // Handle menu item tap
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}