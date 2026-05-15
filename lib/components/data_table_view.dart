import 'package:flutter/material.dart';

/// 明细表格视图组件
/// 用于一人一练、作业试卷、学情诊断等页面的数据展示
class DataTableView extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<Widget Function(int)>? rowActions;
  final bool showBorder;
  final Color headerColor;
  final Color evenRowColor;
  final Color oddRowColor;
  final void Function(int)? onRowTap;

  const DataTableView({
    super.key,
    required this.headers,
    required this.rows,
    this.rowActions,
    this.showBorder = true,
    this.headerColor = const Color(0xFF6BB3FF),
    this.evenRowColor = Colors.white,
    this.oddRowColor = const Color(0xFFF5F5F5),
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: showBorder
          ? BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        children: [
          // 表头
          _buildHeader(),
          // 数据行
          ...List.generate(rows.length, (index) => _buildRow(index)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: headers.map((header) {
          return Expanded(
            child: Text(
              header,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRow(int rowIndex) {
    final row = rows[rowIndex];
    final isEven = rowIndex % 2 == 0;

    return GestureDetector(
      onTap: onRowTap != null ? () => onRowTap!(rowIndex) : null,
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: isEven ? evenRowColor : oddRowColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          ...row.map((cell) {
            return Expanded(
              child: Text(
                cell,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          if (rowActions != null && rowActions!.isNotEmpty)
            rowActions![rowIndex](rowIndex),
        ],
      ),
      ),
    );
  }
}
