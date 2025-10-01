import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String iconName;
  final Color? backgroundColor;
  final Color? valueColor;
  final String? subtitle;
  final bool isUrgent;

  const StatsCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.iconName,
    this.backgroundColor,
    this.valueColor,
    this.subtitle,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isUrgent
            ? Border.all(
          color: AppTheme.getAccentColor(!isDark),
          width: 1.5,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color:
                  (valueColor ?? theme.primaryColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: valueColor ?? theme.primaryColor,
                    size: 4.w,
                  ),
                ),
              ),
              const Spacer(),
              if (isUrgent)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.getAccentColor(!isDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'URGENT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 7.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 0.5.h),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
