import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MetricCharts extends StatelessWidget {
  final bool isMonthly;
  final bool isBarChart;
  final String cattleId;

  const MetricCharts({
    Key? key,
    required this.isMonthly,
    required this.cattleId,
    this.isBarChart = true, // Default to true (bar chart)
  }) : super(key: key);

  Future<Map<String, double>> fetchMilkData() async {
    final now = DateTime.now();
    final start = isMonthly
        ? DateTime(now.year, now.month - 5, 1)
        : now.subtract(const Duration(days: 6));

    final snapshot = await FirebaseFirestore.instance
        .collection('milk_logs')
        .where('cowId', isEqualTo: cattleId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .orderBy('date')
        .get();

    final Map<String, double> dataMap = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final qty = (data['quantity'] as num).toDouble();
      final label = isMonthly
          ? DateFormat.MMM().format(date)
          : DateFormat.Md().format(date);

      dataMap[label] = (dataMap[label] ?? 0) + qty;
    }
    return dataMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: fetchMilkData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final labels = data.keys.toList();
        final values = data.values.toList();

        if (labels.isEmpty) {
          return const Center(child: Text('No data found.'));
        }

        if (isBarChart) {
          return BarChart(
            BarChartData(
              barGroups: values.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(toY: entry.value, width: 12),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      return index < labels.length
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
          );
        } else {
          return LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: values.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
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
          );
        }
      },
    );
  }
}
