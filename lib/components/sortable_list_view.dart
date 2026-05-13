
import 'package:flutter/material.dart';

enum SortOrder { ascending, descending }

class SortableColumn<T> {
  final String label;
  final String field;
  final bool sortable;

  SortableColumn({
    required this.label,
    required this.field,
    this.sortable = true,
  });
}

class SortableListView<T> extends StatefulWidget {
  final List<T> items;
  final List<SortableColumn<T>> columns;
  final Widget Function(T item, int index) itemBuilder;
  final Widget Function(T item)? headerBuilder;
  final String Function(T item, String field) fieldExtractor;
  final void Function(T item)? onTap;
  final String lang;

  const SortableListView({
    super.key,
    required this.items,
    required this.columns,
    required this.itemBuilder,
    this.headerBuilder,
    required this.fieldExtractor,
    this.onTap,
    this.lang = 'cn',
  });

  @override
  State<SortableListView<T>> createState() => _SortableListViewState<T>();
}

class _SortableListViewState<T> extends State<SortableListView<T>> {
  String? _sortField;
  SortOrder _sortOrder = SortOrder.ascending;

  void _sort(String field) {
    setState(() {
      if (_sortField == field) {
        _sortOrder = _sortOrder == SortOrder.ascending 
            ? SortOrder.descending 
            : SortOrder.ascending;
      } else {
        _sortField = field;
        _sortOrder = SortOrder.ascending;
      }
    });
  }

  List<T> _getSortedItems() {
    if (_sortField == null) return widget.items;

    final sorted = List<T>.from(widget.items);
    sorted.sort((a, b) {
      final valueA = widget.fieldExtractor(a, _sortField!);
      final valueB = widget.fieldExtractor(b, _sortField!);
      
      int comparison = valueA.compareTo(valueB);
      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _getSortedItems();

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            itemCount: sortedItems.length,
            itemBuilder: (context, index) {
              final item = sortedItems[index];
              return GestureDetector(
                onTap: () => widget.onTap?.call(item),
                child: widget.itemBuilder(item, index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: widget.columns.map((column) {
          return Expanded(
            child: column.sortable
                ? GestureDetector(
                    onTap: () => _sort(column.field),
                    child: Row(
                      children: [
                        Text(
                          column.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildSortIcon(column.field),
                      ],
                    ),
                  )
                : Text(
                    column.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortIcon(String field) {
    if (_sortField != field) {
      return const Icon(Icons.swap_vert, size: 16, color: Colors.grey);
    }
    return Icon(
      _sortOrder == SortOrder.ascending 
          ? Icons.arrow_upward 
          : Icons.arrow_downward,
      size: 16,
      color: Colors.blue,
    );
  }
}
