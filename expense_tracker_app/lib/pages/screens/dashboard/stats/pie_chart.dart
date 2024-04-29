import 'package:expense_tracker/pages/screens/Categories/categories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class pieChart extends StatefulWidget {
  @override
  _pieChartState createState() => _pieChartState();
}

class _pieChartState extends State<pieChart> {
  List<CategoryData> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // Get current month start and end timestamp
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
        .where('timestamp', isLessThanOrEqualTo: endOfMonth)
        .get();

    double totalAmount = 0;
    List<CategoryData> newData = [];

    // Calculate total amount and prepare data
    snapshot.docs.forEach((doc) {
      final category = Category.fromMap(doc.id, doc.data());
      totalAmount += category.totalAmount;
    });

    // Calculate percentage for each category
    snapshot.docs.forEach((doc) {
      final category = Category.fromMap(doc.id, doc.data());
      final percentage = (category.totalAmount / totalAmount) * 100;
      newData.add(CategoryData.fromMap({
        'category': category.name,
        'percentage': percentage,
        'color': category.color,
        'totalAmount': category.totalAmount,
      }));
    });

    // Check if widget is mounted before updating state
    if (mounted) {
      setState(() {
        data = newData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: data.isNotEmpty
                  ? PieChart(
                      PieChartData(
                        sections: data
                            .map((categoryData) => PieChartSectionData(
                                  value: categoryData.percentage,
                                  title:
                                      '${categoryData.category}: ${categoryData.percentage.toStringAsFixed(2)}%',
                                  color: categoryData.color,
                                  radius: 80,
                                ))
                            .toList(),
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              border: TableBorder.all(),
              children: [
                TableRow(
                  children: [
                    TableCell(
                        child: Text(AppLocalizations.of(context)!.color_hint)),
                    TableCell(
                        child: Text(AppLocalizations.of(context)!.category)),
                    TableCell(
                        child: Text(AppLocalizations.of(context)!.amount_hint)),
                  ],
                ),
                ...data.map((categoryData) {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          color: categoryData.color,
                          height: 20,
                        ),
                      ),
                      TableCell(child: Text(categoryData.category)),
                      TableCell(
                          child: Text(categoryData.totalAmount.toString())),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryData {
  final String category;
  final double percentage;
  final Color color;
  final double totalAmount;

  CategoryData(this.category, this.percentage, this.color, this.totalAmount);

  factory CategoryData.fromMap(Map<String, dynamic> map) {
    return CategoryData(
      map['category'],
      map['percentage'],
      HexColor(map['color']),
      map['totalAmount'],
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor =
        hexColor.toUpperCase().replaceAll("COLOR(0X", "").replaceAll(")", "");
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
