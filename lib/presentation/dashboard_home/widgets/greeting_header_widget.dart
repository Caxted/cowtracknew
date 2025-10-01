import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GreetingHeaderWidget extends StatelessWidget {
  final String farmerName;
  final String farmName;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final int notificationCount;

  const GreetingHeaderWidget({
    super.key,
    required this.farmerName,
    required this.farmName,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  farmerName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (farmName.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 3.w,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          farmName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: onNotificationTap,
                    icon: CustomIconWidget(
                      iconName: 'notifications_outlined',
                      color: theme.colorScheme.onSurface,
                      size: 6.w,
                    ),
                    tooltip: 'Notifications',
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(0.5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.getAccentColor(
                              theme.brightness == Brightness.light),
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 4.w,
                          minHeight: 4.w,
                        ),
                        child: Text(
                          notificationCount > 99
                              ? '99+'
                              : notificationCount.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 7.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: onProfileTap,
                icon: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: theme.primaryColor,
                    size: 5.w,
                  ),
                ),
                tooltip: 'Profile',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
