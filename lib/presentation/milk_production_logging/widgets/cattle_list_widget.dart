import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CattleListWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCowSelected;

  const CattleListWidget({
    super.key,
    required this.onCowSelected,
  });

  @override
  State<CattleListWidget> createState() => _CattleListWidgetState();
}

class _CattleListWidgetState extends State<CattleListWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredCattle = [];

  final List<Map<String, dynamic>> _cattleData = [
    {
      "id": "COW001",
      "name": "Bella",
      "breed": "Holstein",
      "age": 4,
      "image":
          "https://images.pexels.com/photos/422218/pexels-photo-422218.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastProduction": 28.5,
      "averageProduction": 26.8,
      "unit": "L",
      "lastRecorded": "2025-09-11",
      "healthStatus": "Healthy",
    },
    {
      "id": "COW002",
      "name": "Daisy",
      "breed": "Jersey",
      "age": 3,
      "image":
          "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastProduction": 22.3,
      "averageProduction": 21.5,
      "unit": "L",
      "lastRecorded": "2025-09-11",
      "healthStatus": "Healthy",
    },
    {
      "id": "COW003",
      "name": "Luna",
      "breed": "Guernsey",
      "age": 5,
      "image":
          "https://images.pexels.com/photos/1459832/pexels-photo-1459832.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastProduction": 24.7,
      "averageProduction": 23.9,
      "unit": "L",
      "lastRecorded": "2025-09-10",
      "healthStatus": "Monitoring",
    },
    {
      "id": "COW004",
      "name": "Rosie",
      "breed": "Holstein",
      "age": 2,
      "image":
          "https://images.pexels.com/photos/1300355/pexels-photo-1300355.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastProduction": 18.9,
      "averageProduction": 17.2,
      "unit": "L",
      "lastRecorded": "2025-09-11",
      "healthStatus": "Healthy",
    },
    {
      "id": "COW005",
      "name": "Mabel",
      "breed": "Brown Swiss",
      "age": 6,
      "image":
          "https://images.pexels.com/photos/1459832/pexels-photo-1459832.jpeg?auto=compress&cs=tinysrgb&w=400",
      "lastProduction": 31.2,
      "averageProduction": 29.8,
      "unit": "L",
      "lastRecorded": "2025-09-11",
      "healthStatus": "Healthy",
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredCattle = _cattleData;
    _searchController.addListener(_filterCattle);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCattle() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCattle = _cattleData.where((cow) {
        final name = (cow["name"] as String).toLowerCase();
        final id = (cow["id"] as String).toLowerCase();
        final breed = (cow["breed"] as String).toLowerCase();
        return name.contains(query) ||
            id.contains(query) ||
            breed.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        SizedBox(height: 2.h),
        Expanded(
          child: _buildCattleList(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, ID, or breed...',
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _filterCattle();
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 20,
                  ),
                )
              : null,
          filled: true,
          fillColor: AppTheme.lightTheme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCattleList() {
    if (_filteredCattle.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'No cattle found',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search terms',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: _filteredCattle.length,
      itemBuilder: (context, index) {
        final cow = _filteredCattle[index];
        return _buildCowCard(cow);
      },
    );
  }

  Widget _buildCowCard(Map<String, dynamic> cow) {
    final isRecordedToday = cow["lastRecorded"] == "2025-09-12";

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCowSelected(cow),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRecordedToday
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3)
                    : AppTheme.lightTheme.dividerColor.withValues(alpha: 0.2),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.lightTheme.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Cow Image
                Container(
                  width: 15.w,
                  height: 15.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomImageWidget(
                      imageUrl: cow["image"] as String,
                      width: 15.w,
                      height: 15.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Cow Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cow["name"] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isRecordedToday)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Recorded',
                                style: AppTheme.lightTheme.textTheme.labelSmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${cow["id"]} • ${cow["breed"]} • ${cow["age"]} years',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'water_drop',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Last: ${cow["lastProduction"]}${cow["unit"]}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          CustomIconWidget(
                            iconName: 'trending_up',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Avg: ${cow["averageProduction"]}${cow["unit"]}',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 2.w),

                // Arrow Icon
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.4),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
