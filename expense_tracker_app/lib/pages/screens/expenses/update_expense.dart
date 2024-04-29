import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/components/calender.dart';
import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/expenses/expenses.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> updateExpense(BuildContext context,
    {required String categoryId,
    required String expenseId,
    required VoidCallback updateUI}) async {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  // XFile? pickedImage;

  // Fetch existing expense data
  DocumentSnapshot expenseSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('categories')
      .doc(categoryId)
      .collection('expenses')
      .doc(expenseId)
      .get();

  if (expenseSnapshot.exists) {
    Map<String, dynamic> expenseData =
        expenseSnapshot.data() as Map<String, dynamic>;
    nameController.text = expenseData['name'];
    amountController.text = expenseData['amount'].toString();
    descriptionController.text = expenseData['description'];
    dateController.text = expenseData['date'];
    // Set imageUrl directly from expenseData
    // imageUrl = expenseData['image']; // You may need to handle this differently if image needs to be updated
  }

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: thirdColor,
        title: Text(
          AppLocalizations.of(context)!.update_expense,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextField(
                hintText: AppLocalizations.of(context)!.name_hint,
                controller: nameController,
              ),
              const SizedBox(
                height: 16,
              ),
              MyTextField(
                controller: amountController,
                hintText: AppLocalizations.of(context)!.amount_hint,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(
                height: 16,
              ),
              MyTextField(
                controller: descriptionController,
                hintText: AppLocalizations.of(context)!.description_hint,
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
              MyButton(
                onTap: () async {
                  if (nameController.text.isNotEmpty &&
                      amountController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty &&
                      dateController.text.isNotEmpty) {
                    final expense = Expense(
                      id: expenseId, // Use the existing expenseId
                      name: nameController.text,
                      amount: double.parse(amountController.text),
                      description: descriptionController.text,
                      date: dateController.text,
                      // image: imageUrl, // Set imageUrl directly
                    );
                    print('expenseffffffffffffffffffffffffffff');
                    print(expense);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('categories')
                        .doc(categoryId)
                        .collection('expenses')
                        .doc(
                            expenseId) // Update the existing expense instead of adding a new one
                        .set(expense
                            .toMap()); // Use set instead of add for updating

                    Navigator.pop(context);
                    Future.delayed(Duration.zero, () {
                      updateUI();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.fill_required_fields,
                      ),
                    ));
                  }
                },
                buttonText: AppLocalizations.of(context)!.update,
              ),
            ],
          ),
        ),
      );
    },
  );
}
