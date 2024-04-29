import 'package:expense_tracker/core/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:expense_tracker/components/my_button.dart';
import 'package:expense_tracker/components/my_text_field.dart';
import 'package:expense_tracker/components/password_textfield.dart';
import 'package:expense_tracker/pages/authentiction/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:expense_tracker/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  void loginUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        showErrorMessage('Please enter your email and password.');
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sign-in successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } on FirebaseAuthException catch (e) {
      showErrorMessage(handleFirebaseAuthException(e));
    } catch (e) {
      showErrorMessage(AppLocalizations.of(context)!.unexpected_error);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppLocalizations.of(context)!.empty_email;
      case 'wrong-password':
        return AppLocalizations.of(context)!.wrong_password;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalid_email;
      default:
        return AppLocalizations.of(context)!.unexpected_error;
    }
  }

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

  // void showErrorMessage(BuildContext context, String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(message),
  //       actions: <Widget>[
  //         FlatButton(
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //           child: Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'images/logo.png',
                    width: 160.w.toDouble(),
                    height: 160.h.toDouble(),
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 25),
                  MyTextField(
                    controller: emailController,
                    hintText: AppLocalizations.of(context)!.email,
                  ),
                  const SizedBox(height: 10),
                  MyPasswordTextField(
                    controller: passwordController,
                    hintText: AppLocalizations.of(context)!.password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    buttonText: AppLocalizations.of(context)!.login_button,
                    onTap: _isLoading ? null : () => loginUser(context),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.no_account,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.create_account,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
