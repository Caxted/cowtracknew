import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CowStatsCardWidget extends StatelessWidget {
  final Map<String, dynamic> cowData;

  const CowStatsCardWidget({
    super.key,
    required this.cowData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: 'cake',
                  label: 'Age',
                  value: '${cowData["age"] ?? "N/A"} years',
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.lightTheme.dividerColor,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: 'pets',
                  label: 'Breed',
                  value: cowData["breed"] ?? "Unknown",
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: 'monitor_weight',
                  label: 'Weight',
                  value: '${cowData["weight"] ?? "N/A"} kg',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.lightTheme.dividerColor,
              ),
              Expanded(
                child: _buildHealthStatusItem(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHealthStatusItem() {
    final healthStatus = cowData["healthStatus"] ?? "Unknown";
    final Color statusColor = _getHealthStatusColor(healthStatus);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: _getHealthStatusIcon(healthStatus),
            color: statusColor,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Health',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            healthStatus,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Color _getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
      case 'monitoring':
        return Colors.orange;
      case 'sick':
      case 'treatment':
        return Colors.red;
      case 'recovering':
        return Colors.blue;
      default:
        return AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getHealthStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'excellent':
        return 'favorite';
      case 'good':
        return 'thumb_up';
      case 'fair':
      case 'monitoring':
        return 'visibility';
      case 'sick':
      case 'treatment':
        return 'local_hospital';
      case 'recovering':
        return 'healing';
      default:
        return 'help_outline';
    }
  }
}
