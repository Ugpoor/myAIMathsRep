import 'package:flutter/material.dart';

class MenuGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final void Function(int)? onItemTap;

  const MenuGrid({
    super.key,
    this.crossAxisCount = 3,
    this.childAspectRatio = 1,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    const menuItems = [
      {'title': '收件箱', 'icon': Icons.inbox, 'color': Color(0xFF2196F3)},
      {'title': '错误本', 'icon': Icons.error_outline, 'color': Color(0xFFFF5252)},
      {'title': '知识点', 'icon': Icons.lightbulb_outline, 'color': Color(0xFFFFC107)},
      {'title': '习题集', 'icon': Icons.book_outlined, 'color': Color(0xFFFF7043)},
      {'title': '作品集', 'icon': Icons.folder_open, 'color': Color(0xFF4CAF50)},
      {'title': '技能库', 'icon': Icons.code, 'color': Color(0xFF9C27B0)},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      padding: const EdgeInsets.all(8),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildMenuItem(
          item['title'] as String,
          item['icon'] as IconData,
          item['color'] as Color,
          index,
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, Color color, int index) {
    return GestureDetector(
      onTap: () => onItemTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(
                (color.red * 255.0).round().clamp(0, 255),
                (color.green * 255.0).round().clamp(0, 255),
                (color.blue * 255.0).round().clamp(0, 255),
                0.3,
              ),
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