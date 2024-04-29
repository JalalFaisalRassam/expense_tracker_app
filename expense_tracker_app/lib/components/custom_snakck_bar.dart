import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants.dart';

class CustomSnackBar extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String snackText;
  const CustomSnackBar(
      {Key? key,
      required this.iconData,
      required this.iconColor,
      required this.snackText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: 220,
      decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(primaryRadius)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: iconColor,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            snackText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.amber,
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}
