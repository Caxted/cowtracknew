import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

enum InputMode { individual, batch }

class InputModeToggleWidget extends StatelessWidget {
  final InputMode selectedMode;
  final ValueChanged<InputMode> onModeChanged;

  const InputModeToggleWidget({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              context,
              'Individual Cows',
              InputMode.individual,
              Icons.pets_outlined,
            ),
          ),
          Expanded(
            child: _buildToggleButton(
              context,
              'Batch Entry',
              InputMode.batch,
              Icons.format_list_bulleted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    InputMode mode,
    IconData icon,
  ) {
    final isSelected = selectedMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: icon.codePoint.toString(),
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                size: 18,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
