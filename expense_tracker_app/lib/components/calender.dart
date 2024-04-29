import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants.dart';

class MyFormCalendar extends StatefulWidget {
  late final String labelText;

  final TextEditingController controller;

  MyFormCalendar({
    required this.labelText,
    required this.controller,
  });

  @override
  _MyFormCalendarState createState() => _MyFormCalendarState();
}

class _MyFormCalendarState extends State<MyFormCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    widget.controller.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TextFormField(
            controller: widget.controller, // Add this line

            style: TextStyle(fontSize: 12),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade400)),
              hintText: widget.labelText,

              filled: true,
              prefixIcon: GestureDetector(
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());

                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      widget.controller.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                child: Icon(Icons.calendar_today),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(primaryRadius),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 1.0, horizontal: 12.0),

              // icon: Icon(Icons.calendar_today),
            ),
          ),
        ],
      ),
    );
  }
}
