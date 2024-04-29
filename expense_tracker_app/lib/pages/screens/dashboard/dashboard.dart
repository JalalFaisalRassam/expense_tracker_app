import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:expense_tracker/components/custom_snakck_bar.dart';
import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/core/constants.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final incomeController = TextEditingController();
  double spent = 0; // Initialize spent value
  double rest = 0; // Initialize rest value
  double income = 0;

  @override
  void initState() {
    setState(() {});
    super.initState();
    _updateSpent(); // Update 'spent' value
    _fetchIncome(); // Fetch 'income' value
  }

  void _showTopSnackBar(BuildContext context, Widget widget) {
    final overlay = Overlay.of(context);
    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: widget,
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3)).then((value) {
      overlayEntry.remove();
    });
  }

  _updateStatistics(double totalIncome) async {
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('statistics')
        .doc('current')
        .get();

    if (doc.exists) {
      await doc.reference.update({
        'income': totalIncome,
        'spent': spent,
        'rest': totalIncome - spent,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('statistics')
          .doc('current')
          .set({
        'income': totalIncome,
        'spent': spent,
        'rest': totalIncome - spent,
      });
    }
  }

  void _updateSpent() {
    // Listen for changes in the categories subcollections
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      // Calculate the new 'spent' value based on the total amounts in categories
      double newSpent =
          snapshot.docs.fold(0, (prev, curr) => prev + curr['totalAmount']);
      setState(() {
        spent = newSpent;
        rest = income - spent;
      });
    });
  }

  void _fetchIncome() {
    // Fetch 'income' value from Firestore
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('statistics')
        .doc('current')
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          income = snapshot['income'];
          rest = income - spent; // Update 'rest' value too
        });
      } else {
        // Handle the case where the document does not exist
        // Set a default value for income or handle it based on your app's logic
        setState(() {
          income = 0; // Default value
          rest = -spent; // Update 'rest' value too
        });
      }
    }).catchError((error) {
      // Handle any errors that occur during the fetch operation
      print('Error fetching income: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: MyBottomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Your existing code for displaying total balance
            // ...
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor,
                      primaryColor,
                      externalColor,
                      // Theme.of(context).colorScheme.primary,
                      // Theme.of(context).colorScheme.secondary,
                      // Theme.of(context).colorScheme.tertiary,
                      primaryColor,
                      primaryColor,
                      externalColor,

                      // Theme.of(context).colorScheme.primary,
                      // Theme.of(context).colorScheme.secondary,
                      // Theme.of(context).colorScheme.tertiary,
                      primaryColor,
                      primaryColor,
                      externalColor,
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.grey.shade300,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.total_balance,
                      style: TextStyle(
                        fontSize: 16,
                        color: thirdColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${income - spent}',
                      style: TextStyle(
                        fontSize: 40,
                        color: thirdColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
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
                                                  // Fetch the current income value
                                                  double currentIncome = income;

                                                  // Calculate the new total income after removing the current income
                                                  double totalIncome =
                                                      income - currentIncome;

                                                  // Calculate the 'rest' value
                                                  rest = totalIncome - spent;

                                                  // Update statistics in Firestore
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .collection('statistics')
                                                      .doc('current')
                                                      .update({
                                                    'income': totalIncome,
                                                    'spent': spent,
                                                    'rest': rest,
                                                  });

                                                  Navigator.of(context).pop();
                                                  // Show a snackbar to indicate success
                                                  _showTopSnackBar(
                                                      context,
                                                      CustomSnackBar(
                                                        iconData: Icons.check,
                                                        iconColor: primaryColor,
                                                        snackText:
                                                            AppLocalizations.of(
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
                                                        snackText:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .deleteError,
                                                      ));
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
                                  icon: Icon(
                                    Icons.delete,
                                    color: redcolor,
                                    size: 30,
                                  )),
                              Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.arrow_down,
                                    size: 12,
                                    color: Colors.greenAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.income,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: thirdColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '$income',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: thirdColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 25,
                                height: 25,
                                decoration: const BoxDecoration(
                                  color: Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    CupertinoIcons.arrow_down,
                                    size: 12,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.expenses,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: thirdColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '$spent',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: thirdColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  MyTextField(
                    keyboardType: TextInputType.number,
                    hintText: AppLocalizations.of(context)!.enter_income,
                    controller: incomeController,
                  ),
                  SizedBox(height: 16),
                  MyButton(
                    buttonText: AppLocalizations.of(context)!.save,
                    onTap: () async {
                      double newIncome = double.parse(incomeController.text);
                      double totalIncome = income + newIncome;

                      // Update statistics in Firestore
                      await _updateStatistics(totalIncome);

                      // Update the 'income' and 'rest' values in the UI
                      setState(() {
                        income = totalIncome;
                        rest = totalIncome - spent;
                      });

                      // Clear the income text field
                      incomeController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    incomeController.dispose();
    super.dispose();
  }
}
