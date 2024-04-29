import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/dashboard/stats/daily_chart.dart';
import 'package:expense_tracker/pages/screens/dashboard/stats/monthly_chart.dart';
import 'package:expense_tracker/pages/screens/dashboard/stats/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Charts extends StatefulWidget {
  const Charts({super.key});

  @override
  State<Charts> createState() => _ChartsState();
}

class _ChartsState extends State<Charts> {
  int isSelected = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProductCategory(
                    index: 0, name: AppLocalizations.of(context)!.daily),
                _buildProductCategory(
                    index: 1, name: AppLocalizations.of(context)!.monthly),
                _buildProductCategory(
                    index: 2, name: AppLocalizations.of(context)!.categories),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: isSelected == 0
                ? DailyChart()
                : isSelected == 1
                    ? MonthlyChart()
                    : pieChart(),
          )
        ],
      ),
    );
  }

  Widget _buildProductCategory({required int index, required String name}) {
    return GestureDetector(
      onTap: () => setState(() => isSelected = index),
      child: Container(
        width: 100,
        height: 40,
        margin: const EdgeInsets.only(top: 10, right: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected == index ? primaryColor : externalColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
