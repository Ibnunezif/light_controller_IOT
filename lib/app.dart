import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/language.dart';
import 'screens/bulb_list_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLanguage _currentLang = AppLanguage.english;
  final AuthService _authService = AuthService();

  void _changeLanguage(AppLanguage lang) {
    setState(() {
      _currentLang = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Light Controller IoT',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1B1F26),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          surface: Color(0xFF252932),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return BulbListScreen(
              currentLang: _currentLang,
              onLanguageChanged: _changeLanguage,
            );
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
