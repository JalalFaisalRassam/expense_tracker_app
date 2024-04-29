import 'package:expense_tracker/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/components/password_textfield.dart';
import 'package:expense_tracker/pages/authentiction/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:expense_tracker/pages/main_page.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _isLoading = false; // Flag to indicate registration progress

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: white,
            ),
            Text(
              message,
              style: TextStyle(color: white),
            ),
          ],
        ),
      ),
    );
  }

// Other existing code...

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final user = userController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      showErrorMessage(AppLocalizations.of(context)!.empty_email);
      return;
    }

    if (password.isEmpty) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      showErrorMessage(AppLocalizations.of(context)!.empty_password);
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      showErrorMessage(AppLocalizations.of(context)!.password_mismatch);
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user information to Firestore
      await FirebaseFirestore.instance.collection('users').add({
        'name': user,
        'email': email,
      });

      // Registration successful (handle success logic here)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      showErrorMessage(handleFirebaseAuthException(e));
    } catch (e) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      showErrorMessage(AppLocalizations.of(context)!.unexpected_error);
    }
  }

  String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return AppLocalizations.of(context)!.weak_password;
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.email_in_use;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalid_email;
      default:
        return AppLocalizations.of(context)!.unexpected_error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... other UI elements ...

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // logo
                  Image.asset(
                    'images/logo.png',
                    width: 160.w,
                    height: 160.h,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(
                    height: 25,
                  ),

                  MyTextField(
                    controller: userController,
                    hintText: AppLocalizations.of(context)!.username,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                    controller: emailController,
                    hintText: AppLocalizations.of(context)!.email,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyPasswordTextField(
                    controller: passwordController,
                    hintText: AppLocalizations.of(context)!.password,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyPasswordTextField(
                    controller: confirmPasswordController,
                    hintText: AppLocalizations.of(context)!.confirm_password,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ... other UI elements ...

                  MyButton(
                    buttonText: AppLocalizations.of(context)!.register_button,
                    onTap: _isLoading
                        ? null
                        : registerUser, // Disable button during registration
                  ),

                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.already_have_account,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.login_button,
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )

                  // ... other UI elements ...
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
