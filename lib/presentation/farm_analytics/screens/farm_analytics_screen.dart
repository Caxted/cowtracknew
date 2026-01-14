import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class FarmAnalyticsScreen extends StatefulWidget {
  const FarmAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<FarmAnalyticsScreen> createState() => _FarmAnalyticsScreenState();
}

class _FarmAnalyticsScreenState extends State<FarmAnalyticsScreen> {
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 6)),
      end: now,
    );
  }

  Future<List<QueryDocumentSnapshot>> fetchLogs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_dateRange!.start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_dateRange!.end))
        .get();
    return snapshot.docs;
  }

  Map<String, double> groupByCow(List<QueryDocumentSnapshot> docs) {
    final cowMap = <String, double>{};
    for (var doc in docs) {
      final cow = doc['cowId'];
      final qty = (doc['quantity'] as num).toDouble();
      cowMap[cow] = (cowMap[cow] ?? 0) + qty;
    }
    return cowMap;
  }

  Map<String, double> groupByDate(List<QueryDocumentSnapshot> docs) {
    final dateMap = <String, double>{};
    for (var doc in docs) {
      final date = (doc['date'] as Timestamp).toDate();
      final formatted = DateFormat('MM/dd').format(date);
      final qty = (doc['quantity'] as num).toDouble();
      dateMap[formatted] = (dateMap[formatted] ?? 0) + qty;
    }
    return dateMap;
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Milk Analytics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateFormat.yMMMd().format(_dateRange!.start)} - ${DateFormat.yMMMd().format(_dateRange!.end)}',
                  style: const TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: pickDateRange,
                  child: const Text('Change Range'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: fetchLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No logs found'));
                }

                final dateTotals = groupByDate(docs);
                final cowTotals = groupByCow(docs);

                final sortedCows = cowTotals.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final topCow = sortedCows.first;
                final bottomCow = sortedCows.last;

                final spots = dateTotals.entries.toList().asMap().entries.map((e) {
                  return FlSpot(e.key.toDouble(), e.value.value);
                }).toList();

                final labels = dateTotals.keys.toList();

                final totalProduction = cowTotals.values.fold(0.0, (a, b) => a + b);
                final averagePerCow = cowTotals.isNotEmpty
                    ? totalProduction / cowTotals.length
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Production: ${totalProduction.toStringAsFixed(1)} L',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Average per Cow: ${averagePerCow.toStringAsFixed(1)} L/day',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Top Cow: ${topCow.key} (${topCow.value.toStringAsFixed(1)} L)'),
                      Text('Lowest Cow: ${bottomCow.key} (${bottomCow.value.toStringAsFixed(1)} L)'),
                      const SizedBox(height: 16),
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                dotData: FlDotData(show: true),
                              )
                            ],
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, _) {
                                    final index = val.toInt();
                                    return index >= 0 && index < labels.length
                                        ? Text(labels[index], style: const TextStyle(fontSize: 10))
                                        : const Text('');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
