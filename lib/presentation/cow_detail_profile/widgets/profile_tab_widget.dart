import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfileTabWidget extends StatelessWidget {
  final Map<String, dynamic> cowData;

  const ProfileTabWidget({
    super.key,
    required this.cowData,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Basic Information'),
          SizedBox(height: 1.h),
          _buildInfoCard([
            _buildInfoRow('Tag ID', cowData["tagId"] ?? "N/A", 'local_offer'),
            _buildInfoRow('Name', cowData["name"] ?? "Unknown", 'pets'),
            _buildInfoRow('Breed', cowData["breed"] ?? "Unknown", 'category'),
            _buildInfoRow('Gender', cowData["gender"] ?? "Unknown", 'wc'),
            _buildInfoRow(
                'Date of Birth', cowData["dateOfBirth"] ?? "N/A", 'cake'),
            _buildInfoRow(
                'Age', '${cowData["age"] ?? "N/A"} years', 'schedule'),
          ]),
          SizedBox(height: 3.h),
          _buildSectionHeader('Physical Details'),
          SizedBox(height: 1.h),
          _buildInfoCard([
            _buildInfoRow(
                'Weight', '${cowData["weight"] ?? "N/A"} kg', 'monitor_weight'),
            _buildInfoRow(
                'Height', '${cowData["height"] ?? "N/A"} cm', 'height'),
            _buildInfoRow('Color', cowData["color"] ?? "Unknown", 'palette'),
            _buildInfoRow('Markings', cowData["markings"] ?? "None", 'brush'),
          ]),
          SizedBox(height: 3.h),
          _buildSectionHeader('Farm Information'),
          SizedBox(height: 1.h),
          _buildInfoCard([
            _buildInfoRow('Farm ID', cowData["farmId"] ?? "N/A", 'home'),
            _buildInfoRow(
                'Location', cowData["location"] ?? "Unknown", 'location_on'),
            _buildInfoRow(
                'Barn/Section', cowData["barnSection"] ?? "N/A", 'domain'),
            _buildInfoRow('Purchase Date', cowData["purchaseDate"] ?? "N/A",
                'shopping_cart'),
            _buildInfoRow('Purchase Price',
                '\$${cowData["purchasePrice"] ?? "N/A"}', 'attach_money'),
          ]),
          SizedBox(height: 3.h),
          _buildSectionHeader('Breeding Information'),
          SizedBox(height: 1.h),
          _buildInfoCard([
            _buildInfoRow('Breeding Status',
                cowData["breedingStatus"] ?? "Unknown", 'favorite'),
            _buildInfoRow(
                'Last Breeding', cowData["lastBreeding"] ?? "N/A", 'event'),
            _buildInfoRow('Expected Calving',
                cowData["expectedCalving"] ?? "N/A", 'event_available'),
            _buildInfoRow(
                'Total Calves', '${cowData["totalCalves"] ?? 0}', 'child_care'),
            _buildInfoRow('Sire', cowData["sire"] ?? "Unknown", 'male'),
            _buildInfoRow('Dam', cowData["dam"] ?? "Unknown", 'female'),
          ]),
          SizedBox(height: 3.h),
          _buildSectionHeader('Production Information'),
          SizedBox(height: 1.h),
          _buildInfoCard([
            _buildInfoRow('Lactation Number',
                '${cowData["lactationNumber"] ?? 0}', 'numbers'),
            _buildInfoRow(
                'Days in Milk', '${cowData["daysInMilk"] ?? 0}', 'today'),
            _buildInfoRow('Average Daily Milk',
                '${cowData["avgDailyMilk"] ?? 0} L', 'water_drop'),
            _buildInfoRow('Peak Milk Production',
                '${cowData["peakMilkProduction"] ?? 0} L', 'trending_up'),
            _buildInfoRow('Total Lifetime Milk',
                '${cowData["totalLifetimeMilk"] ?? 0} L', 'analytics'),
          ]),
          SizedBox(height: 2.h),
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

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String iconName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
