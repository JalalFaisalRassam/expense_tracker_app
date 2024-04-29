import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/pages/authentiction/login_page.dart';
import 'package:expense_tracker/pages/screens/dashboard/stats/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/pages/screens/Categories/category_list.dart';
import 'package:expense_tracker/pages/screens/dashboard/dashboard.dart';
import 'package:expense_tracker/pages/screens/expenses/expenses_list.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 1;
  final List<Widget> _pages = [
    CategoryList(),
    Dashboard(),
    Charts(),
    ExpenseList(),
  ];

  bool exitConfirmed = false;

  Future<bool> onWillPop() async {
    await Get.dialog(
      AlertDialog(
        backgroundColor: thirdColor,
        title: Text(AppLocalizations.of(context)!.warning),
        content: Text(AppLocalizations.of(context)!.warning_exit),
        actions: [
          TextButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateColor.resolveWith((states) => primaryColor)),
            child: Text(AppLocalizations.of(context)!.no,
                style: TextStyle(color: white)),
            onPressed: () {
              exitConfirmed = false;
              Get.back();
            },
          ),
          TextButton(
            child: Text(AppLocalizations.of(context)!.yes,
                style: TextStyle(color: Colors.white)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red)),
            onPressed: () {
              exitConfirmed = true;
              Get.back();
            },
          ),
        ],
      ),
    );
    return exitConfirmed;
  }

  // void signUserOut() {
  //   FirebaseAuth.instance.signOut();
  // }
  void signUserOut() async {
    await FirebaseAuth.instance.signOut();
    // Perform additional actions after sign-out, such as navigating to another page
    // or updating the UI.
    // For example:
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
    // or
    setState(() {
      // Update UI state
    });
  }

  // ignore: unused_field
  Uint8List? _imageBytes;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imageFile = File(pickedImage.path);
      final imageBytes = await imageFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
      await _uploadImageToStorage(imageBytes);
    }
  }

  Future<void> _uploadImageToStorage(Uint8List imageBytes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile_image.png');
      try {
        await imageRef.putData(imageBytes);
        final imageUrl = await imageRef.getDownloadURL();
        // Update user profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileImageUrl': imageUrl,
        });
      } catch (e) {
        print('Error uploading image: $e');
        // Handle the error appropriately (e.g., show a message to the user)
      }
    }
  }

  Future<void> _fetchImageFromStorage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final imageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('profile_image.png');
      try {
        // ignore: unused_local_variable
        final imageUrl = await imageRef.getDownloadURL();
        setState(() {
          _imageBytes = null;
        });
        // You may want to use a caching mechanism here to avoid fetching the image every time
      } catch (e) {
        print('Error fetching image: $e');
        // Handle the error appropriately (e.g., set a default image)
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchImageFromStorage();
  }

  Future<String> getUsernameFromFirestore(String email) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userData = snapshot.docs.first.data();
        return userData['name'] ?? 'User Name';
      }
      return 'User Name';
    } catch (e) {
      print('Error fetching username: $e');
      return 'User Name';
    }
  }

  Future<String> getUserDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return getUsernameFromFirestore(user.email!);
    }
    return 'User Name';
  }

  // ignore: unused_field
  bool _isArabicSelected = false; // Track language selection

  // ignore: unused_field
  bool _isEnglishSelected = false;

  void _selectArabic() {
    setState(() {
      _isArabicSelected = true;
      _isEnglishSelected = false;
      Get.updateLocale(Locale('ar'));
    });
  }

  void _selectEnglish() {
    setState(() {
      _isArabicSelected = false;
      _isEnglishSelected = true;
      Get.updateLocale(Locale('en'));
    });
  }
  //   textDirection: _isArabicSelected ? TextDirection.rtl : TextDirection.ltr,

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: PopupMenuButton(
            color: primaryColor,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: white,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.language, color: white),
                  title: Text(
                    AppLocalizations.of(context)!.arabic,
                    style: TextStyle(color: white),
                  ),
                  onTap: () {
                    _selectArabic(); // Call the function here
                    Navigator.pop(context);
                    setState(() {});
                    // Navigate to account page
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(
                    Icons.language_sharp,
                    color: white,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.english,
                    style: TextStyle(color: white),
                  ),
                  onTap: () {
                    _selectEnglish();
                    Navigator.pop(context);

                    // Navigate to settings page
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: white,
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.logout,
                    style: TextStyle(color: white),
                  ),
                  onTap: () {
                    signUserOut();
                    Navigator.pop(context);
                    // Implement logout functionality
                  },
                ),
              ),
            ],
          ),
          actions: [
            FutureBuilder<String>(
              future: getUserDisplayName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading...');
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Text(
                  snapshot.data ?? AppLocalizations.of(context)!.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                );
              },
            ),
            Container(
              // decoration: BoxDecoration(
              //     border: Border.all(color: white),
              //     borderRadius: BorderRadius.circular(50)),
              width: 50,
              child: GestureDetector(
                onTap: _getImage,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: thirdColor,
                    radius: 50,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : AssetImage('images/image.png')
                            as ImageProvider<Object>,
                  ),
                ),
              ),
            ),
          ],
        ),
        // very important
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          unselectedItemColor: externalColor,
          selectedFontSize: 12, // Reduced selected item font size
          selectedIconTheme:
              IconThemeData(size: 24), // Reduced selected icon size
          unselectedLabelStyle: TextStyle(color: white),
          backgroundColor: primaryColor,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.category,
                size: 24, // Adjusted icon size
              ),
              label: AppLocalizations.of(context)!.categories,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 24, // Adjusted icon size
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.auto_graph_rounded,
                size: 24, // Adjusted icon size
              ),
              label: AppLocalizations.of(context)!.statistics,
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.monetization_on,
                size: 24, // Adjusted icon size
              ),
              label: AppLocalizations.of(context)!.expenses,
            ),
          ],
        ),
      ),
    );
  }
}
