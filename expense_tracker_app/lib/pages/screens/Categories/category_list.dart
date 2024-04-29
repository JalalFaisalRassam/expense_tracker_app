import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/components/custom_snakck_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/Categories/add_category.dart';
import 'package:expense_tracker/pages/screens/Categories/categories.dart';
import 'package:expense_tracker/pages/screens/Categories/category_expense_details.dart';
import 'package:expense_tracker/pages/screens/Categories/update_category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryList extends StatefulWidget {
  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late Future<List<Category>> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _refreshCategoryList();

    // _categoryFuture = fetchCategories();
  }

  Future<void> _refreshCategoryList() async {
    setState(() {
      _categoryFuture = fetchCategories();
    });
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final userCategories = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('categories')
          .get();

      final categoryIds = userCategories.docs.map((doc) => doc.id).toList();

      final List<Category> categories = [];

      for (final categoryId in categoryIds) {
        final categoryDoc =
            userCategories.docs.firstWhere((doc) => doc.id == categoryId);
        final category = Category.fromMap(
            categoryId, categoryDoc.data() as Map<String, dynamic>);
        categories.add(category);
      }

      return categories;
    } catch (error) {
      print('Error fetching categories: $error');
      return [];
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Category>>(
        future: _categoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];

          return Padding(
            padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
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
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(category.icon, color: primaryColor),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(category.name),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              updateCategory(context,
                                  categoryId: category.id, updateUI: () {});
                            },
                          ),
                          IconButton(
                            color: redcolor,
                            hoverColor: thirdColor,
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
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
                      subtitle: Text(
                        category.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      tileColor: Colors.white,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: parseColor(category.color),
                            radius: 10,
                          ),
                          SizedBox(height: 10),
                          Text(category.totalAmount.toString())
                        ],
                      ),
                      onTap: () {
                        Get.to(CategoryDetailsPage(category: category));
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await addCategory(context);

          _refreshCategoryList();
        },
        backgroundColor: primaryColor,
        tooltip: 'Add Category',
        child: Icon(Icons.add),
      ),
    );
  }
}









// class _CategoryListState extends State<CategoryList> {
//   Future<List<Category>> fetchCategories() async {
//     try {
//       final userCategories = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .collection('categories')
//           .get();

//       final categoryIds = userCategories.docs.map((doc) => doc.id).toList();

//       final List<Future<void>> updateTasks = [];
//       final List<Category> categories = [];

//       for (final categoryId in categoryIds) {
//         final categoryDoc =
//             userCategories.docs.firstWhere((doc) => doc.id == categoryId);
//         final category = Category.fromMap(
//             categoryId, categoryDoc.data() as Map<String, dynamic>);
//         categories.add(category);

//         final expensesSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('categories')
//             .doc(categoryId)
//             .collection('expenses')
//             .get();

//         double totalAmount = expensesSnapshot.docs.fold(0.0, (total, doc) {
//           var amount = (doc.data()['amount'] ?? 0.0).toDouble();

//           print('Amount: $amount');
//           return total + amount;
//         });

//         updateTasks.add(FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('categories')
//             .doc(categoryId)
//             .update({'totalAmount': totalAmount}));
//       }

//       await Future.wait(updateTasks);

//       return categories;
//     } catch (error) {
//       print('Error fetching categories: $error');
//       return [];
//     }
//   }

//   // Future<List<Category>> fetchCategories() async {
//   //   try {
//   //     final userCategories = await FirebaseFirestore.instance
//   //         .collection('users')
//   //         .doc(FirebaseAuth.instance.currentUser!.uid)
//   //         .collection('categories')
//   //         .get();

//   //     List<Category> categories = userCategories.docs
//   //         .map((doc) =>
//   //             Category.fromMap(doc.id, doc.data() as Map<String, dynamic>))
//   //         .toList();

//   //     for (Category category in categories) {
//   //       final expensesSnapshot = await FirebaseFirestore.instance
//   //           .collection('users')
//   //           .doc(FirebaseAuth.instance.currentUser!.uid)
//   //           .collection('categories')
//   //           .doc(category.id)
//   //           .collection('expenses')
//   //           .get();

//   //       double totalAmount = expensesSnapshot.docs.fold(0, (total, doc) {
//   //         return total + (doc.data()['amount'] ?? 0);
//   //       });

//   //       await FirebaseFirestore.instance
//   //           .collection('users')
//   //           .doc(FirebaseAuth.instance.currentUser!.uid)
//   //           .collection('categories')
//   //           .doc(category.id)
//   //           .update({'totalAmount': totalAmount});
//   //     }
//   //     // if (mounted) {
//   //     //   setState(() {});
//   //     // }
//   //     return categories;
//   //   } catch (error) {
//   //     print('Error fetching categories: $error');
//   //     return [];
//   //   }
//   // }

//   Color parseColor(String colorString) {
//     final hexColor = colorString.split('(0x')[1].split(')')[0];
//     return Color(int.parse('0xFF$hexColor'));
//   }

