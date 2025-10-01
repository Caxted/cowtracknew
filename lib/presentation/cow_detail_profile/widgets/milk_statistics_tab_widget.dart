import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MilkStatisticsTabWidget extends StatefulWidget {
  final Map<String, dynamic> milkData;

  const MilkStatisticsTabWidget({
    super.key,
    required this.milkData,
  });

  @override
  State<MilkStatisticsTabWidget> createState() =>
      _MilkStatisticsTabWidgetState();
}

class _MilkStatisticsTabWidgetState extends State<MilkStatisticsTabWidget> {
  String _selectedPeriod = 'Weekly';
  final List<String> _periods = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsSummary(),
          SizedBox(height: 3.h),
          _buildChartSection(),
          SizedBox(height: 3.h),
          _buildProductionTrends(),
          SizedBox(height: 3.h),
          _buildMilkingSchedule(),
        ],
      ),
    );
  }

  Widget _buildStatsSummary() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Summary',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Today',
                  '${widget.milkData["todayProduction"] ?? 0} L',
                  'water_drop',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'This Week',
                  '${widget.milkData["weeklyProduction"] ?? 0} L',
                  'calendar_view_week',
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'This Month',
                  '${widget.milkData["monthlyProduction"] ?? 0} L',
                  'calendar_month',
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Average/Day',
                  '${widget.milkData["averageDaily"] ?? 0} L',
                  'trending_up',
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Production Trend',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              _buildPeriodSelector(),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 30.h,
            child: _buildProductionChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = period;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                period,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductionChart() {
    final List<FlSpot> spots = _getChartData();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.lightTheme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    _getBottomTitle(value.toInt()),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              reservedSize: 40,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '${value.toInt()}L',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: 0,
        maxY: 30,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.lightTheme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: AppTheme.lightTheme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '${barSpot.y.toStringAsFixed(1)}L',
                  AppTheme.lightTheme.textTheme.bodySmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getChartData() {
    switch (_selectedPeriod) {
      case 'Daily':
        return [
          const FlSpot(0, 18),
          const FlSpot(1, 20),
          const FlSpot(2, 19),
          const FlSpot(3, 22),
          const FlSpot(4, 21),
          const FlSpot(5, 23),
          const FlSpot(6, 20),
        ];
      case 'Weekly':
        return [
          const FlSpot(0, 140),
          const FlSpot(1, 145),
          const FlSpot(2, 138),
          const FlSpot(3, 152),
          const FlSpot(4, 148),
        ];
      case 'Monthly':
        return [
          const FlSpot(0, 580),
          const FlSpot(1, 620),
          const FlSpot(2, 595),
          const FlSpot(3, 640),
          const FlSpot(4, 615),
          const FlSpot(5, 660),
        ];
      default:
        return [];
    }
  }

  String _getBottomTitle(int value) {
    switch (_selectedPeriod) {
      case 'Daily':
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return value < days.length ? days[value] : '';
      case 'Weekly':
        return 'W${value + 1}';
      case 'Monthly':
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
        return value < months.length ? months[value] : '';
      default:
        return '';
    }
  }

  Widget _buildProductionTrends() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Insights',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            'Peak Production',
            '${widget.milkData["peakProduction"] ?? 25} L',
            'trending_up',
            Colors.green,
            'Highest daily production this month',
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            'Average Quality',
            '${widget.milkData["averageQuality"] ?? 4.2}/5.0',
            'star',
            Colors.orange,
            'Based on fat content and protein levels',
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            'Consistency',
            '${widget.milkData["consistency"] ?? 85}%',
            'check_circle',
            Colors.blue,
            'Production stability over time',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String title, String value, String icon, Color color,
      String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
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
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      value,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilkingSchedule() {
    final List<Map<String, dynamic>> schedule = [
      {"time": "06:00 AM", "amount": "12 L", "status": "completed"},
      {"time": "02:00 PM", "amount": "10 L", "status": "completed"},
      {"time": "08:00 PM", "amount": "8 L", "status": "pending"},
    ];

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Milking Schedule',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          ...schedule.map((item) => _buildScheduleItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> item) {
    final bool isCompleted = item["status"] == "completed";
    final Color statusColor = isCompleted ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: isCompleted ? 'check_circle' : 'schedule',
              color: statusColor,
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["time"],
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Expected: ${item["amount"]}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isCompleted ? 'Completed' : 'Pending',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
