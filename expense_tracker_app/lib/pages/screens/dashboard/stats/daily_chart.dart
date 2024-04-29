import 'dart:math';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DailyChart extends StatefulWidget {
  const DailyChart({super.key});

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  List<double> dailyExpenses = List.filled(7, 0);
  Map<String, double> documentAmounts =
      {}; // Map to store document names and amounts

  late String documentName; // To store the document name for the bottom label
  Set<DateTime> displayedDays = {}; // Set to keep track of displayed dates

  @override
  void initState() {
    super.initState();
    fetchExpenses();
  }

  void fetchExpenses() async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    for (int i = 0; i < 7; i++) {
      DateTime date = today.subtract(Duration(days: i));
      String day = date.day.toString();
      // Fetch expenses for the day from Firestore and sum them
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('statistics')
          .doc('thecurrent')
          .collection('daily')
          .doc(day)
          .get();

      if (snapshot.exists) {
        double amount = (snapshot.data() as Map<String, dynamic>)['amount'];
        dailyExpenses[i] = amount;
        documentAmounts[day] = amount; // Store document name and amount
      } else {
        dailyExpenses[i] = 0.0;
        documentAmounts[day] = 0.0; // Store 0.0 for missing documents
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      mainBarData(),
    );
  }

  BarChartGroupData makeGroupData(int day, double y) {
    return BarChartGroupData(
      x: day,
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
            toY: dailyExpenses.reduce(math.max), // Max value for background rod
            color: secondaryColor,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        int dayIndex = 6 - i; // Reverse order for top-to-bottom display
        int day = DateTime.now().subtract(Duration(days: dayIndex)).day - 1;
        return makeGroupData(day, dailyExpenses[dayIndex]);
      });

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
              String day = value.toString().padLeft(2, '0');
              return Text(
                documentAmounts.containsKey(day)
                    ? documentAmounts[day]!.toStringAsFixed(2)
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
              int day = value.toInt() + 1; // Adjust for 0-based indexing
              return Text(day.toString().padLeft(2, '0')); // Display day number
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
