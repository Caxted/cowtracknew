import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/cattle.dart';

class CattleCardWidget extends StatelessWidget {
  final Cattle cattle;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CattleCardWidget({
    super.key,
    required this.cattle,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(cattle.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  /// PHOTO
                  Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: cattle.photoUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cattle.photoUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.pets, size: 40),
                  ),

                  SizedBox(width: 4.w),

                  /// DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cattle.name,
                          style: AppTheme.lightTheme.textTheme.titleMedium,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Breed: ${cattle.breed}',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Last Milk: ${cattle.lastMilk.toStringAsFixed(1)} L',
                          style: AppTheme.lightTheme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
