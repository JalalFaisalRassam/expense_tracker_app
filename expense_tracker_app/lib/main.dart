import 'package:expense_tracker/core/constants.dart';
import 'package:expense_tracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/l10n/l10n.dart';
import 'package:expense_tracker/splash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GetMaterialApp(
        supportedLocales: L10n.all,
        locale: Get.locale ?? Locale('en'),
        localeResolutionCallback: (locale, supportedLocales) {
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale?.languageCode &&
                supportedLocale.countryCode == locale?.countryCode) {
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // fontFamily: AppLocalizations.of(context)!.font,
          primaryColor: primaryColor,
          hintColor: secondaryColor,
          backgroundColor: fourthColor,
          scaffoldBackgroundColor: fourthColor,
          appBarTheme: AppBarTheme(
            backgroundColor: primaryColor,
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: MaterialColor(primaryColor.value, {
              50: primaryColor,
              100: fourthColor,
              200: primaryColor,
              300: primaryColor,
              400: fourthColor,
              500: primaryColor,
              600: fourthColor,
              700: primaryColor,
              800: fourthColor,
              900: primaryColor,
            }),
          ).copyWith(
            secondary: secondaryColor,
          ),
          textTheme: TextTheme(
            // Set default font size to 12
            bodyLarge: TextStyle(fontSize: 16),
            bodyMedium: TextStyle(fontSize: 14),
            bodySmall: TextStyle(fontSize: 12),
            labelSmall: TextStyle(fontSize: 12),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}
