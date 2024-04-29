import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/components/calender.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> addExpense(BuildContext context,
    {required String categoryId, required VoidCallback updateUI}) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: thirdColor,
        title: Text(AppLocalizations.of(context)!.create_expense),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                hintText: AppLocalizations.of(context)!.name_hint,
                controller: nameController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(
                height: 16,
              ),
              MyTextField(
                hintText: AppLocalizations.of(context)!.amount_hint,
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 16,
              ),
              MyTextField(
                hintText: AppLocalizations.of(context)!.description_hint,
                controller: descriptionController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(
                height: 16,
              ),
              MyFormCalendar(
                labelText: AppLocalizations.of(context)!.date_label,
                controller: dateController,
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Button radius
                  ),
                  minimumSize: Size(double.infinity, 50), // Button width
                ),
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      amountController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      dateController.text.isNotEmpty) {
                    double amount = double.parse(amountController.text);
                    String date = dateController.text;
                    String day = date.split('-')[2]; // Extract day from date
                    String month =
                        date.split('-')[1]; // Extract month from date
                    // ignore: unused_local_variable
                    String year = date.split('-')[0]; // Extract year from date

                    // Add the expense to the 'expenses' collection
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('categories')
                        .doc(categoryId)
                        .collection('expenses')
                        .add({
                      'name': nameController.text,
                      'amount': amount,
                      'description': descriptionController.text,
                      'date': date,
                    });

                    // Update the 'statistics' subcollection
                    // Add the amount to the existing amount for the day, month, and year
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('statistics')
                        .doc('thecurrent')
                        .collection('daily')
                        .doc(day)
                        .set({
                      'amount': FieldValue.increment(amount),
                    }, SetOptions(merge: true));

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('statistics')
                        .doc('thecurrent')
                        .collection('monthly')
                        .doc(month)
                        .set({
                      'amount': FieldValue.increment(amount),
                    }, SetOptions(merge: true));

                    Navigator.of(context).pop();

                    // Your existing code for saving the expense
                    updateUI();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.fill_required_fields,
                      ),
                    ));
                  }
                },
                child: Text(
                  AppLocalizations.of(context)!.save,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
