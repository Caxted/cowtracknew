import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class CowMilkAnalyticsScreen extends StatefulWidget {
  final String cowId;
  final String cowName;

  const CowMilkAnalyticsScreen({
    Key? key,
    required this.cowId,
    required this.cowName,
  }) : super(key: key);

  @override
  State<CowMilkAnalyticsScreen> createState() => _CowMilkAnalyticsScreenState();
}

class _CowMilkAnalyticsScreenState extends State<CowMilkAnalyticsScreen> {
  int _days = 7;

  Future<List<Map<String, dynamic>>> fetchMilkLogs() async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));
    final snapshot = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('cowId', isEqualTo: widget.cowId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('date')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.cowName} Milk Analytics')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 Days')),
                ButtonSegment(value: 30, label: Text('30 Days')),
                ButtonSegment(value: 180, label: Text('6 Months')),
              ],
              selected: {_days},
              onSelectionChanged: (s) {
                setState(() => _days = s.first);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMilkLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return const Center(child: Text('No milk logs found.'));
                }

                final spots = logs.map((log) {
                  final date = (log['date'] as Timestamp).toDate();
                  return FlSpot(
                    date.millisecondsSinceEpoch.toDouble(),
                    (log['quantity'] as num).toDouble(),
                  );
                }).toList();

                final dateLabels = {
                  for (var log in logs)
                    (log['date'] as Timestamp).toDate().millisecondsSinceEpoch.toDouble():
                    DateFormat.MMMd().format((log['date'] as Timestamp).toDate())
                };

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(show: false),
                        )
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: (spots.length > 1)
                                ? ((spots.last.x - spots.first.x) / 4)
                                : 1,
                            getTitlesWidget: (value, meta) {
                              final label = dateLabels[value];
                              return Text(label ?? '', style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      lineTouchData: LineTouchData(
                        enabled: true,
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.black54,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              final dateStr = dateLabels[spot.x] ?? '';
                              return LineTooltipItem(
                                '$dateStr\n${spot.y.toStringAsFixed(1)} L',
                                const TextStyle(color: Colors.white),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
