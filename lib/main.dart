import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCVpIPIt0XwQnk1tJf4U_4TT0RBxHU91Ls",
        authDomain: "dailyquoteapp-bc3bf.firebaseapp.com",
        projectId: "dailyquoteapp-bc3bf",
        storageBucket: "dailyquoteapp-bc3bf.appspot.com",
        messagingSenderId: "825923183845",
        appId: "1:825923183845:web:88e3795f3b3e59b82b200c", // You can replace this with your real Web App ID if you add one
      ),
    );
  } else {
    await Firebase.initializeApp();
    await NotificationService().init();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeProvider.currentTheme,
        home: const SplashScreenWrapper(),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        return const HomeScreen();
      } else {
        return const LoginScreen();
      }
    }
  }
}
