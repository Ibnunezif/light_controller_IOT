import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';

import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Enable offline persistence once during startup
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    
    runApp(const MyApp());
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    runApp(const MyApp()); // Still run the app even if Firebase fails
  }
}
