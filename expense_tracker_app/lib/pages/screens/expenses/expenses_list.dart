import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/components/custom_snakck_bar.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/Categories/add_category.dart';
import 'package:expense_tracker/pages/screens/Categories/categories.dart';
import 'package:expense_tracker/pages/screens/Categories/update_category.dart';
import 'package:expense_tracker/pages/screens/expenses/expenses.dart';
import 'package:expense_tracker/pages/screens/expenses/update_expense.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExpenseList extends StatefulWidget {
  @override
  State<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends State<ExpenseList> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void updateUI() {
    setState(() {});
  }
// Future<List<Category>> fetchCategories() async {
//   final userCategories = await FirebaseFirestore.instance
//       .collection('users')
//       .doc(FirebaseAuth.instance.currentUser!.uid)
//       .collection('categories')
//       .get();

//   return categories;
// }
  bool _isMounted = false;
  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  void _someAsyncOperation() {
    // Check if the widget is still mounted before calling setState
    if (_isMounted) {
      setState(() {
        // Update your state here
      });
    }
  }

  Future<List<Category>> fetchCategories() async {
    final userCategories = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .get();

    List<Category> categories = [];

    for (var doc in userCategories.docs) {
      List<Expense> expenses = [];

      // Fetch expenses for the category
      var expensesSnapshot = await doc.reference.collection('expenses').get();

      for (var expenseDoc in expensesSnapshot.docs) {
        expenses.add(Expense.fromMap(
          expenseDoc.id,
          expenseDoc.data(),
        ));
      }

      // Calculate total amount
      double totalAmount = expenses.fold(0.0, (total, expense) {
        return total + (expense.amount ?? 0.0);
      });

      // Update total amount in category document
      await doc.reference.update({'totalAmount': totalAmount});

      // Create Category object
      categories.add(Category.fromMap(
        doc.id,
        doc.data(),
        expenses,
      ));
    }

    return categories;
  }

  // Future<List<Category>> fetchCategories() async {
  //   final userCategories = await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(FirebaseAuth.instance.currentUser!.uid)
  //       .collection('categories')
  //       .get();
  //   List<Category> categories1 = userCategories.docs
  //       .map((doc) =>
  //           Category.fromMap(doc.id, doc.data() as Map<String, dynamic>))
  //       .toList();

  //   // Iterate through categories to update total amount
  //   for (Category category in categories1) {
  //     // Get expenses for the category
  //     final expensesSnapshot = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .collection('categories')
  //         .doc(category.id)
  //         .collection('expenses')
  //         .get();

  //     // Calculate total amount
  //     double totalAmount = expensesSnapshot.docs.fold(0.0, (total, doc) {
  //       return total + (doc.data()['amount'] ?? 0.0);
  //     });

  //     // Update total amount in category document
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(FirebaseAuth.instance.currentUser!.uid)
  //         .collection('categories')
  //         .doc(category.id)
  //         .update({'totalAmount': totalAmount});
  //   }
  //   List<Category> categories = [];
  //   for (var doc in userCategories.docs) {
  //     List<Expense> expenses = [];
  //     var expensesSnapshot = await doc.reference.collection('expenses').get();
  //     for (var expenseDoc in expensesSnapshot.docs) {
  //       expenses.add(Expense.fromMap(expenseDoc.id, expenseDoc.data()));
  //     }
  //     categories.add(Category.fromMap(doc.id, doc.data(), expenses));
  //   }

  //   return categories;
  // }

  Color parseColor(String colorString) {
    final hexColor = colorString.split('(0x')[1].split(')')[0];
    return Color(int.parse('0xFF$hexColor'));
  }

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
      overlayEntry.remove();
    });
  }

  Future<void> deleteExpense(Category category, Expense expense) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('categories')
          .doc(category.id)
          .collection('expenses')
          .doc(expense.id)
          .delete();
      _someAsyncOperation();
    } catch (error) {
      throw 'Error deleting expense: $error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: MyBottomAppBar(),
      key: _scaffoldKey,
      body: FutureBuilder<List<Category>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Container(
                  decoration: BoxDecoration(
                    color: thirdColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    trailing: CircleAvatar(
                      child: Icon(Icons.keyboard_arrow_down_outlined),
                      backgroundColor: parseColor(category.color),
                    ),
                    collapsedTextColor: parseColor(category.color),
                    leading: Icon(category.icon, color: primaryColor),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            category.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateCategory(context,
                                categoryId: category.id, updateUI: updateUI);
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
                                      AppLocalizations.of(context)!.warning),
                                  content: Text(AppLocalizations.of(context)!
                                      .confirm_delete_message),
                                  actions: <Widget>[
                                    TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                          (states) => primaryColor,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.no,
                                        style: TextStyle(
                                          color: white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                          (states) => redcolor,
                                        ),
                                      ),
                                      onPressed: () async {
                                        try {
                                          // Add the code to delete the category here
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .collection('categories')
                                              .doc(category.id)
                                              .delete();
                                          // Close the dialog
                                          Navigator.of(context).pop();
                                          // Show a snackbar to indicate success
                                          _showTopSnackBar(
                                              context,
                                              CustomSnackBar(
                                                iconData: Icons.check,
                                                iconColor: primaryColor,
                                                snackText: AppLocalizations.of(
                                                        context)!
                                                    .deleteSuccess,
                                              ));

                                          // Update the UI
                                          setState(() {});
                                        } catch (error) {
                                          _showTopSnackBar(
                                              context,
                                              CustomSnackBar(
                                                iconData: Icons.check,
                                                iconColor: primaryColor,
                                                snackText: AppLocalizations.of(
                                                        context)!
                                                    .deleteError,
                                              ));
                                        }
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.delete,
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
                    children: category.expenses.map((expense) {
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
                            leading: Icon(Icons.note_alt_outlined),
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
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 11, 180, 180),
                                  ),
                                  onPressed: () async {
                                    print(
                                        ' category.id kkkkkkkkkkkkkkkkkkkkkk');
                                    print(category.id);
                                    print(expense.id);
                                    await updateExpense(context,
                                        categoryId: category.id,
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
                                          backgroundColor: fourthColor,
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
                                                  await deleteExpense(
                                                      category, expense);
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
                                                  // setState(() {});
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
                              maxLines: 2,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(expense.amount.toStringAsFixed(2)),
                                Text(expense.date),
                              ],
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            onTap: () {
                              // Implement editing or deleting the expense
                              // For example, show a dialog to edit the expense details
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addCategory(context);
          setState(() {});
        },
        backgroundColor: primaryColor,
        tooltip: 'Add Category',
        child: Icon(Icons.add),
      ),
    );
  }
}
