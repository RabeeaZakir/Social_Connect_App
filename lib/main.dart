import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import this
import 'firebase_options.dart'; // Generated file
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  // Widgets binding initialize karna zaroori hai
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const SocialConnectApp(),
    ),
  );
}

class SocialConnectApp extends StatelessWidget {
  const SocialConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}