import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MetricCharts extends StatelessWidget {
  final bool isMonthly;
  final String cattleId;

  const MetricCharts({
    super.key,
    required this.isMonthly,
    required this.cattleId,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not logged in'));
    }

    final now = DateTime.now();
    final startDate = isMonthly
        ? DateTime(now.year, now.month - 5, 1)
        : DateTime(now.year, now.month, now.day - 6);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('milk_logs')
          .where('ownerId', isEqualTo: user.uid)
          .where('cattleId', isEqualTo: cattleId)
          .where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No milk data available'));
        }

        final Map<String, double> groupedData = {};

        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final date = (data['date'] as Timestamp).toDate();
          final qty = (data['quantity'] as num).toDouble();

          final key = isMonthly
              ? DateFormat('MMM').format(date)
              : DateFormat('EEE').format(date);

          groupedData[key] = (groupedData[key] ?? 0) + qty;
        }

        final List<FlSpot> spots = [];
        int index = 0;

        for (final value in groupedData.values) {
          spots.add(FlSpot(index.toDouble(), value));
          index++;
        }

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: true),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        );
      },
    );
  }
}
