import 'package:flutter/material.dart';

/// 筛选条件数据模型
class FilterField {
  final String name;        // 列名（中文）
  final String key;         // 列键
  final bool isNumeric;     // 是否数值类型（显示范围筛选）
  final List<String>? options; // 选项列表（非数值时使用）

  const FilterField({
    required this.name,
    required this.key,
    this.isNumeric = false,
    this.options,
  });
}

/// 筛选结果
class FilterResult {
  final Map<String, String?> selectedValues;   // 选中值 key -> value
  final Map<String, RangeValue?> rangeValues;  // 范围值 key -> (min, max)

  const FilterResult({
    required this.selectedValues,
    required this.rangeValues,
  });

  bool get isEmpty => selectedValues.values.every((v) => v == null) &&
      rangeValues.values.every((v) => v == null);
}

class RangeValue {
  final String? min;
  final String? max;
  const RangeValue({this.min, this.max});
}

/// 通用筛选弹窗组件
/// 用于各功能页面的"根据列筛选"弹窗
class FilterDialog extends StatefulWidget {
  /// 可筛选的列字段定义
  final List<FilterField> fields;

  /// 当前已选中的筛选条件
  final FilterResult? initialResult;

  const FilterDialog({
    super.key,
    required this.fields,
    this.initialResult,
  });

  /// 显示筛选弹窗，返回筛选结果（取消返回null）
  static Future<FilterResult?> show(
    BuildContext context, {
    required List<FilterField> fields,
    FilterResult? initialResult,
  }) {
    return showDialog<FilterResult>(
      context: context,
      builder: (context) => FilterDialog(
        fields: fields,
        initialResult: initialResult,
      ),
    );
  }

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late Map<String, String?> _selectedValues;
  late Map<String, RangeValue?> _rangeValues;
  late Map<String, bool> _expanded;

  @override
  void initState() {
    super.initState();
    _selectedValues = {};
    _rangeValues = {};
    _expanded = {};

    for (final field in widget.fields) {
      _selectedValues[field.key] = widget.initialResult?.selectedValues[field.key];
      _rangeValues[field.key] = widget.initialResult?.rangeValues[field.key];
      _expanded[field.key] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF6BB3FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('筛选条件',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // 筛选项列表
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.fields.map((field) => _buildFieldItem(field)).toList(),
                ),
              ),
            ),

            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('重置', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, FilterResult(
                          selectedValues: Map.from(_selectedValues),
                          rangeValues: Map.from(_rangeValues),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6BB3FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('应用筛选'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldItem(FilterField field) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // 字段标题行（可展开/收起）
          GestureDetector(
            onTap: () => setState(() => _expanded[field.key] = !_expanded[field.key]!),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(field.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (_hasActiveFilter(field))
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('●', style: TextStyle(fontSize: 8, color: Colors.red.shade700)),
                        ),
                    ],
                  ),
                  Icon(
                    _expanded[field.key]! ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.grey,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // 展开的筛选内容
          if (_expanded[field.key]!)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: field.isNumeric
                  ? _buildRangeInput(field)
                  : _buildOptionsChips(field),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsChips(FilterField field) {
    final options = field.options ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedValues[field.key] == option;
        return ChoiceChip(
          label: Text(option, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          selectedColor: const Color(0xFF6BB3FF),
          backgroundColor: Colors.grey.shade100,
          onSelected: (selected) {
            setState(() {
              _selectedValues[field.key] = selected ? option : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRangeInput(FilterField field) {
    final range = _rangeValues[field.key];
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: range?.min ?? ''),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '最小值',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              final current = _rangeValues[field.key];
              _rangeValues[field.key] = RangeValue(min: value.isEmpty ? null : value, max: current?.max);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('~', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: range?.max ?? ''),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '最大值',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              final current = _rangeValues[field.key];
              _rangeValues[field.key] = RangeValue(min: current?.min, max: value.isEmpty ? null : value);
            },
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilter(FilterField field) {
    if (field.isNumeric) {
      final r = _rangeValues[field.key];
      return r != null && (r.min != null || r.max != null);
    } else {
      return _selectedValues[field.key] != null;
    }
  }
}
