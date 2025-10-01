import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>>? onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  final List<String> _breeds = [
    'All Breeds',
    'Holstein',
    'Jersey',
    'Angus',
    'Hereford',
    'Brahman',
    'Charolais',
    'Simmental',
  ];

  final List<String> _healthStatuses = [
    'All Status',
    'Healthy',
    'Sick',
    'Treatment',
    'Pregnant',
  ];

  final List<String> _ageRanges = [
    'All Ages',
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  final List<String> _milkProductionLevels = [
    'All Levels',
    'High (>20L/day)',
    'Medium (10-20L/day)',
    'Low (<10L/day)',
    'Not Producing',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Cattle',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Options
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breed Filter
                  _buildFilterSection(
                    'Breed',
                    _breeds,
                    _filters['breed'] as String? ?? 'All Breeds',
                    (value) => setState(() => _filters['breed'] = value),
                  ),

                  SizedBox(height: 3.h),

                  // Age Range Filter
                  _buildFilterSection(
                    'Age Range',
                    _ageRanges,
                    _filters['ageRange'] as String? ?? 'All Ages',
                    (value) => setState(() => _filters['ageRange'] = value),
                  ),

                  SizedBox(height: 3.h),

                  // Health Status Filter
                  _buildFilterSection(
                    'Health Status',
                    _healthStatuses,
                    _filters['healthStatus'] as String? ?? 'All Status',
                    (value) => setState(() => _filters['healthStatus'] = value),
                  ),

                  SizedBox(height: 3.h),

                  // Milk Production Level Filter
                  _buildFilterSection(
                    'Milk Production Level',
                    _milkProductionLevels,
                    _filters['milkLevel'] as String? ?? 'All Levels',
                    (value) => setState(() => _filters['milkLevel'] = value),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return FilterChip(
              label: Text(
                option,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              checkmarkColor: AppTheme.lightTheme.colorScheme.onPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters = {
        'breed': 'All Breeds',
        'ageRange': 'All Ages',
        'healthStatus': 'All Status',
        'milkLevel': 'All Levels',
      };
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged?.call(_filters);
    Navigator.pop(context);
  }
}
