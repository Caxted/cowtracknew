import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CattleCardWidget extends StatelessWidget {
  final Map<String, dynamic> cattle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onHealthRecords;
  final VoidCallback? onMilkLog;
  final VoidCallback? onDelete;
  final VoidCallback? onSetReminder;
  final VoidCallback? onViewProfile;
  final VoidCallback? onShareDetails;

  const CattleCardWidget({
    super.key,
    required this.cattle,
    this.onTap,
    this.onEdit,
    this.onHealthRecords,
    this.onMilkLog,
    this.onDelete,
    this.onSetReminder,
    this.onViewProfile,
    this.onShareDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(cattle['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              icon: Icons.edit,
              label: 'Edit',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onHealthRecords?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onTertiary,
              icon: Icons.medical_services,
              label: 'Health',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onMilkLog?.call(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.water_drop,
              label: 'Milk Log',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => _showDeleteConfirmation(context),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Cow Photo
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.dividerColor,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: CustomImageWidget(
                        imageUrl: cattle['photo'] as String,
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Cattle Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name and Health Status Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                cattle['name'] as String,
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildHealthStatusBadge(
                                cattle['healthStatus'] as String),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Age and Breed Row
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'cake',
                              size: 16,
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${cattle['age']} years',
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(width: 4.w),
                            CustomIconWidget(
                              iconName: 'pets',
                              size: 16,
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                            SizedBox(width: 1.w),
                            Expanded(
                              child: Text(
                                cattle['breed'] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Last Milk Production
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'water_drop',
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Last: ${cattle['lastMilkAmount']}L',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '(${cattle['lastMilkDate']})',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  CustomIconWidget(
                    iconName: 'chevron_right',
                    size: 20,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusBadge(String status) {
    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'healthy':
        badgeColor = AppTheme.lightTheme.colorScheme.tertiary;
        textColor = AppTheme.lightTheme.colorScheme.onTertiary;
        break;
      case 'sick':
        badgeColor = AppTheme.lightTheme.colorScheme.error;
        textColor = AppTheme.lightTheme.colorScheme.onError;
        break;
      case 'treatment':
        badgeColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'pregnant':
        badgeColor = Colors.purple;
        textColor = Colors.white;
        break;
      default:
        badgeColor = AppTheme.lightTheme.colorScheme.surface;
        textColor = AppTheme.lightTheme.colorScheme.onSurface;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete ${cattle['name']}?',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this cattle record? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              cattle['name'] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'alarm',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: const Text('Set Reminder'),
              onTap: () {
                Navigator.pop(context);
                onSetReminder?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                onViewProfile?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                size: 24,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              title: const Text('Share Details'),
              onTap: () {
                Navigator.pop(context);
                onShareDetails?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
