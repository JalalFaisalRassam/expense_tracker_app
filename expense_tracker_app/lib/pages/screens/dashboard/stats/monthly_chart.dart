import 'dart:math';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthlyChart extends StatefulWidget {
  const MonthlyChart({super.key});

  @override
  State<MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<MonthlyChart> {
  List<double> monthlyExpenses = List.filled(7, 0);
  Map<String, double> documentAmounts =
      {}; // Map to store document names and amounts

  String documentName = ""; // To store the document name for the bottom label
  Set<DateTime> displayedMonths = {}; // Set to keep track of displayed dates

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  void fetchExpenses() async {
    final today = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = subtractMonths(today, 6 - i);
      final month = date.month.toString().padLeft(2, '0');

      // Fetch expenses for the month from Firestore and sum them
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('statistics')
          .doc('thecurrent')
          .collection('monthly')
          .doc(month)
          .get();

      if (snapshot.exists) {
        final amount =
            (snapshot.data() as Map<String, dynamic>)['amount'] ?? 0.0;
        monthlyExpenses[i] = amount;
        documentAmounts[month] = amount;
      } else {
        monthlyExpenses[i] = 0.0;
        documentAmounts[month] = 0.0;
      }
    }

    setState(() {});
  }

  DateTime subtractMonths(DateTime date, int months) {
    return DateTime(date.year, date.month - months, date.day);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: BarChart(
            mainBarData(),
          ),
        );
      },
    );
  }

  BarChartGroupData makeGroupData(int month, double y) {
    return BarChartGroupData(
      x: month,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
            transform: const GradientRotation(pi / 30),
          ),
          width: 15,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: monthlyExpenses
                .reduce(math.max), // Max value for background rod
            color: secondaryColor,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(7, (i) {
      return makeGroupData(i, monthlyExpenses[i]);
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      backgroundColor: fourthColor,
      titlesData: FlTitlesData(
        show: true,
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, titleMeta) {
              String month = value.toString().padLeft(2, '0');
              return Text(
                documentAmounts.containsKey(month)
                    ? documentAmounts[month]!.toStringAsFixed(2)
                    : '0.00',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (value, titleMeta) {
              final monthsAgo = DateTime.now().month - 6 + value.toInt();
              final month = (monthsAgo <= 0 ? monthsAgo + 12 : monthsAgo)
                  .toString()
                  .padLeft(2, '0');
              return Text(month);
            },
          ),
        ),
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 38)),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups: showingGroups(),
    );
  }
}
