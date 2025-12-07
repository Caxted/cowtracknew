// lib/presentation/cattle/widgets/metric_charts.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

// Use package import so Dart can always resolve it correctly.
// If your package name is not `cowtrack`, replace `cowtrack` with the name from pubspec.yaml (the `name:` field).
import 'package:cowtrack/models/daily_metric.dart';

class MetricCharts extends StatelessWidget {
  final List<DailyMetric> metrics;
  const MetricCharts({Key? key, required this.metrics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const Center(child: Text('No metrics yet'));
    }
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildTempChart(context),
        const SizedBox(height: 12),
        _buildStepsChart(context),
        const SizedBox(height: 12),
        _buildMilkChart(context),
      ],
    );
  }

  Widget _buildTempChart(BuildContext context) {
    // Convert safe: metrics is non-empty here
    final spots = <FlSpot>[];
    for (var i = 0; i < metrics.length; i++) {
      final val = metrics[i].temperatureAvg;
      spots.add(FlSpot(i.toDouble(), val));
    }

    // safe min/max because metrics is not empty
    final minY = metrics.map((m) => m.temperatureMin).reduce((a, b) => a < b ? a : b) - 1;
    final maxY = metrics.map((m) => m.temperatureMax).reduce((a, b) => a > b ? a : b) + 1;

    final theme = Theme.of(context);

    return SizedBox(
      height: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Temperature (°C)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        dotData: FlDotData(show: false),
                        barWidth: 2,
                      )
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) {
                            final idx = v.toInt();
                            if (idx < 0 || idx >= metrics.length) return const SizedBox();
                            final d = metrics[idx].date;
                            DateTime parsed;
                            try {
                              parsed = DateTime.parse(d);
                            } catch (_) {
                              parsed = DateTime.now();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                DateFormat.Md().format(parsed),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                          reservedSize: 36,
                        ),
                      ),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepsChart(BuildContext context) {
    final bars = metrics.asMap().entries.map((e) {
      final idx = e.key;
      final m = e.value;
      return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: m.steps.toDouble(), width: 10)]);
    }).toList();

    return SizedBox(
      height: 160,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Text('Steps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(BarChartData(
                barGroups: bars,
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
              )),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMilkChart(BuildContext context) {
    final bars = metrics.asMap().entries.map((e) {
      final idx = e.key;
      final m = e.value;
      return BarChartGroupData(x: idx, barRods: [BarChartRodData(toY: m.milk.toDouble(), width: 10)]);
    }).toList();

    return SizedBox(
      height: 140,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Text('Milk (L)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: BarChart(BarChartData(
                barGroups: bars,
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
              )),
            ),
          ]),
        ),
      ),
    );
  }
}
