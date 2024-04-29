import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:expense_tracker/components/custom_snakck_bar.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/Categories/categories.dart';
import 'package:expense_tracker/pages/screens/expenses/add_expense.dart';
import 'package:expense_tracker/pages/screens/expenses/expenses.dart';
import 'package:expense_tracker/pages/screens/expenses/update_expense.dart';

class CategoryDetailsPage extends StatefulWidget {
  final Category category;

  const CategoryDetailsPage({required this.category});

  @override
  State<CategoryDetailsPage> createState() => _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends State<CategoryDetailsPage> {
  Color parseColor(String colorString) {
    final hexColor = colorString.split('(0x')[1].split(')')[0];
    return Color(int.parse('0xFF$hexColor'));
  }

  void updateUI() {
    setState(() {});
  }

  Future<List<Expense>> fetchExpenses(String categoryId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(categoryId)
        .collection('expenses')
        .get();

    return querySnapshot.docs
        .map((doc) =>
            Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
  // Future<List<Expense>> fetchExpenses(String categoryId) async {
  //   final userId = FirebaseAuth.instance.currentUser!.uid;
  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(userId)
  //       .collection('categories')
  //       .doc(categoryId)
  //       .collection('expenses')
  //       .get();

  //   return querySnapshot.docs
  //       .map((doc) =>
  //           Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
  //       .toList();
  // }

  void _showTopSnackBar(BuildContext context, Widget widget) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        child: Material(
          color: primaryColor,
          child: widget,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((value) {
      if (overlayEntry.mounted) {
        // Check if the overlay entry is still mounted
        overlayEntry.remove();
      }
    });
  }

  Future<void> deleteExpense(Expense expense) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('categories')
          .doc(widget.category.id) // Access the category from the widget
          .collection('expenses')
          .doc(expense.id)
          .delete();
    } catch (error) {
      throw 'Error deleting expense: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: secondaryColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_double_arrow_left),
                      Text(AppLocalizations.of(context)!.category),
                      Icon(Icons.keyboard_double_arrow_right),
                    ],
                  ),
                  IntrinsicHeight(
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          IconData(widget.category.iconCodePoint,
                              fontFamily: 'MaterialIcons'),
                          color: primaryColor,
                        ),
                        title: Text(widget.category.name),
                        subtitle: Text(widget.category.description),
                        tileColor: Colors.white,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  parseColor(widget.category.color),
                              radius: 10,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(widget.category.totalAmount.toString())
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_double_arrow_left),
                Text(AppLocalizations.of(context)!.expenses),
                Icon(Icons.keyboard_double_arrow_right),
              ],
            ),
          ),
          // Expanded(
          //   child: FutureBuilder<List<Expense>>(
          //     future: fetchExpenses(widget.category.id),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Center(child: CircularProgressIndicator());
          //       }

          //       if (snapshot.hasError) {
          //         return Center(child: Text('Error: ${snapshot.error}'));
          //       }

          //       final expenses = snapshot.data ?? [];

          //       return ListView.builder(
          //         shrinkWrap: true,
          //         physics: NeverScrollableScrollPhysics(),
          //         itemCount: expenses.length,
          //         itemBuilder: (context, index) {
          //           final expense = expenses[index];

          //           return Padding(
          //             padding: const EdgeInsets.symmetric(vertical: 3),
          //             child: Container(
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.circular(8.0),
          //                 boxShadow: [
          //                   BoxShadow(
          //                     color: Colors.grey.withOpacity(0.5),
          //                     spreadRadius: 2,
          //                     blurRadius: 5,
          //                     offset: Offset(0, 2),
          //                   ),
          //                 ],
          //               ),
          //               child: ListTile(
          //                   // ListTile content
          //                   ),
          //             ),
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),

          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: fetchExpenses(widget.category.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final expenses = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.note_alt_outlined,
                              color: primaryColor,
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  color: Color.fromARGB(255, 11, 180, 180),
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    await updateExpense(context,
                                        categoryId: widget.category.id,
                                        expenseId: expense.id,
                                        updateUI: updateUI);

                                    // Implement editing functionality
                                    // For example, show a dialog to edit the category name
                                  },
                                ),
                                IconButton(
                                  color: redcolor,
                                  hoverColor: thirdColor,
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: thirdColor,
                                          icon: const Icon(
                                            Icons.dangerous,
                                            size: 40,
                                            color: redcolor,
                                          ),
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .warning),
                                          content: Text(
                                              AppLocalizations.of(context)!
                                                  .confirm_delete_message),
                                          actions: <Widget>[
                                            TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateColor
                                                        .resolveWith(
                                                  (states) => primaryColor,
                                                ),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .no,
                                                style: TextStyle(
                                                  color: white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateColor
                                                        .resolveWith(
                                                  (states) => redcolor,
                                                ),
                                              ),
                                              onPressed: () async {
                                                try {
                                                  await deleteExpense(expense);
                                                  if (mounted) {
                                                    setState(() {});
                                                  }
                                                  Navigator.of(context).pop();
                                                  _showTopSnackBar(
                                                    context,
                                                    CustomSnackBar(
                                                      iconData: Icons.check,
                                                      iconColor: fourthColor,
                                                      snackText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .deleteSuccess,
                                                    ),
                                                  );
                                                  setState(() {});
                                                } catch (error) {
                                                  _showTopSnackBar(
                                                    context,
                                                    CustomSnackBar(
                                                      iconData: Icons.error,
                                                      iconColor: redcolor,
                                                      snackText:
                                                          AppLocalizations.of(
                                                                  context)!
                                                              .deleteError,
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                AppLocalizations.of(context)!
                                                    .delete,
                                                style: TextStyle(
                                                  color: white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),

                            subtitle: Text(
                              expense.description,
                              overflow: TextOverflow.ellipsis,
                              maxLines:
                                  2, // Adjust the number of lines before ellipsis as needed
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(expense.amount.toStringAsFixed(
                                    2)), // Convert double to string
                                Text(expense.date),
                              ],
                            ), // Display formatted date
                            // Display formatted date
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            onTap: () {},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addExpense(context,
              categoryId: widget.category.id, updateUI: updateUI);
          setState(() {});
        },
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
    );
  }
}
