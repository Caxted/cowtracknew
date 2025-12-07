// lib/presentation/cattle/cattle_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cowtrack/models/daily_metric.dart';
import 'package:cowtrack/services/cattle_service.dart';
import 'widgets/metric_charts.dart';

class CattlePage extends StatefulWidget {
  final String cattleName;
  final String cattleId;

  const CattlePage({Key? key, required this.cattleName, required this.cattleId}) : super(key: key);

  @override
  State<CattlePage> createState() => _CattlePageState();
}

class _CattlePageState extends State<CattlePage> {
  final CattleService _cattleService = CattleService();
  int _selectedMetricRange = 30;

  Future<void> onBeltDataReceived(Map<String, dynamic> payload) async {
    // This is the hook for future BLE data integration.
    final metric = DailyMetric(
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      temperatureAvg: (payload['temperatureAvg'] is num) ? (payload['temperatureAvg'] as num).toDouble() : 0.0,
      temperatureMax: (payload['temperatureMax'] is num) ? (payload['temperatureMax'] as num).toDouble() : 0.0,
      temperatureMin: (payload['temperatureMin'] is num) ? (payload['temperatureMin'] as num).toDouble() : 0.0,
      steps: (payload['steps'] is num) ? (payload['steps'] as num).toInt() : 0,
      milk: (payload['milk'] is num) ? (payload['milk'] as num).toDouble() : 0.0,
      updatedAt: Timestamp.now(),
    );
    await _cattleService.saveDailyMetric(widget.cattleId, metric);
  }

  void _simulateSync() {
    // Simulate receiving data from a BLE device.
    final dummyPayload = {
      'temperatureAvg': 38.5 + (DateTime.now().second % 2 - 0.5),
      'temperatureMax': 39.5,
      'temperatureMin': 37.5,
      'steps': 5000 + DateTime.now().second * 10,
      'milk': 15.5 + (DateTime.now().microsecond % 2 - 0.5),
    };
    onBeltDataReceived(dummyPayload);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulated sync complete!')),
    );
  }
  /// Seed demo metrics for the last [days] days (1..30). Safe for dev only.
  Future<void> seedDemoMetrics(int days) async {
    if (days <= 0 || days > 90) days = 7; // clamp sensible default
    final now = DateTime.now();
    final rnd = DateTime.now().millisecond; // small entropy

    // Collect async operations so we can await them together
    final futures = <Future>[];

    for (int i = 0; i < days; i++) {
      final d = now.subtract(Duration(days: i));
      final dateId = DateFormat('yyyy-MM-dd').format(d);

      // generate demo values with small variations
      final tempAvg = 38.0 + ((i % 3) * 0.3) + ((rnd % 10) / 100);
      final tempMax = tempAvg + 0.6;
      final tempMin = tempAvg - 0.7;
      final steps = 3000 + (i * 200) + (rnd % 500);
      final milk = 10.0 + (i % 4) * 0.5;

      final metric = DailyMetric(
        date: dateId,
        temperatureAvg: tempAvg,
        temperatureMax: tempMax,
        temperatureMin: tempMin,
        steps: steps,
        milk: milk,
        updatedAt: Timestamp.now(),
      );

      // call your service - collect futures
      futures.add(_cattleService.saveDailyMetric(widget.cattleId, metric));
    }

    // await all writes
    await Future.wait(futures);
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
              stream: _cattleService.streamDailyMetrics(widget.cattleId, days: _selectedMetricRange),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final metrics = snapshot.data ?? [];
                return Column(
                  children: [
                    _buildLatestSnapshotCard(metrics.isNotEmpty ? metrics.first : null),
                    MetricCharts(metrics: metrics),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton.small(
              heroTag: 'seedDemo',
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Seed demo data?'),
                    content: const Text('This will create 7 demo daily metrics for testing.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Seed')),
                    ],
                  ),
                );

                if (ok == true) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Seeding demo data...')));

                  await seedDemoMetrics(7);

                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Demo data seeded')));
                  }
                }
              },
              tooltip: 'Seed demo metrics (7 days)',
              child: const Icon(Icons.auto_graph, size: 20),
            ),
          ),

          FloatingActionButton(
            heroTag: 'simulateSync',
            onPressed: _simulateSync,
            tooltip: 'Simulate Belt Sync',
            child: const Icon(Icons.sync),
          ),
        ],
      ),

    );
  }
  Widget _buildMetricRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment<int>(value: 7, label: Text('7 Days')),
          ButtonSegment<int>(value: 14, label: Text('14 Days')),
          ButtonSegment<int>(value: 30, label: Text('30 Days')),
        ],
        selected: {_selectedMetricRange},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() {
            _selectedMetricRange = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildLatestSnapshotCard(DailyMetric? latestMetric) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest Snapshot', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (latestMetric != null)
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricTile('Avg Temp', '${latestMetric.temperatureAvg.toStringAsFixed(1)}°C'),
                  _buildMetricTile('Steps', latestMetric.steps.toString()),
                  _buildMetricTile('Milk', '${latestMetric.milk.toStringAsFixed(1)} L'),
                ],
              )
            else
              const Text('No recent data available.'),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationCard() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vaccination Schedule', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Center(child: Text('Vaccination tracking coming soon!')),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
