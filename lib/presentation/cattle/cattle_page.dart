import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cowtrack/models/daily_metric.dart';
import 'package:cowtrack/services/cattle_service.dart';
import 'widgets/metric_charts.dart';

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
  int _selectedMetricRange = 30;

  /// 🔹 BLE / simulated belt data
  Future<void> onBeltDataReceived(Map<String, dynamic> payload) async {
    final metric = DailyMetric(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      temperatureAvg:
      (payload['temperatureAvg'] as num?)?.toDouble() ?? 0.0,
      temperatureMax:
      (payload['temperatureMax'] as num?)?.toDouble() ?? 0.0,
      temperatureMin:
      (payload['temperatureMin'] as num?)?.toDouble() ?? 0.0,
      steps: (payload['steps'] as num?)?.toInt() ?? 0,
      milk: (payload['milk'] as num?)?.toDouble() ?? 0.0,
      updatedAt: Timestamp.now(),
    );

    await _cattleService.saveDailyMetric(widget.cattleId, metric);
  }

  void _simulateSync() {
    onBeltDataReceived({
      'temperatureAvg': 38.4,
      'temperatureMax': 39.2,
      'temperatureMin': 37.6,
      'steps': 5200,
      'milk': 14.8,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulated sync complete')),
    );
  }

  Future<void> seedDemoMetrics(int days) async {
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final metric = DailyMetric(
        date: DateFormat('yyyy-MM-dd').format(date),
        temperatureAvg: 38.0 + (i % 3) * 0.3,
        temperatureMax: 39.0,
        temperatureMin: 37.4,
        steps: 3000 + (i * 150),
        milk: 10 + (i % 4),
        updatedAt: Timestamp.now(),
      );

      await _cattleService.saveDailyMetric(widget.cattleId, metric);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cattleName)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMetricRangeSelector(),

            StreamBuilder<List<DailyMetric>>(
              stream: _cattleService.streamDailyMetrics(
                widget.cattleId,
                days: _selectedMetricRange,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final metrics = snapshot.data ?? [];

                return Column(
                  children: [
                    _buildLatestSnapshotCard(
                        metrics.isNotEmpty ? metrics.first : null),
                    const SizedBox(height: 16),
                    MetricCharts(
                      cattleId: widget.cattleId,
                      isMonthly: false,
                    ),
                    const SizedBox(height: 24),
                    MetricCharts(
                      cattleId: widget.cattleId,
                      isMonthly: true,
                    ),
                    _buildVaccinationCard(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'seed',
            onPressed: () async {
              await seedDemoMetrics(7);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo metrics seeded')),
                );
              }
            },
            child: const Icon(Icons.auto_graph),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'sync',
            onPressed: _simulateSync,
            child: const Icon(Icons.sync),
          ),
        ],
      ),
    );
  }

  /// ================= UI HELPERS =================

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
