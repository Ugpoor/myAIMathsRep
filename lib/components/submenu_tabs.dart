import 'package:flutter/material.dart';

class SubmenuTabs extends StatelessWidget {
  final List<String> tabs;
  final String selectedTab;
  final Function(String) onTabSelected;
  final VoidCallback? onHomeTap;

  const SubmenuTabs({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
    this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE3F2FD),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onHomeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(128, 128, 128, 0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.home, color: Color(0xFF6BB3FF), size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.map((tab) {
                  final isSelected = selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => onTabSelected(tab),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6BB3FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color.fromRGBO(
                                      107,
                                      179,
                                      255,
                                      0.3,
                                    ),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: const Color.fromRGBO(
                                      128,
                                      128,
                                      128,
                                      0.2,
                                    ),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                  ),
                                ],
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}