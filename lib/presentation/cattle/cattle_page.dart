import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cowtrack/models/daily_metric.dart';
import 'package:cowtrack/services/cattle_service.dart';
import 'widgets/metric_charts.dart';

// 👉 Add imports for milk log
import 'package:cowtrack/presentation/milk_log/screens/add_milk_log_screen.dart';
import 'package:cowtrack/presentation/milk_log/screens/cow_milk_analytics_screen.dart';

// ... Your existing imports
import 'package:fl_chart/fl_chart.dart';

class CattlePage extends StatefulWidget {
  final String cattleName;
  final String cattleId;

  const CattlePage({
    Key? key,
    required this.cattleName,
    required this.cattleId,
  }) : super(key: key);

  @override
  State<CattlePage> createState() => _CattlePageState();
}

class _CattlePageState extends State<CattlePage> {
  final CattleService _cattleService = CattleService();
  int _selectedMetricRange = 7;

  DateTimeRange? _customRange;
  bool _isBarChart = true;

  @override
  Widget build(BuildContext context) {
    final startDate = _customRange?.start ?? DateTime.now().subtract(Duration(days: _selectedMetricRange));
    final endDate = _customRange?.end ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(widget.cattleName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildActionButtons(),
            _buildMetricRangeSelector(),
            StreamBuilder<List<DailyMetric>>(
              stream: _cattleService.streamDailyMetrics(
                widget.cattleId,
                days: _selectedMetricRange,
              ),
              builder: (context, snapshot) {
                final metrics = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildLatestSnapshotCard(metrics.isNotEmpty ? metrics.first : null),
                    const SizedBox(height: 16),
                    _buildMilkEntriesList(metrics),
                    const SizedBox(height: 16),
                    _buildAnalyticsSection(metrics),
                    const SizedBox(height: 16),
                    _buildVaccinationCard(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ================= UI SECTIONS =================

  Widget _buildMilkEntriesList(List<DailyMetric> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Milk Entries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...metrics.map((m) => ListTile(
          title: Text("${m.date}"),
          trailing: Text("${m.milk.toStringAsFixed(1)} L"),
        )),
      ],
    );
  }

  Widget _buildAnalyticsSection(List<DailyMetric> metrics) {
    if (metrics.isEmpty) return const SizedBox();

    final spots = metrics.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.milk);
    }).toList();

    final labels = metrics.map((m) => m.date.substring(5)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text("Milk Analytics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text("Pick Date Range"),
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _customRange = picked);
                }
              },
            ),
            IconButton(
              icon: Icon(_isBarChart ? Icons.show_chart : Icons.bar_chart),
              onPressed: () => setState(() => _isBarChart = !_isBarChart),
            ),
          ],
        ),
        SizedBox(
          height: 240,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isBarChart
                ? BarChart(
              BarChartData(
                barGroups: spots.map((e) {
                  return BarChartGroupData(
                    x: e.x.toInt(),
                    barRods: [BarChartRodData(toY: e.y, width: 16)],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        return Text(i >= 0 && i < labels.length ? labels[i] : '');
                      },
                    ),
                  ),
                ),
              ),
            )
                : LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        return Text(i >= 0 && i < labels.length ? labels[i] : '');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ========== Other unchanged widgets ==========

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.local_drink),
            label: const Text('Add Milk Log'),
            onPressed: () {
              // Navigate to add milk screen
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Analytics'),
            onPressed: () {
              // Navigate to full analytics if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 7, label: Text('7 Days')),
          ButtonSegment(value: 14, label: Text('14 Days')),
          ButtonSegment(value: 30, label: Text('30 Days')),
        ],
        selected: {_selectedMetricRange},
        onSelectionChanged: (s) {
          setState(() => _selectedMetricRange = s.first);
        },
      ),
    );
  }

  Widget _buildLatestSnapshotCard(DailyMetric? metric) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: metric == null
            ? const Text('No recent data')
            : GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _metricTile('Avg Temp', '${metric.temperatureAvg}°C'),
            _metricTile('Steps', metric.steps.toString()),
            _metricTile('Milk', '${metric.milk} L'),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationCard() {
    return const Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Vaccination tracking coming soon'),
      ),
    );
  }

  Widget _metricTile(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: const TextStyle(fontSize: 18)),
        Text(label),
      ],
    );
  }
}
