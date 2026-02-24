import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/language_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageManager.instance.currentLocale,
      builder: (context, locale, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          home: const SplashScreen(),
        );
      },
    );
  }
}
