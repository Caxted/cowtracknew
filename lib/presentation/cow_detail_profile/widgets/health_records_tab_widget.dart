import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HealthRecordsTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> healthRecords;

  const HealthRecordsTabWidget({
    super.key,
    required this.healthRecords,
  });

  @override
  Widget build(BuildContext context) {
    if (healthRecords.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Medical History Timeline'),
          SizedBox(height: 2.h),
          _buildHealthTimeline(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  Widget _buildHealthTimeline() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: healthRecords.length,
      itemBuilder: (context, index) {
        final record = healthRecords[index];
        final isLast = index == healthRecords.length - 1;

        return _buildTimelineItem(record, isLast);
      },
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> record, bool isLast) {
    final recordType = record["type"] ?? "treatment";
    final Color typeColor = _getRecordTypeColor(recordType);
    final String typeIcon = _getRecordTypeIcon(recordType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: typeColor,
                    width: 2,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: typeIcon,
                  color: typeColor,
                  size: 20,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: AppTheme.lightTheme.dividerColor,
                ),
            ],
          ),

          SizedBox(width: 4.w),

          // Record content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: typeColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatRecordType(recordType),
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        record["date"] ?? "Unknown date",
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    record["title"] ?? "Medical Record",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (record["description"] != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      record["description"],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                  if (record["veterinarian"] != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Dr. ${record["veterinarian"]}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (record["cost"] != null) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'attach_money',
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '\$${record["cost"]}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (record["nextAppointment"] != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.tertiary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 16,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Next: ${record["nextAppointment"]}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'local_hospital',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Health Records',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Health records and medical history will appear here',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRecordTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Colors.green;
      case 'treatment':
        return Colors.orange;
      case 'checkup':
        return Colors.blue;
      case 'surgery':
        return Colors.red;
      case 'breeding':
        return Colors.purple;
      case 'medication':
        return Colors.teal;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getRecordTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return 'vaccines';
      case 'treatment':
        return 'healing';
      case 'checkup':
        return 'health_and_safety';
      case 'surgery':
        return 'local_hospital';
      case 'breeding':
        return 'favorite';
      case 'medication':
        return 'medication';
      default:
        return 'medical_services';
    }
  }

  String _formatRecordType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}
