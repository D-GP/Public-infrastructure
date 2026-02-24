import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'utils/language_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Timer? _logoutTimer;
  final _storage = const FlutterSecureStorage();

  void _startTimer() {
    _logoutTimer?.cancel();
    _logoutTimer = Timer(const Duration(minutes: 2), _performLogout);
  }

  void _handleUserInteraction([_]) {
    _startTimer();
  }

  Future<void> _performLogout() async {
    await _storage.deleteAll();

    // Check if context is available to navigate
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/login'),
          builder: (context) => const LoginScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _logoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleUserInteraction,
      onPointerMove: _handleUserInteraction,
      onPointerUp: _handleUserInteraction,
      child: ValueListenableBuilder<Locale>(
        valueListenable: LanguageManager.instance.currentLocale,
        builder: (context, locale, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            locale: locale,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
