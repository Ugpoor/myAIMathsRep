import 'package:flutter/material.dart';

class FunctionButtons extends StatelessWidget {
  final void Function(int)? onItemTap;

  const FunctionButtons({super.key, this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final functionItems = [
      {
        'title': '学情诊断',
        'icon': Icons.remove_red_eye_outlined,
        'color': const Color(0xFF4CAF50),
      },
      {
        'title': '作业试卷',
        'icon': Icons.file_copy_outlined,
        'color': const Color(0xFF2196F3),
      },
      {
        'title': '一人一练',
        'icon': Icons.person_outline,
        'color': const Color(0xFFFF5722),
      },
      {
        'title': '知识点',
        'icon': Icons.network_check,
        'color': const Color(0xFFFF9800),
      },
      {
        'title': '学籍管理',
        'icon': Icons.school_outlined,
        'color': const Color(0xFF00BCD4),
      },
      {
        'title': '题库',
        'icon': Icons.library_books_outlined,
        'color': const Color(0xFFE65100),
      },
      {
        'title': '课程研发',
        'icon': Icons.book_outlined,
        'color': const Color(0xFF3F51B5),
      },
      {
        'title': '小组导学',
        'icon': Icons.group_work_outlined,
        'color': const Color(0xFFE91E63),
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: functionItems.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildFunctionButton(
          item['title'] as String,
          item['icon'] as IconData,
          item['color'] as Color,
          index,
        );
      }).toList(),
    );
  }

  Widget _buildFunctionButton(
    String title,
    IconData icon,
    Color color,
    int index,
  ) {
    return GestureDetector(
      onTap: () => onItemTap?.call(index),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
