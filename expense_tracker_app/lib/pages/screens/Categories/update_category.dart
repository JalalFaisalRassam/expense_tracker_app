import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/Categories/categories.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future updateCategory(BuildContext context,
    {required String categoryId, required VoidCallback updateUI}) async {
  List<int> flutterIcons = [
    0xe0be, // Icons.phone
    0xe7ef, // Icons.star
    0xe8d3, // Icons.camera_alt
    0xe80d, // Icons.edit
    0xe8e1, // Icons.home
    0xe87c, // Icons.menu
    0xe8af,
    0xe531,
    0xe8f1,
    0xeb3b,
  ];

  int? iconSelected; // Initialize to null
  bool isExpanded = false;
  Color categoryColor = Colors.white;
  TextEditingController categoryNameController = TextEditingController();
  TextEditingController categoryDisController = TextEditingController();
  TextEditingController categoryIconController = TextEditingController();
  TextEditingController categoryColorController = TextEditingController();
  bool isLoading = false;

  // Fetch the existing category data based on the categoryId
  DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('categories')
      .doc(categoryId)
      .get();

  if (categorySnapshot.exists) {
    Map<String, dynamic> categoryData =
        categorySnapshot.data() as Map<String, dynamic>;
    categoryNameController.text = categoryData['name'];
    categoryDisController.text = categoryData['description'];
    // categoryColor = Color(int.parse(categoryData['color']));
    // You may need to map the icon data as well if it's stored in the document
    // For now, I'll leave it as it is
  }

  return showDialog(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: thirdColor,
            title: Text(AppLocalizations.of(context)!.update_category),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyTextField(
                      hintText: AppLocalizations.of(context)!.name_hint,
                      controller: categoryNameController,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    MyTextField(
                      hintText: AppLocalizations.of(context)!.description_hint,
                      controller: categoryDisController,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: categoryIconController,
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      textAlignVertical: TextAlignVertical.center,
                      readOnly: true,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        suffixIcon: const Icon(
                          Icons.list,
                          size: 12,
                        ),
                        fillColor: Colors.white,
                        hintText: AppLocalizations.of(context)!.icon_hint,
                        border: OutlineInputBorder(
                          borderRadius: isExpanded
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                )
                              : BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    isExpanded
                        ? Container(
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                ),
                                itemCount: flutterIcons.length,
                                itemBuilder: (context, int i) {
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        iconSelected = i;
                                      });
                                    },
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 3,
                                          color: iconSelected == i
                                              ? primaryColor
                                              : grey,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        IconData(
                                          flutterIcons[i],
                                          fontFamily: 'MaterialIcons',
                                        ),
                                        size: 30,
                                        color: iconSelected == i
                                            ? primaryColor
                                            : grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: categoryColorController,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx2) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ColorPicker(
                                    pickerColor: categoryColor,
                                    onColorChanged: (value) {
                                      setState(() {
                                        categoryColor = value;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() {});

                                        Navigator.pop(ctx2);
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .edit_color,
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      textAlignVertical: TextAlignVertical.center,
                      readOnly: true,
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: categoryColor,
                        hintText: AppLocalizations.of(context)!.color_hint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: kToolbarHeight,
                      child: isLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                              onPressed: () async {
                                // Find the index of the selected icon in myCategoriesIcons
                                if (iconSelected != null) {
                                  int iconCodePoint =
                                      flutterIcons[iconSelected!];

                                  Category category = Category(
                                    id: categoryId,
                                    name: categoryNameController.text,
                                    description: categoryDisController.text,
                                    iconCodePoint: iconCodePoint,
                                    color: categoryColor.toString(),
                                  );

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('categories')
                                      .doc(categoryId)
                                      .set(category
                                          .toMap()); // Use set instead of update
                                  updateUI();
                                  Navigator.pop(ctx);
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.update,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