//   void _showTopSnackBar(BuildContext context, Widget widget) {
//     final overlay = Overlay.of(context);
//     OverlayEntry overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: 0,
//         child: Material(
//           color: primaryColor,
//           child: widget,
//         ),
//       ),
//     );

//     overlay.insert(overlayEntry);

//     Future.delayed(Duration(seconds: 3)).then((value) {
//       overlayEntry.remove();
//     });
//   }

//   void updateUI() {
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // bottomNavigationBar: MyBottomAppBar(),
//       body: FutureBuilder<List<Category>>(
//         future: fetchCategories(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           final categories = snapshot.data ?? [];

//           return Padding(
//             padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
//             child: ListView.builder(
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 3),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.0),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.5),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: Offset(0, 2), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                     child: ListTile(
//                       leading: Icon(category.icon, color: primaryColor),
//                       title: Row(
//                         children: [
//                           Expanded(
//                             child: Text(category.name),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.edit),
//                             onPressed: () {
//                               // Call the updateCategory function with the existing category to edit
//                               updateCategory(context,
//                                   categoryId: category.id, updateUI: updateUI);
//                               print('hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh');
//                               print(category);
//                               print(category.id);
//                             },
//                           ),
//                           IconButton(
//                             color: redcolor,
//                             hoverColor: thirdColor,
//                             icon: const Icon(Icons.delete),
//                             onPressed: () async {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return AlertDialog(
//                                     backgroundColor: fourthColor,
//                                     icon: const Icon(
//                                       Icons.dangerous,
//                                       size: 40,
//                                       color: redcolor,
//                                     ),
//                                     title: Text(
//                                         AppLocalizations.of(context)!.warning),
//                                     content: Text(AppLocalizations.of(context)!
//                                         .confirm_delete_message),
//                                     actions: <Widget>[
//                                       TextButton(
//                                         style: ButtonStyle(
//                                           backgroundColor:
//                                               MaterialStateColor.resolveWith(
//                                             (states) => primaryColor,
//                                           ),
//                                         ),
//                                         onPressed: () {
//                                           Navigator.of(context).pop();
//                                         },
//                                         child: Text(
//                                           AppLocalizations.of(context)!.no,
//                                           style: TextStyle(
//                                             color: white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                       TextButton(
//                                         style: ButtonStyle(
//                                           backgroundColor:
//                                               MaterialStateColor.resolveWith(
//                                             (states) => redcolor,
//                                           ),
//                                         ),
//                                         onPressed: () async {
//                                           try {
//                                             // Add the code to delete the category here
//                                             await FirebaseFirestore.instance
//                                                 .collection('users')
//                                                 .doc(FirebaseAuth
//                                                     .instance.currentUser!.uid)
//                                                 .collection('categories')
//                                                 .doc(category.id)
//                                                 .delete();

//                                             // Check if the widget is still mounted before updating the UI
//                                             if (mounted) {
//                                               setState(() {});
//                                             }

//                                             // Close the dialog
//                                             Navigator.of(context).pop();
//                                             // Show a snackbar to indicate success
//                                             _showTopSnackBar(
//                                                 context,
//                                                 CustomSnackBar(
//                                                   iconData: Icons.check,
//                                                   iconColor: fourthColor,
//                                                   snackText:
//                                                       AppLocalizations.of(
//                                                               context)!
//                                                           .deleteSuccess,
//                                                 ));
//                                           } catch (error) {
//                                             _showTopSnackBar(
//                                                 context,
//                                                 CustomSnackBar(
//                                                   iconData: Icons.check,
//                                                   iconColor: primaryColor,
//                                                   snackText:
//                                                       AppLocalizations.of(
//                                                               context)!
//                                                           .deleteError,
//                                                 ));
//                                           }
//                                         },
//                                         child: Text(
//                                           AppLocalizations.of(context)!.delete,
//                                           style: TextStyle(
//                                             color: white,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       subtitle: Text(
//                         category.description,
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 2,
//                       ),
//                       tileColor: Colors.white,
//                       trailing: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircleAvatar(
//                             backgroundColor: parseColor(category.color),
//                             radius: 10,
//                           ),
//                           SizedBox(
//                             height: 10,
//                           ),
//                           Text(category.totalAmount.toString())
//                         ],
//                       ),
//                       onTap: () async {
//                         await Get.to(
//                           CategoryDetailsPage(category: category),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//           );
//           // ignore: dead_code
//         },
//       ),
//       floatingActionButton: Stack(
//         children: <Widget>[
//           Positioned(
//             bottom: -10.0, // Adjust this value to move the button up or down
//             right: MediaQuery.of(context).size.width / 3 -
//                 28, // Center the button horizontally
//             child: SizedBox(
//               width: 56.0, // Set the width of the button
//               child: FloatingActionButton(
//                 backgroundColor: primaryColor,
//                 onPressed: () async {
//                   await addCategory(context);
//                   setState(() {});
//                 },
//                 tooltip: 'Pick Image',
//                 child: Icon(Icons.add),
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//     );
//   }
// }
