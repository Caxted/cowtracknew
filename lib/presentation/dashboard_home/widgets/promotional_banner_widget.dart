import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PromotionalBannerWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final String? imageUrl;
  final bool showArrow;

  const PromotionalBannerWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onTap,
    this.backgroundColor,
    this.imageUrl,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 85.w,
        margin: EdgeInsets.only(right: 4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImageWidget(
                  imageUrl: imageUrl!,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 3.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (buttonText != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      buttonText!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showArrow) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'arrow_forward_ios',
                color: theme.primaryColor,
                size: 4.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
